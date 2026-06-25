`timescale 1ns / 1ps

module aer_scan_tb_new;

    logic        clk  = 0;
    logic        rstn = 0;
    logic        snn_kick = 0;
    logic        fifo_full = 0;

    wire         chunk_req;
    wire  [4:0]  chunk_num;
    wire  [9:0]  aer_data;
    wire         aer_valid;
    wire         scan_done;

    logic [31:0] dtcm [0:24];
    wire  [31:0] chunk_data = dtcm[chunk_num];  // combinatorial DTCM

    always #5 clk = ~clk;

    aer_scan dut (
        .clk_i         (clk),
        .rstn_i        (rstn),
        .snn_kick_i    (snn_kick),
        .chunk_i       (chunk_data),
        .chunk_valid_i (chunk_req),
        .fifo_full_i   (fifo_full),
        .aer_data_o    (aer_data),
        .aer_valid_o   (aer_valid),
        .scan_done_o   (scan_done),
        .chunk_req_o   (chunk_req),
        .chunk_num_o   (chunk_num)
    );

    // Spike collector — one spike per aer_valid posedge (address changes each cycle normally)
    int spike_count;
    int spike_ids [0:783];
    always @(posedge clk) begin
        if (aer_valid) begin
            if (spike_count < 784) spike_ids[spike_count] = aer_data;
            spike_count++;
        end
    end

    // Run one image, return spike count
    task automatic run_image(output int cnt);
        spike_count = 0;
        @(posedge clk); snn_kick <= 1;
        @(posedge clk); snn_kick <= 0;
        fork
            @(posedge scan_done);
            begin repeat(3000) @(posedge clk); end
        join_any
        disable fork;
        repeat(3) @(posedge clk);
        cnt = spike_count;
    endtask

    int got;

    initial begin
        $display("=== AER_SCAN TB START ===");
        foreach (dtcm[i]) dtcm[i] = 32'h0;
        #20 rstn = 1;
        repeat(2) @(posedge clk);

        // ---- Test 1: pixels 0,1,2 (chunk 0 bits [2:0]) ----
        $display("[TB] Test 1 - 3 pixels: 0, 1, 2");
        foreach (dtcm[i]) dtcm[i] = 32'h0;
        dtcm[0] = 32'h0000_0007;
        run_image(got);
        if (got == 3 && spike_ids[0] == 0 && spike_ids[1] == 1 && spike_ids[2] == 2)
            $display("[TB] Success - %0d spikes: 0, 1, 2", got);
        else begin
            $display("[TB] FAIL    - got %0d spikes", got);
            for (int i = 0; i < got && i < 10; i++)
                $display("          spike[%0d]=%0d", i, spike_ids[i]);
        end

        // ---- Test 2: pixel 100 (chunk 3, bit 4) ----
        $display("[TB] Test 2 - 1 pixel: 100");
        foreach (dtcm[i]) dtcm[i] = 32'h0;
        dtcm[3] = 32'h0000_0010;   // 3*32+4 = 100
        run_image(got);
        if (got == 1 && spike_ids[0] == 100)
            $display("[TB] Success - 1 spike: pixel 100");
        else
            $display("[TB] FAIL    - got %0d spikes, first=%0d (expected 1, 100)", got, spike_ids[0]);

        // ---- Test 3: pixel 783 (chunk 24, bit 15) ----
        $display("[TB] Test 3 - 1 pixel: 783 (last pixel)");
        foreach (dtcm[i]) dtcm[i] = 32'h0;
        dtcm[24] = 32'h0000_8000;  // 24*32+15 = 783
        run_image(got);
        if (got == 1 && spike_ids[0] == 783)
            $display("[TB] Success - 1 spike: pixel 783");
        else
            $display("[TB] FAIL    - got %0d spikes, first=%0d (expected 1, 783)", got, spike_ids[0]);

        // ---- Test 4: blank image ----
        $display("[TB] Test 4 - blank image (no spikes)");
        foreach (dtcm[i]) dtcm[i] = 32'h0;
        run_image(got);
        if (got == 0)
            $display("[TB] Success - 0 spikes (blank)");
        else
            $display("[TB] FAIL    - got %0d spikes (expected 0)", got);

        // ---- Test 5: FIFO-full stall (verify scan completes despite backpressure) ----
        $display("[TB] Test 5 - FIFO-full stall (pixels 0,1,2,3) — verify scan_done fires");
        foreach (dtcm[i]) dtcm[i] = 32'h0;
        dtcm[0] = 32'h0000_000F;
        @(posedge clk); snn_kick <= 1;
        @(posedge clk); snn_kick <= 0;
        repeat(5) @(posedge clk);
        fifo_full <= 1;
        repeat(10) @(posedge clk);
        fifo_full <= 0;
        begin
            automatic logic done_seen = 0;
            fork
                begin @(posedge scan_done); done_seen = 1; end
                begin repeat(3000) @(posedge clk); end
            join_any
            disable fork;
            repeat(3) @(posedge clk);
            if (done_seen)
                $display("[TB] Success - FIFO stall resolved, scan_done asserted");
            else
                $display("[TB] FAIL    - scan_done never fired (scan hung)");
        end

        $display("=== AER_SCAN TB DONE ===");
        $finish;
    end

endmodule
