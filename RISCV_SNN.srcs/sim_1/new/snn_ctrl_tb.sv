`timescale 1ns / 1ps

module snn_ctrl_tb;

    logic        clk = 0;
    logic        rstn = 0;
    logic        fifo_empty = 1;
    logic [9:0]  fifo_data  = 0;
    wire         fifo_rd_en;
    wire [12:0]  ram_addr;
    wire         ram_rd_en;
    wire         spike_o;
    wire         pe_en;
    wire [2:0]   stp_idx;
    wire         layer_sel;
    wire         eval_l1;

    always #5 clk = ~clk;

    snn_ctrl dut (
        .clk_i           (clk),
        .rstn_i          (rstn),
        .fifo_empty_i    (fifo_empty),
        .fifo_data_i     (fifo_data),
        .fifo_rd_en_o    (fifo_rd_en),
        .ram_addr_o      (ram_addr),
        .ram_rd_en_o     (ram_rd_en),
        .spike_o         (spike_o),
        .pe_en_o         (pe_en),
        .stp_idx_o       (stp_idx),
        .layer_sel_o     (layer_sel),
        .pe_spikes_out_i (64'd0),
        .eval_l1_o       (eval_l1)
    );

    // Push one spike address into the FIFO interface and wait for
    // snn_ctrl to read it (fifo_rd_en asserted).
    task push_spike(input logic [9:0] addr);
        fifo_data  <= addr;
        fifo_empty <= 0;
        @(posedge fifo_rd_en);
        @(posedge clk);
        fifo_empty <= 1;
    endtask

    // Collect RAM addresses and stp_idx values during one EXEC sweep (8 groups).
    task automatic collect_l1_exec(
        output logic [12:0] addrs [0:7],
        output logic [2:0]  stps  [0:7]
    );
        automatic int ai = 0, si = 0;
        // Wait up to 40 cycles for all 8 captures
        repeat(40) begin
            @(posedge clk);
            if (ram_rd_en && ai < 8) addrs[ai++] = ram_addr;
            if (pe_en     && si < 8) stps [si++] = stp_idx;
        end
    endtask

    int ok;

    initial begin
        $display("=== SNN_CTRL TB START ===");
        #20 rstn = 1;
        repeat(2) @(posedge clk);

        // ---- Test 1: single L1 pixel — check RAM addresses and stp_idx sequence ----
        $display("[TB] Test 1 - Single L1 pixel addr=42, expect RAM 42*8..42*8+7, stp 0..7");
        begin
            automatic logic [12:0] addrs [0:7];
            automatic logic [2:0]  stps  [0:7];
            ok = 1;
            fork
                push_spike(10'd42);
                collect_l1_exec(addrs, stps);
            join
            for (int i = 0; i < 8; i++) begin
                if (addrs[i] !== {10'd42, i[2:0]}) ok = 0;
                if (stps [i] !== i[2:0])           ok = 0;
            end
            if (ok)
                $display("[TB] Success - RAM addrs 336..343, stp_idx 0..7 correct");
            else begin
                $display("[TB] FAIL    - mismatch:");
                for (int i = 0; i < 8; i++)
                    $display("          [%0d] ram_addr=%0d (exp %0d)  stp_idx=%0d (exp %0d)",
                             i, addrs[i], {10'd42, i[2:0]}, stps[i], i[2:0]);
            end
        end
        repeat(30) @(posedge clk);  // let EVAL_L1 + L2_INIT pass

        // ---- Test 2: pixel addr=0, RAM addresses 0..7 ----
        $display("[TB] Test 2 - Pixel addr=0, expect RAM 0..7");
        begin
            automatic logic [12:0] addrs [0:7];
            automatic logic [2:0]  stps  [0:7];
            ok = 1;
            fork
                push_spike(10'd0);
                collect_l1_exec(addrs, stps);
            join
            for (int i = 0; i < 8; i++)
                if (addrs[i] !== i[12:0]) ok = 0;
            if (ok)
                $display("[TB] Success - RAM addrs 0..7 correct");
            else begin
                $display("[TB] FAIL    - mismatch:");
                for (int i = 0; i < 8; i++)
                    $display("          [%0d] ram_addr=%0d (exp %0d)", i, addrs[i], i);
            end
        end
        repeat(30) @(posedge clk);

        // ---- Test 3: pixel addr=783 (last pixel), RAM 6264..6271 ----
        $display("[TB] Test 3 - Pixel addr=783, expect RAM 6264..6271");
        begin
            automatic logic [12:0] addrs [0:7];
            automatic logic [2:0]  stps  [0:7];
            ok = 1;
            fork
                push_spike(10'd783);
                collect_l1_exec(addrs, stps);
            join
            for (int i = 0; i < 8; i++)
                if (addrs[i] !== {10'd783, i[2:0]}) ok = 0;
            if (ok)
                $display("[TB] Success - RAM addrs 6264..6271 correct");
            else begin
                $display("[TB] FAIL    - mismatch:");
                for (int i = 0; i < 8; i++)
                    $display("          [%0d] ram_addr=%0d (exp %0d)", i, addrs[i], {10'd783, i[2:0]});
            end
        end
        repeat(30) @(posedge clk);

        // ---- Test 4: two consecutive pixels, processed sequentially ----
        $display("[TB] Test 4 - Two pixels (10 then 20), both processed in sequence");
        begin
            automatic logic [12:0] a0 [0:7], a1 [0:7];
            automatic logic [2:0]  s0 [0:7], s1 [0:7];
            ok = 1;
            // Pixel 10: push then immediately collect
            fork
                push_spike(10'd10);
                collect_l1_exec(a0, s0);
            join
            // Wait for EVAL_L1 + L2_INIT + L2 pass-through to finish
            repeat(30) @(posedge clk);
            // Pixel 20: push then immediately collect
            fork
                push_spike(10'd20);
                collect_l1_exec(a1, s1);
            join
            repeat(30) @(posedge clk);
            for (int i = 0; i < 8; i++) begin
                if (a0[i] !== {10'd10, i[2:0]}) ok = 0;
                if (a1[i] !== {10'd20, i[2:0]}) ok = 0;
            end
            if (ok)
                $display("[TB] Success - Both pixels produced correct RAM sequences");
            else begin
                $display("[TB] FAIL    - Pixel pair mismatch:");
                for (int i = 0; i < 8; i++)
                    $display("  px10[%0d] ram=%0d(exp %0d)  px20[%0d] ram=%0d(exp %0d)",
                             i, a0[i], {10'd10,i[2:0]}, i, a1[i], {10'd20,i[2:0]});
            end
        end
        repeat(30) @(posedge clk);

        $display("=== SNN_CTRL TB DONE ===");
        $finish;
    end

endmodule
