`timescale 1ns / 1ps
// AXI4-Lite master bridge: translates the CPU's 1-cycle write pulse and
// status-read into AXI UARTLite transactions.
//
// CPU interface:
//   cpu_wr_en  / cpu_wr_data  → AXI write to TX FIFO  (addr 0x4)
//   tx_full_o                 → cached TX_FULL from AXI Status reg (addr 0x8, bit 3)
//
// The FSM runs continuously: after every write it reads back status, then
// loops on status reads while idle.  The CPU polls tx_full_o (returned as
// bit 0 of the load from 0x40000004) before each write, so it never
// submits a byte when the FIFO is full.

module axi_uart_bridge (
    input        clk_i,
    input        rstn_i,
    // CPU-side interface
    input        cpu_wr_en,       // 1-cycle pulse: write byte to TX FIFO
    input  [7:0] cpu_wr_data,     // byte to transmit
    output       tx_full_o,       // TX FIFO full (bit 0 returned to CPU)
    // Physical UART pins
    output       uart_tx_o,
    input        uart_rx_i
);

    // ----------------------------------------------------------------
    // AXI4-Lite signals to axi_uart IP
    // ----------------------------------------------------------------
    reg  [3:0]  axi_awaddr;
    reg         axi_awvalid;
    wire        axi_awready;

    reg  [31:0] axi_wdata;
    reg  [3:0]  axi_wstrb;
    reg         axi_wvalid;
    wire        axi_wready;

    wire [1:0]  axi_bresp;
    wire        axi_bvalid;
    reg         axi_bready;

    reg  [3:0]  axi_araddr;
    reg         axi_arvalid;
    wire        axi_arready;

    wire [31:0] axi_rdata;
    wire [1:0]  axi_rresp;
    wire        axi_rvalid;
    reg         axi_rready;

    // ----------------------------------------------------------------
    // AXI UARTLite register addresses (4-bit AXI addr space)
    // ----------------------------------------------------------------
    localparam UART_TX_FIFO_ADDR = 4'h4;   // write-only
    localparam UART_STATUS_ADDR  = 4'h8;   // read-only  bit3=TX_FULL

    // ----------------------------------------------------------------
    // FSM
    // ----------------------------------------------------------------
    localparam [2:0]
        IDLE       = 3'd0,
        WR_AW_W    = 3'd1,   // drive AW + W channels simultaneously
        WR_WAIT_B  = 3'd2,   // wait for write response
        RD_AR      = 3'd3,   // drive AR channel (status read)
        RD_WAIT_R  = 3'd4;   // wait for read data

    reg [2:0] state;
    reg [7:0] wr_data_buf;
    reg       wr_pending;
    reg       tx_full_cached;
    reg       aw_done, w_done;

    assign tx_full_o = tx_full_cached;

    // ----------------------------------------------------------------
    // FSM + write capture
    // ----------------------------------------------------------------
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            state          <= IDLE;
            wr_pending     <= 1'b0;
            wr_data_buf    <= 8'h0;
            tx_full_cached <= 1'b0;
            aw_done        <= 1'b0;
            w_done         <= 1'b0;
            axi_awvalid    <= 1'b0;
            axi_awaddr     <= 4'h0;
            axi_wvalid     <= 1'b0;
            axi_wdata      <= 32'h0;
            axi_wstrb      <= 4'hF;
            axi_bready     <= 1'b0;
            axi_arvalid    <= 1'b0;
            axi_araddr     <= 4'h0;
            axi_rready     <= 1'b0;
        end else begin

            // Capture write request whenever the CPU issues one and the
            // pending slot is free.  The slot is guaranteed free before
            // the next write because SW polls tx_full_o first.
            if (cpu_wr_en && !wr_pending) begin
                wr_data_buf <= cpu_wr_data;
                wr_pending  <= 1'b1;
            end

            case (state)
                // ---------------------------------------------------------
                IDLE: begin
                    aw_done     <= 1'b0;
                    w_done      <= 1'b0;
                    axi_arvalid <= 1'b0;
                    axi_bready  <= 1'b0;
                    if (wr_pending) begin
                        wr_pending  <= 1'b0;
                        axi_awaddr  <= UART_TX_FIFO_ADDR;
                        axi_awvalid <= 1'b1;
                        axi_wdata   <= {24'h0, wr_data_buf};
                        axi_wstrb   <= 4'hF;
                        axi_wvalid  <= 1'b1;
                        state       <= WR_AW_W;
                    end else begin
                        // Continuous status refresh when no write is pending
                        axi_araddr  <= UART_STATUS_ADDR;
                        axi_arvalid <= 1'b1;
                        state       <= RD_AR;
                    end
                end

                // ---------------------------------------------------------
                // Drive both AW and W channels; track independent handshakes
                WR_AW_W: begin
                    if (axi_awvalid && axi_awready) begin
                        axi_awvalid <= 1'b0;
                        aw_done     <= 1'b1;
                    end
                    if (axi_wvalid && axi_wready) begin
                        axi_wvalid <= 1'b0;
                        w_done     <= 1'b1;
                    end
                    // Transition once both channels have been accepted
                    if ((aw_done || (axi_awvalid && axi_awready)) &&
                        (w_done  || (axi_wvalid  && axi_wready))) begin
                        axi_bready <= 1'b1;
                        state      <= WR_WAIT_B;
                    end
                end

                // ---------------------------------------------------------
                WR_WAIT_B: begin
                    if (axi_bvalid && axi_bready) begin
                        axi_bready  <= 1'b0;
                        // Immediately read status after the write completes
                        axi_araddr  <= UART_STATUS_ADDR;
                        axi_arvalid <= 1'b1;
                        state       <= RD_AR;
                    end
                end

                // ---------------------------------------------------------
                RD_AR: begin
                    if (axi_arvalid && axi_arready) begin
                        axi_arvalid <= 1'b0;
                        axi_rready  <= 1'b1;
                        state       <= RD_WAIT_R;
                    end
                end

                // ---------------------------------------------------------
                RD_WAIT_R: begin
                    if (axi_rvalid && axi_rready) begin
                        tx_full_cached <= axi_rdata[3]; // TX_FULL bit
                        axi_rready     <= 1'b0;
                        state          <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    // ----------------------------------------------------------------
    // Xilinx AXI UARTLite IP instance
    // ----------------------------------------------------------------
    axi_uart u_axi_uart (
        .s_axi_aclk    (clk_i),
        .s_axi_aresetn (rstn_i),
        .interrupt     (),
        .s_axi_awaddr  (axi_awaddr),
        .s_axi_awvalid (axi_awvalid),
        .s_axi_awready (axi_awready),
        .s_axi_wdata   (axi_wdata),
        .s_axi_wstrb   (axi_wstrb),
        .s_axi_wvalid  (axi_wvalid),
        .s_axi_wready  (axi_wready),
        .s_axi_bresp   (axi_bresp),
        .s_axi_bvalid  (axi_bvalid),
        .s_axi_bready  (axi_bready),
        .s_axi_araddr  (axi_araddr),
        .s_axi_arvalid (axi_arvalid),
        .s_axi_arready (axi_arready),
        .s_axi_rdata   (axi_rdata),
        .s_axi_rresp   (axi_rresp),
        .s_axi_rvalid  (axi_rvalid),
        .s_axi_rready  (axi_rready),
        .rx            (uart_rx_i),
        .tx            (uart_tx_o)
    );

endmodule
