`timescale 1ns / 1ps

// AXI4-Lite slave wrapper for snn_top.
// Designed to attach to a MicroBlaze AXI4-Lite master (LMB->AXI bridge or
// direct M_AXI_DP). Hosts a 4 KB internal image BRAM that is served to the
// SNN core via its existing dtcm_* read port, so the SNN sees the same
// interface it had against the RV32I DTCM.
//
// Register map (byte offsets, 32-bit aligned):
//   0x0000 CTRL       RW  [0] ap_start (kick, self-clear)  [1] soft_reset (active high)
//   0x0004 STATUS     RO  [0] ap_done   (done_l2 sticky, HLS ap_ctrl_hs)
//                         [1] ap_idle   (~busy)
//                         [2] ap_ready  (~busy, can accept next ap_start)
//                         [3] busy
//                         [4] done_l1   (sticky)
//                         [5] done_learn (sticky)
//   0x0008 TIMESTEP   RW  [7:0]
//   0x000C IMG_BASE   RW  [11:0]  base offset into image BRAM for SNN scan
//   0x0010 HIDDEN_LO  RO  hidden_spike_o[31:0]
//   0x0014 HIDDEN_HI  RO  hidden_spike_o[63:32]
//   0x0018 OUTPUT     RO  output_spike_o[9:0]
//   0x4000-0x4FFF     RW  IMG_BUF  (1024 x 32b BRAM, also read by SNN dtcm port)
//
// Address decode: bit[14] selects IMG_BUF (1) vs CSR (0).
// Total slave aperture: 32 KB (15-bit AXI address).

module axi4lite_snn_wrapper #(
    parameter C_S_AXI_ADDR_WIDTH = 15,
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter WEIGHT_WIDTH       = 8,
    parameter TIMESTEP_WIDTH     = 8
)(
    input  wire                              S_AXI_ACLK,
    input  wire                              S_AXI_ARESETN,

    // Write address channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_AWADDR,
    input  wire [2:0]                        S_AXI_AWPROT,
    input  wire                              S_AXI_AWVALID,
    output reg                               S_AXI_AWREADY,

    // Write data channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  wire                              S_AXI_WVALID,
    output reg                               S_AXI_WREADY,

    // Write response channel
    output reg  [1:0]                        S_AXI_BRESP,
    output reg                               S_AXI_BVALID,
    input  wire                              S_AXI_BREADY,

    // Read address channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_ARADDR,
    input  wire [2:0]                        S_AXI_ARPROT,
    input  wire                              S_AXI_ARVALID,
    output reg                               S_AXI_ARREADY,

    // Read data channel
    output reg  [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA,
    output reg  [1:0]                        S_AXI_RRESP,
    output reg                               S_AXI_RVALID,
    input  wire                              S_AXI_RREADY
);

    // ------------------------------------------------------------------
    // CSR storage
    // ------------------------------------------------------------------
    reg        ctrl_kick;          // self-clearing pulse
    reg        ctrl_soft_reset;
    reg [7:0]  reg_timestep;
    reg [11:0] reg_img_base;

    // ------------------------------------------------------------------
    // SNN <-> wrapper signals
    // ------------------------------------------------------------------
    wire [63:0] hidden_spike;
    wire [9:0]  output_spike;
    wire        done_l1, done_l2, done_learn;

    wire        snn_dtcm_rd_en;
    wire [11:0] snn_dtcm_addr;
    wire [31:0] snn_dtcm_data;

    // Combined reset: external aresetn AND not soft_reset
    wire        snn_rstn = S_AXI_ARESETN & ~ctrl_soft_reset;

    // busy: kick seen but neither layer-2 done nor learn done flag observed yet
    reg busy_r;
    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN)       busy_r <= 1'b0;
        else if (ctrl_kick)       busy_r <= 1'b1;
        else if (done_l2)         busy_r <= 1'b0;
    end

    // Sticky done flags (cleared on kick)
    reg done_l1_sticky, done_l2_sticky, done_learn_sticky;
    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            done_l1_sticky    <= 1'b0;
            done_l2_sticky    <= 1'b0;
            done_learn_sticky <= 1'b0;
        end else if (ctrl_kick) begin
            done_l1_sticky    <= 1'b0;
            done_l2_sticky    <= 1'b0;
            done_learn_sticky <= 1'b0;
        end else begin
            if (done_l1)    done_l1_sticky    <= 1'b1;
            if (done_l2)    done_l2_sticky    <= 1'b1;
            if (done_learn) done_learn_sticky <= 1'b1;
        end
    end

    // ------------------------------------------------------------------
    // Image BRAM (1024 x 32b)
    //   Port A: AXI read/write (32-bit word addressed by AWADDR[11:2])
    //   Port B: SNN dtcm read port
    // ------------------------------------------------------------------
    reg [31:0] img_bram [0:1023];
    reg [31:0] img_bram_axi_dout;
    reg [31:0] img_bram_snn_dout;

    // AXI port (synchronous read; write handled in write FSM below)
    wire        img_axi_rd_en;
    wire [9:0]  img_axi_rd_addr;

    always @(posedge S_AXI_ACLK) begin
        if (img_axi_rd_en)
            img_bram_axi_dout <= img_bram[img_axi_rd_addr];
    end

    // SNN port
    always @(posedge S_AXI_ACLK) begin
        if (snn_dtcm_rd_en)
            img_bram_snn_dout <= img_bram[snn_dtcm_addr[9:0]];
    end
    assign snn_dtcm_data = img_bram_snn_dout;

    // ------------------------------------------------------------------
    // AXI4-Lite write FSM
    // ------------------------------------------------------------------
    localparam W_IDLE = 2'd0, W_DATA = 2'd1, W_RESP = 2'd2;
    reg [1:0]                       w_state;
    reg [C_S_AXI_ADDR_WIDTH-1:0]    awaddr_lat;

    wire is_img_write = awaddr_lat[14];
    wire [13:0] csr_waddr = awaddr_lat[13:0];

    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            w_state          <= W_IDLE;
            S_AXI_AWREADY    <= 1'b0;
            S_AXI_WREADY     <= 1'b0;
            S_AXI_BVALID     <= 1'b0;
            S_AXI_BRESP      <= 2'b00;
            awaddr_lat       <= {C_S_AXI_ADDR_WIDTH{1'b0}};

            ctrl_kick        <= 1'b0;
            ctrl_soft_reset  <= 1'b0;
            reg_timestep     <= 8'd0;
            reg_img_base     <= 12'd0;
        end else begin
            // CTRL.kick is a 1-cycle self-clearing pulse
            ctrl_kick <= 1'b0;

            case (w_state)
            W_IDLE: begin
                S_AXI_AWREADY <= 1'b1;
                S_AXI_WREADY  <= 1'b0;
                S_AXI_BVALID  <= 1'b0;
                if (S_AXI_AWVALID && S_AXI_AWREADY) begin
                    awaddr_lat    <= S_AXI_AWADDR;
                    S_AXI_AWREADY <= 1'b0;
                    S_AXI_WREADY  <= 1'b1;
                    w_state       <= W_DATA;
                end
            end
            W_DATA: begin
                if (S_AXI_WVALID && S_AXI_WREADY) begin
                    S_AXI_WREADY <= 1'b0;

                    if (is_img_write) begin
                        // 1024 x 32b: word index = awaddr_lat[11:2]
                        // Honor WSTRB byte-wise (AXI4-Lite IHI 0022D §A3.4.3)
                        if (S_AXI_WSTRB[0]) img_bram[awaddr_lat[11:2]][ 7: 0] <= S_AXI_WDATA[ 7: 0];
                        if (S_AXI_WSTRB[1]) img_bram[awaddr_lat[11:2]][15: 8] <= S_AXI_WDATA[15: 8];
                        if (S_AXI_WSTRB[2]) img_bram[awaddr_lat[11:2]][23:16] <= S_AXI_WDATA[23:16];
                        if (S_AXI_WSTRB[3]) img_bram[awaddr_lat[11:2]][31:24] <= S_AXI_WDATA[31:24];
                    end else begin
                        case (csr_waddr[7:0])
                        8'h00: if (S_AXI_WSTRB[0]) begin // CTRL (bits in byte 0)
                            ctrl_kick       <= S_AXI_WDATA[0];
                            ctrl_soft_reset <= S_AXI_WDATA[1];
                        end
                        8'h08: if (S_AXI_WSTRB[0]) reg_timestep <= S_AXI_WDATA[7:0];
                        8'h0C: begin // IMG_BASE spans bytes 0-1 (12 bits)
                            if (S_AXI_WSTRB[0]) reg_img_base[ 7:0] <= S_AXI_WDATA[ 7:0];
                            if (S_AXI_WSTRB[1]) reg_img_base[11:8] <= S_AXI_WDATA[11:8];
                        end
                        default: ; // unmapped writes silently OKAY (per AXI-Lite norm)
                        endcase
                    end

                    S_AXI_BRESP  <= 2'b00; // OKAY
                    S_AXI_BVALID <= 1'b1;
                    w_state      <= W_RESP;
                end
            end
            W_RESP: begin
                if (S_AXI_BREADY && S_AXI_BVALID) begin
                    S_AXI_BVALID  <= 1'b0;
                    S_AXI_AWREADY <= 1'b1;
                    w_state       <= W_IDLE;
                end
            end
            default: w_state <= W_IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------------
    // AXI4-Lite read FSM
    // ------------------------------------------------------------------
    localparam R_IDLE = 2'd0, R_WAIT_BRAM = 2'd1, R_RESP = 2'd2;
    reg [1:0]                    r_state;
    reg [C_S_AXI_ADDR_WIDTH-1:0] araddr_lat;

    assign img_axi_rd_en   = (r_state == R_IDLE) && S_AXI_ARVALID && S_AXI_ARREADY && S_AXI_ARADDR[14];
    assign img_axi_rd_addr = S_AXI_ARADDR[11:2];

    wire is_img_read = araddr_lat[14];

    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            r_state       <= R_IDLE;
            S_AXI_ARREADY <= 1'b0;
            S_AXI_RVALID  <= 1'b0;
            S_AXI_RDATA   <= 32'd0;
            S_AXI_RRESP   <= 2'b00;
            araddr_lat    <= {C_S_AXI_ADDR_WIDTH{1'b0}};
        end else begin
            case (r_state)
            R_IDLE: begin
                S_AXI_ARREADY <= 1'b1;
                S_AXI_RVALID  <= 1'b0;
                if (S_AXI_ARVALID && S_AXI_ARREADY) begin
                    araddr_lat    <= S_AXI_ARADDR;
                    S_AXI_ARREADY <= 1'b0;
                    // BRAM read is registered: need 1 cycle.
                    // CSR read can be combinational, but for timing we mux next cycle too.
                    r_state       <= R_WAIT_BRAM;
                end
            end
            R_WAIT_BRAM: begin
                if (is_img_read) begin
                    S_AXI_RDATA <= img_bram_axi_dout;
                end else begin
                    case (araddr_lat[7:0])
                    8'h00:   S_AXI_RDATA <= {30'd0, ctrl_soft_reset, 1'b0};
                    8'h04:   S_AXI_RDATA <= {26'd0,
                                              done_learn_sticky, // [5]
                                              done_l1_sticky,    // [4]
                                              busy_r,            // [3]
                                              ~busy_r,           // [2] ap_ready
                                              ~busy_r,           // [1] ap_idle
                                              done_l2_sticky};   // [0] ap_done
                    8'h08:   S_AXI_RDATA <= {24'd0, reg_timestep};
                    8'h0C:   S_AXI_RDATA <= {20'd0, reg_img_base};
                    8'h10:   S_AXI_RDATA <= hidden_spike[31:0];
                    8'h14:   S_AXI_RDATA <= hidden_spike[63:32];
                    8'h18:   S_AXI_RDATA <= {22'd0, output_spike};
                    default: S_AXI_RDATA <= 32'hDEAD_BEEF;
                    endcase
                end
                S_AXI_RRESP  <= 2'b00;
                S_AXI_RVALID <= 1'b1;
                r_state      <= R_RESP;
            end
            R_RESP: begin
                if (S_AXI_RREADY && S_AXI_RVALID) begin
                    S_AXI_RVALID  <= 1'b0;
                    S_AXI_ARREADY <= 1'b1;
                    r_state       <= R_IDLE;
                end
            end
            default: r_state <= R_IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------------
    // SNN core instance
    // ------------------------------------------------------------------
    snn_top #(
        .WEIGHT_WIDTH  (WEIGHT_WIDTH),
        .TIMESTEP_WIDTH(TIMESTEP_WIDTH)
    ) u_snn (
        .clk_i         (S_AXI_ACLK),
        .rstn_i        (snn_rstn),
        .timestep_i    (reg_timestep),
        .snn_kick_i    (ctrl_kick),
        .img_base_i    (reg_img_base),
        .hidden_spike_o(hidden_spike),
        .output_spike_o(output_spike),
        .done_layer1_o (done_l1),
        .done_layer2_o (done_l2),
        .done_learn_o  (done_learn),
        .dtcm_rd_en_o  (snn_dtcm_rd_en),
        .dtcm_addr_o   (snn_dtcm_addr),
        .dtcm_data_i   (snn_dtcm_data)
    );

endmodule
