`timescale 1ns / 1ps

module snn_ctrl(
    input clk_i,
    input rstn_i,
    input snn_kick_i,

    // AER FIFO
    input        fifo_empty_i,
    input  [9:0] fifo_data_i,
    output reg   fifo_rd_en_o,

    // Weight RAM (Port A)
    output reg [12:0] ram_addr_o,
    output reg        ram_rd_en_o,

    // SIMD interface
    output            spike_o,
    output reg        pe_en_o,
    output reg  [2:0] stp_idx_o,

    // Layer control
    output reg        layer_sel_o,    // 0 = L1, 1 = L2
    input      [63:0] pe_spikes_out_i, // hidden_spike_o from snn_top

    // Evaluation sweep indicator (L1 post-scan threshold readout)
    output reg        eval_l1_o
);

    assign spike_o = 1'b1;

    // FSM states
    localparam IDLE    = 3'd0;
    localparam FETCH   = 3'd1; // Assert FIFO rd_en, wait for data
    localparam DEC     = 3'd2; // Latch FIFO data (L1) / scan spike buffer (L2)
    localparam EXEC    = 3'd3; // SIMD execution (L1: 8 groups, L2: 2 groups)
    localparam READOUT = 3'd4; // L2 complete -> IDLE
    localparam L2_INIT = 3'd5; // 2-cycle wait after eval: lets hidden_spike_o settle
    localparam EVAL_L1 = 3'd6; // Post-scan L1 threshold evaluation sweep (stp_idx 0..7+1)

    reg [2:0] state, next_state;

    reg  [9:0] spike_address;
    reg  [3:0] loop_count;
    reg [63:0] l1_spike_buffer;
    reg  [5:0] l1_spike_id;
    reg        layer_idx;     // 0=L1, 1=L2
    reg        l2_init_wait;  // 1 on first L2_INIT cycle, 0 on second
    reg  [3:0] eval_count;    // EVAL_L1 sweep counter (0..8)

    // -----------------------------------------------------------------------
    // Sequential
    // -----------------------------------------------------------------------
    always @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i || snn_kick_i) begin
            state         <= IDLE;
            spike_address <= 10'b0;
            loop_count    <= 4'd0;
            layer_idx     <= 1'b0;
            l1_spike_id   <= 6'd0;
            l1_spike_buffer <= 64'b0;
            l2_init_wait  <= 1'b0;
            eval_count    <= 4'd0;
        end else begin
            state <= next_state;

            // --- DEC ---
            if (state == DEC) begin
                if (layer_idx == 1'b0) begin
                    // L1: latch pixel address from FIFO output
                    spike_address <= fifo_data_i;
                end else begin
                    // L2: shift past zero bits in the spike buffer
                    if (l1_spike_buffer[0] == 1'b0 && l1_spike_buffer != 64'b0) begin
                        l1_spike_buffer <= l1_spike_buffer >> 1;
                        l1_spike_id     <= l1_spike_id + 1;
                    end
                end
            end

            // --- EXEC loop counter & L2 buffer shift ---
            if (state == EXEC) begin
                loop_count <= loop_count + 1;
                // After each L2 spike pair, advance to next set bit
                if (layer_idx == 1'b1 && loop_count == 4'd1) begin
                    l1_spike_buffer <= l1_spike_buffer >> 1;
                    l1_spike_id     <= l1_spike_id + 1;
                end
            end else begin
                loop_count <= 4'd0;
            end

            // --- EVAL_L1 sweep counter ---
            if (state == EVAL_L1) begin
                eval_count <= eval_count + 1;
            end else begin
                eval_count <= 4'd0;
            end

            // --- Trigger L2_INIT at end of EVAL_L1 sweep ---
            // eval_count=8: last pe_en pulse (stp_idx=7 repeat), then go to L2_INIT
            if (state == EVAL_L1 && eval_count == 4'd8) begin
                l2_init_wait <= 1'b1;
            end

            // --- L2_INIT: 2-cycle settle ---
            // Cycle 1 (l2_init_wait=1): just wait, clear flag
            // Cycle 2 (l2_init_wait=0): latch hidden_spike_o and switch layer
            if (state == L2_INIT) begin
                if (!l2_init_wait) begin
                    // hidden_spike_o is now fully updated (pe_en_dly fired last cycle)
                    l1_spike_buffer <= pe_spikes_out_i;
                    l1_spike_id     <= 6'd0;
                    layer_idx       <= 1'b1;
                end
                l2_init_wait <= 1'b0;
            end

            // --- READOUT (L2 done): reset layer ---
            if (state == READOUT) begin
                layer_idx <= 1'b0;
            end
        end
    end

    // -----------------------------------------------------------------------
    // Combinational
    // -----------------------------------------------------------------------
    always @(*) begin
        next_state   = state;
        fifo_rd_en_o = 1'b0;
        ram_addr_o   = 13'b0;
        ram_rd_en_o  = 1'b0;
        pe_en_o      = 1'b0;
        stp_idx_o    = 3'd0;
        layer_sel_o  = layer_idx;
        eval_l1_o    = 1'b0;

        case (state)

        IDLE: begin
            if (!fifo_empty_i) begin
                fifo_rd_en_o = 1'b1;
                next_state   = FETCH;
            end
        end

        FETCH: begin
            next_state = DEC;
        end

        DEC: begin
            if (layer_idx == 1'b0) begin
                // L1: one-cycle delay for FIFO data, then execute
                next_state = EXEC;
            end else begin
                // L2: scan buffer for next set bit
                if (l1_spike_buffer == 64'b0)
                    next_state = READOUT;
                else if (l1_spike_buffer[0] == 1'b1)
                    next_state = EXEC;
                else
                    next_state = DEC; // sequential block shifts this cycle
            end
        end

        EXEC: begin
            ram_rd_en_o = 1'b1;

            if (layer_idx == 1'b0) begin
                // --- L1: 8 SIMD groups per input pixel ---
                // RAM fetch: loop_count 0..7 (1-cycle latency -> data at loop_count 1..8)
                if (loop_count < 4'd8)
                    ram_addr_o = {spike_address, loop_count[2:0]};

                // pe_en on loop_count 1..8 (data ready 1 cycle after fetch)
                if (loop_count > 4'd0 && loop_count <= 4'd8) begin
                    pe_en_o   = 1'b1;
                    stp_idx_o = loop_count[2:0] - 1'b1;
                end

                if (loop_count == 4'd8) begin
                    if (!fifo_empty_i) begin
                        fifo_rd_en_o = 1'b1;
                        next_state   = FETCH;   // more pixels to process
                    end else begin
                        next_state = EVAL_L1;   // all pixels done, evaluate L1 thresholds
                    end
                end

            end else begin
                // --- L2: 2 SIMD groups per active hidden spike ---
                // Word layout: base 6272, 2 words per spike (group 0: outputs 0-7, group 1: outputs 8-9)
                if (loop_count < 4'd2)
                    ram_addr_o = 13'd6272 + {l1_spike_id, 1'b0} + loop_count[0];

                if (loop_count > 4'd0 && loop_count <= 4'd2) begin
                    pe_en_o   = 1'b1;
                    stp_idx_o = loop_count[2:0] - 1'b1;
                end

                if (loop_count == 4'd2)
                    next_state = DEC; // find next set bit
            end
        end

        EVAL_L1: begin
            // Post-scan L1 evaluation: sweep stp_idx 0..7 with pe_en=1, spike forced to
            // 0 in snn_top so add_w = scratchpad[k]. spike_o registers the final
            // threshold comparison one cycle later.
            // eval_count 0..7: pe_en pulses for groups 0-7.
            // eval_count 8:    extra pe_en on stp_idx=7 ensures pe_en_dly=1 at
            //                  L2_INIT cycle 1, blocking premature done_inference.
            eval_l1_o = 1'b1;
            pe_en_o   = 1'b1;
            stp_idx_o = (eval_count == 4'd8) ? 3'd7 : eval_count[2:0];
            if (eval_count == 4'd8)
                next_state = L2_INIT;
        end

        L2_INIT: begin
            // Stay for 2 cycles: first cycle (l2_init_wait=1) waits, second cycle
            // (l2_init_wait=0) latches hidden_spike_o and switches to L2.
            if (!l2_init_wait)
                next_state = DEC;
            else
                next_state = L2_INIT;
        end

        READOUT: begin
            next_state = IDLE;
        end

        default: next_state = IDLE;
        endcase
    end

endmodule
