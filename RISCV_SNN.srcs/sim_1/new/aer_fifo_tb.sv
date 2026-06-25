`timescale 1ns / 1ps

module aer_fifo_tb;

    logic        clk  = 0;
    logic        rstn = 0;
    logic [9:0]  aer_data_i;
    logic        wr_en = 0;
    logic        rd_en = 0;
    wire  [9:0]  aer_data_o;
    wire         full, empty;

    always #5 clk = ~clk;

    aer_fifo #(.DATA_WIDTH(10), .DEPTH(64)) dut (
        .clk_i       (clk),
        .rstn_i      (rstn),
        .aer_data_i  (aer_data_i),
        .wr_en_i     (wr_en),
        .rd_en_i     (rd_en),
        .fifo_full_o (full),
        .fifo_empty_o(empty),
        .aer_data_o  (aer_data_o)
    );

    localparam int PIXELS [0:5] = '{0, 42, 100, 255, 512, 783};

    // Capture aer_data_o on negedge (after posedge NBA has settled)
    logic [9:0] read_values [0:5];
    int         capture_idx = 0;
    logic       capturing   = 0;

    always @(negedge clk) begin
        if (capturing && capture_idx < 6)
            read_values[capture_idx++] = aer_data_o;
    end

    initial begin
        $display("=== AER_FIFO TB START ===");
        aer_data_i = 0;
        #20 rstn = 1;
        repeat(2) @(posedge clk);

        // ---- Write 6 pixel addresses ----
        $display("[TB] Writing 6 pixel addresses to FIFO...");
        foreach (PIXELS[i]) begin
            @(posedge clk);
            aer_data_i <= PIXELS[i];
            wr_en      <= 1;
        end
        @(posedge clk); wr_en <= 0;
        repeat(2) @(posedge clk);

        if (dut.count == 6)
            $display("[TB] Success - 6 entries written  (count=%0d)", dut.count);
        else
            $display("[TB] FAIL    - expected count=6, got %0d", dut.count);

        // ---- Read back 6 entries ----
        // rd_en goes high at posedge N  (NBA: rd_en=1 visible at posedge N+1)
        // FIFO reads rp=0 at posedge N+1 → aer_data_o = PIXELS[0] after NBA of N+1
        // → first valid data available at negedge N+1
        // Start capturing AFTER the first posedge where FIFO reads (i.e. after posedge N+1)
        $display("[TB] Reading back from FIFO...");
        @(posedge clk); rd_en <= 1;   // posedge N
        @(posedge clk);                // posedge N+1: FIFO reads rp=0
        capturing = 1;                 // enable capture starting at negedge N+1
        repeat(5) @(posedge clk);     // posedge N+2..N+6: FIFO reads rp=1..5
        rd_en     <= 0;
        capturing  = 0;
        repeat(2) @(posedge clk);

        begin
            automatic int ok = 1;
            for (int i = 0; i < 6; i++)
                if (read_values[i] != PIXELS[i]) ok = 0;
            if (ok && dut.count == 0)
                $display("[TB] Success - All 6 entries read in correct order  (count=%0d)", dut.count);
            else begin
                $display("[TB] FAIL    - Read mismatch (count=%0d)", dut.count);
                for (int i = 0; i < 6; i++)
                    $display("          read[%0d]=%0d  expected=%0d", i, read_values[i], PIXELS[i]);
            end
        end

        // ---- Fill FIFO to capacity (64 entries) ----
        $display("[TB] Filling FIFO to full capacity (64 entries)...");
        for (int i = 0; i < 64; i++) begin
            @(posedge clk);
            aer_data_i <= i[9:0];
            wr_en      <= 1;
        end
        @(posedge clk); wr_en <= 0;
        repeat(2) @(posedge clk);

        if (full && dut.count == 64)
            $display("[TB] Success - FIFO full  (count=%0d, full=%0b)", dut.count, full);
        else
            $display("[TB] FAIL    - Expected full, got count=%0d full=%0b", dut.count, full);

        // ---- Write 1 extra to full FIFO (should be dropped) ----
        $display("[TB] Writing 1 extra entry to full FIFO (should be dropped)...");
        @(posedge clk); aer_data_i <= 10'd999; wr_en <= 1;
        @(posedge clk); wr_en <= 0;
        repeat(2) @(posedge clk);

        if (dut.count == 64)
            $display("[TB] Success - Extra write dropped, count unchanged  (count=%0d)", dut.count);
        else
            $display("[TB] FAIL    - Count changed to %0d", dut.count);

        #20;
        $display("=== AER_FIFO TB DONE ===");
        $finish;
    end

endmodule
