`timescale 1ns / 1ps

module snn_top #(
    parameter WEIGHT_WIDTH    = 8,
    parameter TIMESTEP_WIDTH  = 8
)(
    input clk_i,
    input rstn_i,

    input  [TIMESTEP_WIDTH-1:0] timestep_i,
    
    input snn_kick_i,
    input [11:0] img_base_i,

    output reg [63:0] hidden_spike_o,   // accumulated L1 spikes
    output reg  [9:0] output_spike_o,   // accumulated L2 spikes (classification)
    output            done_layer1_o,
    output            done_layer2_o,
    output            done_learn_o,
    
    output            dtcm_rd_en_o,
    output [11:0]     dtcm_addr_o,
    input  [31:0]     dtcm_data_i
);
    //THRESHOLD
    localparam signed [31:0] THRESH_L1 = 32'sd179;
    localparam signed [31:0] THRESH_L2 = 32'sd17;

    // ------------------------------------------------------------------
    // AER Scanner <-> AER FIFO
    // ------------------------------------------------------------------
    wire        fifo_full;
    wire  [9:0] aer_data;
    wire        fifo_wr_en;
    wire        scan_done;

    // ------------------------------------------------------------------
    // AER FIFO <-> Control Unit
    // ------------------------------------------------------------------
    wire        fifo_rd_en;
    wire        fifo_empty;
    wire  [9:0] fifo_dout;

    // ------------------------------------------------------------------
    // Control Unit outputs
    // ------------------------------------------------------------------
    wire [12:0] ram_addr;
    wire        ram_rd_en;
    wire        spike;
    wire        pe_en;
    wire  [2:0] stp_idx;
    wire        layer_sel;   // 0=L1, 1=L2

    // ------------------------------------------------------------------
    // Dual Port RAM <-> Learning Unit
    // ------------------------------------------------------------------
    wire        lr_ram_rd_en;
    wire        lr_ram_wr_en;
    wire [63:0] lr_ram_din;
    wire [63:0] lr_ram_dout;
    wire [12:0] lr_ram_addr;

    // ------------------------------------------------------------------
    // SIMD outputs
    // ------------------------------------------------------------------
    wire [63:0] ram_dout;
    wire  [7:0] spike_out;

    // ------------------------------------------------------------------
    // Learning Unit
    // ------------------------------------------------------------------
    wire lr_done;
    wire lr_en;

    // ------------------------------------------------------------------
    // Spike-time memories
    // ------------------------------------------------------------------
    wire  [9:0]              t_pre_addr;
    wire  [TIMESTEP_WIDTH-1:0] t_pre_data;
    wire  [2:0]              t_post_addr;
    wire [63:0]              t_post_data;

    // ------------------------------------------------------------------
    // Layer transition tracking
    // ------------------------------------------------------------------
    reg  pe_en_dly;
    reg  [2:0] stp_idx_dly;
    reg  layer_sel_prev;
    wire layer_transition;   // rising edge of layer_sel: L1->L2

    // eval_l1: high throughout EVAL_L1 state; delayed one cycle for latch gating
    wire eval_l1;
    reg  eval_l1_dly;
    
    // ------------------------------------------------------------------
    //SNN Interface
    // ------------------------------------------------------------------
    wire        chunk_req;
    wire [4:0]  scan_chunk_num;

    // DTCM port-B has 1-cycle read latency. aer_scan must not latch its
    // chunk_reg in the same cycle it asserts chunk_req (it would grab the
    // previous cycle's port-B output). Delay chunk_req by one cycle and
    // feed that as chunk_valid_i so the latch lines up with valid data.
    // Without this, port-B contention with the CPU during the poll loop
    // makes aer_scan see all-zero chunks and the SNN stalls in IDLE.
    reg chunk_req_d;
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) chunk_req_d <= 1'b0;
        else         chunk_req_d <= chunk_req;
    end

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            pe_en_dly      <= 1'b0;
            stp_idx_dly    <= 3'b0;
            layer_sel_prev <= 1'b0;
            eval_l1_dly    <= 1'b0;
        end else begin
            pe_en_dly      <= pe_en;
            stp_idx_dly    <= stp_idx;
            layer_sel_prev <= layer_sel;
            eval_l1_dly    <= eval_l1;
        end
    end

    assign layer_transition = layer_sel & ~layer_sel_prev;

    // ------------------------------------------------------------------
    // done_inference: all L1 processing complete
    // Guard with !layer_sel to prevent re-fire during L2 DEC idle cycles
    // ------------------------------------------------------------------
    reg  scan_done_sticky;
    wire done_inference;

    assign done_inference = scan_done_sticky & fifo_empty
                          & ~pe_en & ~pe_en_dly & ~fifo_rd_en
                          & ~layer_sel;

    assign done_layer1_o = done_inference;

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            scan_done_sticky <= 1'b0;
        end else if (snn_kick_i || done_inference) begin
            scan_done_sticky <= 1'b0;
        end else if (scan_done) begin
            scan_done_sticky <= 1'b1;
        end
    end

    // done_layer2: falling edge of layer_sel (READOUT->IDLE in ctrl)
    assign done_layer2_o = layer_sel_prev & ~layer_sel;
    
    // ------------------------------------------------------------------
    //SNN Assignment
    // ------------------------------------------------------------------
    assign dtcm_rd_en_o = chunk_req;
    assign dtcm_addr_o = img_base_i + {7'b0, scan_chunk_num};

    // ------------------------------------------------------------------
    // STDP / learning
    // ------------------------------------------------------------------
    reg start_stdp;
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) start_stdp <= 1'b0;
        else         start_stdp <= done_inference;
    end
    assign done_learn_o = start_stdp;
    assign lr_en        = 1'b0;

    // ------------------------------------------------------------------
    // Submodules
    // ------------------------------------------------------------------
    aer_scan scan_mod(
        .clk_i       (clk_i),
        .rstn_i      (rstn_i),
        .snn_kick_i  (snn_kick_i),
        .chunk_i     (dtcm_data_i),
        .chunk_valid_i (chunk_req_d),
        .fifo_full_i (fifo_full),
        .aer_data_o  (aer_data),
        .aer_valid_o (fifo_wr_en),
        .scan_done_o (scan_done),
        .chunk_req_o (chunk_req),
        .chunk_num_o (scan_chunk_num)
    );

    aer_fifo #(
        .DATA_WIDTH(10),
        .DEPTH(64)
    ) fifo_mod (
        .clk_i       (clk_i),
        .rstn_i      (rstn_i),
        .flush_i     (snn_kick_i),
        .aer_data_i  (aer_data),
        .rd_en_i     (fifo_rd_en),
        .wr_en_i     (fifo_wr_en),
        .fifo_full_o (fifo_full),
        .fifo_empty_o(fifo_empty),
        .aer_data_o  (fifo_dout)
    );

    // During EVAL_L1, spike is forced to 0 so add_w = scratchpad[k] (no weight
    // added), giving a clean threshold comparison on the final accumulated sum.
    wire spike_to_simd = eval_l1 ? 1'b0 : spike;

    snn_ctrl ctrl_unit(
        .clk_i          (clk_i),
        .rstn_i         (rstn_i),
        .snn_kick_i     (snn_kick_i),
        .fifo_empty_i   (fifo_empty),
        .fifo_data_i    (fifo_dout),
        .fifo_rd_en_o   (fifo_rd_en),
        .ram_addr_o     (ram_addr),
        .ram_rd_en_o    (ram_rd_en),
        .spike_o        (spike),
        .pe_en_o        (pe_en),
        .stp_idx_o      (stp_idx),
        .layer_sel_o    (layer_sel),
        .pe_spikes_out_i(hidden_spike_o),  // latched by ctrl in L2_INIT cycle 2
        .eval_l1_o      (eval_l1)
    );

    learning_unit #(
        .WEIGHT_WIDTH (WEIGHT_WIDTH),
        .TIMESTEP_WIDTH(TIMESTEP_WIDTH),
        .ALPHA_SHIFT  (3),
        .TIME_WINDOW  (8),
        .BRAM_DEPTH   (6272),
        .ADDR_WIDTH   (13)
    ) lu1 (
        .clk_i        (clk_i),
        .rstn_i       (rstn_i),
        .lr_en_i      (lr_en),
        .lr_done_o    (lr_done),
        .ram_addr_o   (lr_ram_addr),
        .ram_rd_en_o  (lr_ram_rd_en),
        .ram_wr_en_o  (lr_ram_wr_en),
        .ram_weight_i (lr_ram_din),
        .ram_weight_o (lr_ram_dout),
        .t_pre_addr_o (t_pre_addr),
        .t_pre_data_i (t_pre_data),
        .t_post_addr_o(t_post_addr),
        .t_post_data_i(t_post_data)
    );

    spike_time_mem #(
        .DEPTH         (784),
        .TIMESTEP_WIDTH(8),
        .ADDR_WIDTH    (10)
    ) pre_time (
        .clk      (clk_i),
        .rd_en    (1'b1),
        .rd_addr  (t_pre_addr),
        .rd_tstep (t_pre_data),
        .wr_en    (fifo_wr_en),
        .wr_addr  (aer_data),
        .wr_tstep (timestep_i)
    );

    dual_port_RAM #(
        .DATA_WIDTH(64),
        .DEPTH     (6400),
        .ADDR_WIDTH(13)
    ) weight_ram (
        .clk     (clk_i),
        .rd_en_a (ram_rd_en),
        .addr_a  (ram_addr),
        .dout_a  (ram_dout),
        .rd_en_b (lr_ram_rd_en),
        .wr_en_b (lr_ram_wr_en),
        .din_b   (lr_ram_dout),
        .addr_b  (lr_ram_addr),
        .dout_b  (lr_ram_din)
    );

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : pos_timestep_mem
            wire       lane_spike       = spike_out[i];
            wire [7:0] lane_t_post_out;

            spike_time_mem #(
                .DEPTH         (8),
                .TIMESTEP_WIDTH(8),
                .ADDR_WIDTH    (3)
            ) pos_time (
                .clk      (clk_i),
                .rd_en    (1'b1),
                .rd_addr  (t_post_addr),
                .rd_tstep (lane_t_post_out),
                .wr_en    (pe_en && lane_spike),
                .wr_addr  (stp_idx),
                .wr_tstep (timestep_i)
            );

            assign t_post_data[(i*8) +: 8] = lane_t_post_out;
        end
    endgenerate

    // l2_en_i: one-cycle pulse at layer transition to reset SIMD scratchpads
    simd_8 #(
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .LANE_COUNT  (8),
        .POT_WIDTH   (32)
    ) simd_mod (
        .clk_i    (clk_i),
        .rstn_i   (rstn_i),
        .pe_en_i  (pe_en),
        .snn_en_i (snn_kick_i),
        .l2_en_i  (layer_transition),
        .spike_i  (spike_to_simd),
        .stp_idx_i(stp_idx),
        .weight_i (ram_dout),
        .spike_o  (spike_out),
        .layer_sel_i (layer_sel),
        .thresh_L1_i (THRESH_L1),
        .thresh_L2_i (THRESH_L2)
    );

    // ------------------------------------------------------------------
    // L1 hidden spike evaluation (post-scan, not during scanning).
    // EVAL_L1 state sweeps stp_idx 0..7 with spike forced to 0, so
    // spike_out[i] = (scratchpad[k] >= THRESH_L1) on the COMPLETE sum.
    // Latch one cycle after pe_en (spike_o is registered in snn_pe).
    // ------------------------------------------------------------------
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            hidden_spike_o <= 64'd0;
        end else if (snn_kick_i) begin
            hidden_spike_o <= 64'd0;
        end else if (pe_en_dly && eval_l1_dly) begin
            // Overwrite: definitive threshold comparison after full image accumulation
            hidden_spike_o[(stp_idx_dly*8) +: 8] <= spike_out;
        end
    end

    // ------------------------------------------------------------------
    // L2 output spike accumulation (10 output neurons)
    // stp_idx_dly=0 -> neurons 0-7 (spike_out[7:0])
    // stp_idx_dly=1 -> neurons 8-9 (spike_out[1:0])
    // ------------------------------------------------------------------
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            output_spike_o <= 10'd0;
        end else if(snn_kick_i)begin
            output_spike_o <= 10'd0;
        end else if (pe_en_dly && layer_sel_prev) begin
            if (stp_idx_dly == 3'd0)
                output_spike_o[7:0] <= spike_out[7:0];   // overwrite — no OR
            else if (stp_idx_dly == 3'd1)
                output_spike_o[9:8] <= spike_out[1:0];   // overwrite — no OR
        end
    end

endmodule
