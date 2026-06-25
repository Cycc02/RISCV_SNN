`timescale 1ns / 1ps

module snn_pe_tb;

    logic        clk = 0;
    logic        rstn = 0;
    logic        pe_en   = 0;
    logic        spike_i = 0;
    logic        leak_en = 0;
    logic signed [31:0] threshold = 32'sd179;
    logic signed [7:0]  weight    = 8'sd0;
    logic signed [31:0] acc_i     = 32'sd0;

    wire         spike_o;
    wire         pcache_wr_o;
    wire  signed [31:0] acc_o;

    always #5 clk = ~clk;

    snn_pe #(.WEIGHT_WIDTH(8), .POTENTIAL_WIDTH(32)) dut (
        .clk_i      (clk),
        .rstn_i     (rstn),
        .pe_en_i    (pe_en),
        .spike_i    (spike_i),
        .leak_en_i  (leak_en),
        .threshold_i(threshold),
        .weight_i   (weight),
        .acc_i      (acc_i),
        .spike_o    (spike_o),
        .pcache_wr_o(pcache_wr_o),
        .acc_o      (acc_o)
    );

    // Drive inputs one cycle, latch on next posedge; #1 puts us past NBA region
    task pe_cycle(input logic spk, input logic signed [7:0] w,
                  input logic signed [31:0] a);
        @(posedge clk);
        pe_en   <= 1;
        spike_i <= spk;
        weight  <= w;
        acc_i   <= a;
        @(posedge clk);  // DUT registers inputs here
        pe_en <= 0;
        #1;              // past NBA, outputs now stable
    endtask

    initial begin
        $display("=== SNN_PE TB START ===");
        #15 rstn = 1;
        repeat(2) @(posedge clk);

        // ---- Test 1: 4 accumulations, spike on 4th ----
        $display("[TB] Test 1 - Accumulate spike=1 weight=50 threshold=179 (spike on 4th)");
        begin
            automatic logic signed [31:0] run_acc = 32'sd0;
            automatic int ok = 1;
            pe_cycle(1, 8'sd50, run_acc); run_acc = acc_o;   // 50
            pe_cycle(1, 8'sd50, run_acc); run_acc = acc_o;   // 100
            pe_cycle(1, 8'sd50, run_acc);                     // 150 — no spike yet
            if (spike_o) ok = 0;
            run_acc = acc_o;
            pe_cycle(1, 8'sd50, run_acc);                     // 200 — spike
            if (!spike_o || acc_o !== 32'sd200) ok = 0;
            if (ok) $display("[TB] Success - acc=%0d spike=%0b", acc_o, spike_o);
            else    $display("[TB] FAIL    - acc=%0d spike=%0b (expected acc=200 spike=1)", acc_o, spike_o);
        end
        repeat(2) @(posedge clk);

        // ---- Test 2: spike=0, weight ignored ----
        $display("[TB] Test 2 - spike=0, weight=100, acc stays 0");
        pe_cycle(0, 8'sd100, 32'sd0);
        if (acc_o === 32'sd0 && !spike_o)
            $display("[TB] Success - acc=%0d spike=%0b", acc_o, spike_o);
        else
            $display("[TB] FAIL    - acc=%0d spike=%0b (expected 0, 0)", acc_o, spike_o);
        repeat(2) @(posedge clk);

        // ---- Test 3: leakage ----
        $display("[TB] Test 3 - leak_en=1, acc=160 weight=20 (v_leaked=80 add_w=100)");
        leak_en = 1;
        pe_cycle(1, 8'sd20, 32'sd160);
        if (acc_o === 32'sd100 && !spike_o)
            $display("[TB] Success - acc=%0d spike=%0b", acc_o, spike_o);
        else
            $display("[TB] FAIL    - acc=%0d spike=%0b (expected 100, 0)", acc_o, spike_o);
        leak_en = 0;
        repeat(2) @(posedge clk);

        // ---- Test 4: negative weight ----
        $display("[TB] Test 4 - spike=1 weight=-30 acc=50 (add_w=20)");
        pe_cycle(1, -8'sd30, 32'sd50);
        if (acc_o === 32'sd20 && !spike_o)
            $display("[TB] Success - acc=%0d spike=%0b", acc_o, spike_o);
        else
            $display("[TB] FAIL    - acc=%0d spike=%0b (expected 20, 0)", acc_o, spike_o);
        repeat(2) @(posedge clk);

        // ---- Test 5: exactly at threshold ----
        $display("[TB] Test 5 - acc=129 weight=50 (129+50=179 == threshold, spike)");
        pe_cycle(1, 8'sd50, 32'sd129);
        if (acc_o === 32'sd179 && spike_o)
            $display("[TB] Success - acc=%0d spike=%0b", acc_o, spike_o);
        else
            $display("[TB] FAIL    - acc=%0d spike=%0b (expected 179, 1)", acc_o, spike_o);

        #20;
        $display("=== SNN_PE TB DONE ===");
        $finish;
    end

endmodule
