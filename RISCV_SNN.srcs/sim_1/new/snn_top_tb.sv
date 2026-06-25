`timescale 1ns / 1ps

// ============================================================
// Multi-inference testbench for snn_top
//
// VERBOSE = 1 : full per-cycle trace (use for single-image debug)
// VERBOSE = 0 : summary only — L1/L2 pass/fail per inference
// ============================================================
module snn_top_tb;

    localparam int VERBOSE   = 0;   // set to 1 for step-by-step trace
    localparam int THRESHOLD_L1 = 179;  // must match snn_top THRESHOLD
    localparam int THRESHOLD_L2 = 17; 
    
    // ----------------------------------------------------------------
    //  Test images  (bit[p]=1 -> pixel p active, 28x28 = 784 pixels)
    // ----------------------------------------------------------------
    localparam bit [783:0] IMG0 = 784'b1;                       // pixel 0 only
    localparam bit [783:0] IMG1 = (784'b1 << 783);              // pixel 783 only
    localparam bit [783:0] IMG2 = 784'b11;                      // pixels 0+1
    localparam bit [783:0] IMG3 = (784'b0                       // sparse 5 pixels
        | (784'b1 << 0) | (784'b1 << 1) | (784'b1 << 2)
        | (784'b1 << 100) | (784'b1 << 200));
    localparam bit [783:0] IMG4 = 784'hFFFFFFF;                 // top row  (pixels 0-27)
    localparam bit [783:0] IMG5 = (784'b0                       // bottom row (pixels 756-783)
        | (784'b1 << 756) | (784'b1 << 757) | (784'b1 << 758)
        | (784'b1 << 759) | (784'b1 << 760) | (784'b1 << 761)
        | (784'b1 << 762) | (784'b1 << 763) | (784'b1 << 764)
        | (784'b1 << 765) | (784'b1 << 766) | (784'b1 << 767)
        | (784'b1 << 768) | (784'b1 << 769) | (784'b1 << 770)
        | (784'b1 << 771) | (784'b1 << 772) | (784'b1 << 773)
        | (784'b1 << 774) | (784'b1 << 775) | (784'b1 << 776)
        | (784'b1 << 777) | (784'b1 << 778) | (784'b1 << 779)
        | (784'b1 << 780) | (784'b1 << 781) | (784'b1 << 782)
        | (784'b1 << 783));
    localparam bit [783:0] IMG6 = {{392{1'b0}}, {392{1'b1}}};  // top half (pixels 0-391)
    localparam bit [783:0] IMG7 = '1;                           // ALL 784 pixels
    localparam bit [783:0] IMG8 = (784'b0                       // stride-7 (~112 pixels)
        | (784'b1 <<   0) | (784'b1 <<   7) | (784'b1 <<  14)
        | (784'b1 <<  21) | (784'b1 <<  28) | (784'b1 <<  35)
        | (784'b1 <<  42) | (784'b1 <<  49) | (784'b1 <<  56)
        | (784'b1 <<  63) | (784'b1 <<  70) | (784'b1 <<  77)
        | (784'b1 <<  84) | (784'b1 <<  91) | (784'b1 <<  98)
        | (784'b1 << 105) | (784'b1 << 112) | (784'b1 << 119)
        | (784'b1 << 126) | (784'b1 << 133) | (784'b1 << 140)
        | (784'b1 << 147) | (784'b1 << 154) | (784'b1 << 161)
        | (784'b1 << 168) | (784'b1 << 175) | (784'b1 << 182)
        | (784'b1 << 189) | (784'b1 << 196) | (784'b1 << 203)
        | (784'b1 << 210) | (784'b1 << 217) | (784'b1 << 224)
        | (784'b1 << 231) | (784'b1 << 238) | (784'b1 << 245)
        | (784'b1 << 252) | (784'b1 << 259) | (784'b1 << 266)
        | (784'b1 << 273) | (784'b1 << 280) | (784'b1 << 287)
        | (784'b1 << 294) | (784'b1 << 301) | (784'b1 << 308)
        | (784'b1 << 315) | (784'b1 << 322) | (784'b1 << 329)
        | (784'b1 << 336) | (784'b1 << 343) | (784'b1 << 350)
        | (784'b1 << 357) | (784'b1 << 364) | (784'b1 << 371)
        | (784'b1 << 378) | (784'b1 << 385) | (784'b1 << 392)
        | (784'b1 << 399) | (784'b1 << 406) | (784'b1 << 413)
        | (784'b1 << 420) | (784'b1 << 427) | (784'b1 << 434)
        | (784'b1 << 441) | (784'b1 << 448) | (784'b1 << 455)
        | (784'b1 << 462) | (784'b1 << 469) | (784'b1 << 476)
        | (784'b1 << 483) | (784'b1 << 490) | (784'b1 << 497)
        | (784'b1 << 504) | (784'b1 << 511) | (784'b1 << 518)
        | (784'b1 << 525) | (784'b1 << 532) | (784'b1 << 539)
        | (784'b1 << 546) | (784'b1 << 553) | (784'b1 << 560)
        | (784'b1 << 567) | (784'b1 << 574) | (784'b1 << 581)
        | (784'b1 << 588) | (784'b1 << 595) | (784'b1 << 602)
        | (784'b1 << 609) | (784'b1 << 616) | (784'b1 << 623)
        | (784'b1 << 630) | (784'b1 << 637) | (784'b1 << 644)
        | (784'b1 << 651) | (784'b1 << 658) | (784'b1 << 665)
        | (784'b1 << 672) | (784'b1 << 679) | (784'b1 << 686)
        | (784'b1 << 693) | (784'b1 << 700) | (784'b1 << 707)
        | (784'b1 << 714) | (784'b1 << 721) | (784'b1 << 728)
        | (784'b1 << 735) | (784'b1 << 742) | (784'b1 << 749)
        | (784'b1 << 756) | (784'b1 << 763) | (784'b1 << 770)
        | (784'b1 << 777));
    localparam bit [783:0] MNIST_IMG_0 = 784'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110000000000000000000001111111100000000000000001111111111110000000000000111111111100000000000000000111111110000000000000000000111111000000000000000000000111110000000000000000000000111110000000000000000000000011110000001110000000000000000111000011111100000000000000001111111111110000000000000000111111111100000000000000000001111111000000000000000000011111110000000000000000000011111100000000000000000000001111100000000000000000000001111111100000000000000000000111111111111110000000000000001111111111111000000000000000000111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000; 
    
    logic rstn_i = 1'b0;
    logic clk_i = 1'b0;
    always #5 clk_i = ~clk_i;   // 100 MHz

    // ----------------------------------------------------------------
    //  DUT I/O
    // ----------------------------------------------------------------
    logic        snn_kick_i  = 1'b0;
    logic [11:0] img_base_i  = 12'h0;
    logic  [7:0] timestep_i  = 8'd0;

    wire [63:0] hidden_spike_o;
    wire  [9:0] output_spike_o;
    wire        done_layer1_o;
    wire        done_layer2_o;
    wire        done_learn_o;

    // DTCM model — combinatorial read so aer_scan gets data in same cycle
    reg  [31:0] dtcm_mem [0:4095];
    wire        dtcm_rd_en;
    wire [11:0] dtcm_addr;
    wire [31:0] dtcm_data;
    assign dtcm_data = dtcm_mem[dtcm_addr];

    snn_top #(
        .WEIGHT_WIDTH  (8),
        .TIMESTEP_WIDTH(8)
    ) dut (
        .clk_i         (clk_i),
        .rstn_i        (rstn_i),
        .snn_kick_i    (snn_kick_i),
        .img_base_i    (img_base_i),
        .timestep_i    (timestep_i),
        .hidden_spike_o(hidden_spike_o),
        .output_spike_o(output_spike_o),
        .done_layer1_o (done_layer1_o),
        .done_layer2_o (done_layer2_o),
        .done_learn_o  (done_learn_o),
        .dtcm_rd_en_o  (dtcm_rd_en),
        .dtcm_addr_o   (dtcm_addr),
        .dtcm_data_i   (dtcm_data)
    );

    // ----------------------------------------------------------------
    //  Weight RAM reference copy
    // ----------------------------------------------------------------
    bit [63:0] weight_ram [0:6399];

    // ----------------------------------------------------------------
    //  Cycle counter
    // ----------------------------------------------------------------
    int cyc = 0;
    always @(posedge clk_i) cyc++;

    // ----------------------------------------------------------------
    //  FSM state name helper
    // ----------------------------------------------------------------
    function automatic string ctrl_state_str(input logic [2:0] s);
        case (s)
            3'd0: return "IDLE   ";  3'd1: return "FETCH  ";
            3'd2: return "DEC    ";  3'd3: return "EXEC   ";
            3'd4: return "READOUT";  3'd5: return "L2_INIT";
            default: return "???    ";
        endcase
    endfunction

    // ----------------------------------------------------------------
    //  Latches for verbose logging
    // ----------------------------------------------------------------
    logic [63:0] wt_latch     = '0;
    logic  [9:0] l1_pxl_latch = '0;
    logic  [5:0] l2_id_latch  = '0;

    always @(posedge clk_i) begin
        if (dut.pe_en) begin
            wt_latch     <= dut.ram_dout;
            l1_pxl_latch <= dut.ctrl_unit.spike_address;
            if (dut.ctrl_unit.layer_idx && dut.stp_idx == 3'd0)
                l2_id_latch <= dut.ctrl_unit.l1_spike_id;
        end
    end

    // ----------------------------------------------------------------
    //  Edge-detection helpers
    // ----------------------------------------------------------------
    logic scan_done_d1   = 0;
    logic layer_trans_d1 = 0;
    logic [2:0] state_d1 = 3'bx;

    always @(posedge clk_i) begin
        scan_done_d1   <= dut.scan_done;
        layer_trans_d1 <= dut.layer_transition;
        state_d1       <= dut.ctrl_unit.state;
    end

    // ================================================================
    //  VERBOSE MONITORS (suppressed when VERBOSE=0)
    // ================================================================
    always @(posedge clk_i) begin
        if (VERBOSE && rstn_i) begin
            if (dut.ctrl_unit.state !== state_d1)
                $display("[cyc=%04d] FSM  %s -> %s  (layer=%s, fifo_empty=%0b)",
                    cyc, ctrl_state_str(state_d1),
                    ctrl_state_str(dut.ctrl_unit.state),
                    dut.ctrl_unit.layer_idx ? "L2" : "L1",
                    dut.fifo_empty);

            if (dut.fifo_wr_en)
                $display("[cyc=%04d] [AER ] pxl=%3d -> FIFO", cyc, dut.aer_data);

            if (dut.scan_done && !scan_done_d1)
                $display("[cyc=%04d] [AER ] Scan DONE", cyc);

            if (dut.pe_en_dly && !dut.layer_sel_prev)
                $display("[cyc=%04d] [L1-PE] pxl=%3d grp=%0d  wt=%016h  spike_out=%08b",
                    cyc, l1_pxl_latch, dut.stp_idx_dly, wt_latch, dut.spike_out);

            if (dut.layer_transition && !layer_trans_d1)
                $display("[cyc=%04d] [TRANS] L1->L2  hidden=%016h (%0d active)",
                    cyc, hidden_spike_o, $countones(hidden_spike_o));

            if (dut.pe_en_dly && dut.layer_sel_prev)
                $display("[cyc=%04d] [L2-PE] h_n=%2d grp=%0d  wt=%016h  spike_out=%02b  out=%010b",
                    cyc, l2_id_latch, dut.stp_idx_dly, wt_latch,
                    dut.spike_out[1:0], output_spike_o);
        end
    end


    // ================================================================
    //  REFERENCE MODEL
    // ================================================================
    function automatic void ref_l1(
        input  bit [783:0] img,
        output bit [63:0]  h_spikes
    );
        int signed pot[64];
        h_spikes = '0;
        foreach (pot[n]) pot[n] = 0;

        // 1. ACCUMULATE ALL 784 PIXELS FIRST
        for (int p = 0; p < 784; p++) begin
            if (img[p]) begin
                for (int step = 0; step < 8; step++) begin
                    bit [63:0] word = weight_ram[p*8 + step];
                    for (int lane = 0; lane < 8; lane++) begin
                        int n         = step*8 + lane;
                        byte signed w = signed'(word[(lane*8) +: 8]);
                        
                        pot[n] = pot[n] + int'(w); // Just add! No threshold yet.
                    end
                end
            end
        end
        
        // 2. EVALUATE THRESHOLD AT THE VERY END
        for (int n = 0; n < 64; n++) begin
            if (pot[n] >= THRESHOLD_L1) begin
                h_spikes[n] = 1'b1;
            end
        end
    endfunction

    function automatic void ref_l2(
        input  bit [63:0] h_spikes,
        output bit [9:0]  o_spikes
    );
        int signed pot[10];
        int predicted_digit = -1;
        o_spikes = '0;
        foreach (pot[n]) pot[n] = 0;

        // 1. ACCUMULATE ALL WEIGHTS FIRST
        for (int i = 0; i < 64; i++) begin
            if (h_spikes[i]) begin
                bit [63:0] w0 = weight_ram[6272 + i*2];
                bit [63:0] w1 = weight_ram[6272 + i*2 + 1];
                
                for (int lane = 0; lane < 8; lane++) begin
                    byte signed w = signed'(w0[(lane*8) +: 8]);
                    pot[lane] = pot[lane] + int'(w); // No threshold check here!
                end
                for (int lane = 0; lane < 2; lane++) begin
                    byte signed w = signed'(w1[(lane*8) +: 8]);
                    pot[8+lane] = pot[8+lane] + int'(w); // No threshold check here!
                end
            end
        end

        // 2. CHECK THRESHOLD AT THE VERY END
        for (int lane = 0; lane < 10; lane++) begin
            if (pot[lane] >= THRESHOLD_L2) begin
                o_spikes[lane] = 1'b1;
            end
        end
        
        if (VERBOSE)
            $display("  [DEBUG] L2 Membrane Potentials: %p", pot);

    endfunction

    // ================================================================
    //  Single inference task
    // ================================================================
    int pass_count = 0;
    int fail_count = 0;

    task automatic run_and_check(
        input bit [783:0] img,
        input bit   [7:0] ts,
        input string      label
    );
        bit [63:0] ref_hidden;
        bit [9:0]  ref_output;
        int        l1_ok, l2_ok;

        $display("");
        $display("----------------------------------------------");
        $display("  %s", label);
        $display("  pixels=%0d  ts=%0d", $countones(img), ts);

        // Pack 784-bit image into 25 x 32-bit DTCM words at base 0
        for (int c = 0; c < 25; c++)
            dtcm_mem[c] = img[c*32 +: 32];

        @(posedge clk_i);
        img_base_i <= 12'h000;
        timestep_i <= ts;
        snn_kick_i <= 1'b1;

        @(posedge clk_i);
        snn_kick_i <= 1'b0;

        // Wait for inference to complete with a cycle timeout guard
        fork
            @(posedge done_layer2_o);
            begin
                repeat(5_000) @(posedge clk_i);
                $display("[TIMEOUT] %s did not complete — skipping", label);
                fail_count++;
            end
        join_any
        disable fork;

        repeat(10) @(posedge clk_i);

        ref_l1(img, ref_hidden);
        ref_l2(ref_hidden, ref_output);

        l1_ok = (hidden_spike_o === ref_hidden);
        l2_ok = (output_spike_o === ref_output[9:0]);

        if (VERBOSE) begin
            $display("  [HW ] L1=%016h (%0d)  L2=%010b",
                hidden_spike_o, $countones(hidden_spike_o), output_spike_o);
            $display("  [REF] L1=%016h (%0d)  L2=%010b",
                ref_hidden,     $countones(ref_hidden),     ref_output[9:0]);
        end

        if (l1_ok && l2_ok)
            pass_count++;
        else begin
            if (!VERBOSE) begin
                $display("  [HW ] L1=%016h  L2=%010b", hidden_spike_o, output_spike_o);
                $display("  [REF] L1=%016h  L2=%010b", ref_hidden, ref_output[9:0]);
            end
            $display("  --> FAIL  (L1=%s  L2=%s)",
                l1_ok ? "ok" : "MISMATCH", l2_ok ? "ok" : "MISMATCH");
            fail_count++;
        end
    endtask
    
    // ----------------------------------------------------------------
    //  MNIST Dataset Memory
    // ----------------------------------------------------------------
    //bit [783:0] mnist_images [0:99]; // Array of 100 images
    //bit [3:0]   mnist_labels [0:99]; // Array of 100 labels (0-9)

    // ================================================================
    //  MODE SELECT
    //  SINGLE_MODE = 1 : run one image, show prediction
    //  SINGLE_MODE = 0 : batch MNIST accuracy sweep
    // ================================================================
    localparam int SINGLE_MODE = 0;

    // ---- Single-image selection (used when SINGLE_MODE=1) ----
    // Change SINGLE_IMG to any of: IMG0..IMG8, MNIST_IMG_0
    // or define your own 784-bit pattern below.
    localparam bit [783:0] SINGLE_IMG = MNIST_IMG_0;
    localparam bit   [7:0] SINGLE_TS  = 8'd1;       // timestep value (arbitrary)

    // ---- Batch MNIST settings (used when SINGLE_MODE=0) ----
    localparam int NUM_TESTS = 9999;   // must match line count in mnist_stimulus.mem

    reg [783:0] image_mem [0 : NUM_TESTS-1];
    integer     label_mem [0 : NUM_TESTS-1];

    int  correct_predictions = 0;
    int  predicted_digit     = -1;
    int  start_cyc           = 0;
    int  total_cycles        = 0;
    real total_sec;
    real img_per_sec;

    // ================================================================
    //  MAIN SEQUENCE
    // ================================================================
    initial begin
        $readmemh("C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/weights_combined.hex", weight_ram);

        rstn_i = 1'b0;
        repeat(4) @(posedge clk_i);
        rstn_i = 1'b1;
        repeat(2) @(posedge clk_i);

        if (SINGLE_MODE) begin
            // ----------------------------------------------------------
            //  SINGLE IMAGE MODE
            // ----------------------------------------------------------
            $display("==============================================");
            $display("  SNN Single-Image Inference");
            $display("  pixels active = %0d", $countones(SINGLE_IMG));
            $display("==============================================");

            run_and_check(SINGLE_IMG, SINGLE_TS, "Single Image");

            // Decode one-hot output to digit
            predicted_digit = -1;
            for (int i = 0; i < 10; i++)
                if (output_spike_o[i]) predicted_digit = i;

            $display("");
            $display("==============================================");
            if (predicted_digit == -1)
                $display("  PREDICTION : SILENCE (no output neuron fired)");
            else
                $display("  PREDICTION : digit %0d", predicted_digit);
            $display("  L1 hidden  : %016h  (%0d active)", hidden_spike_o, $countones(hidden_spike_o));
            $display("  L2 output  : %010b", output_spike_o);
            $display("==============================================");

        end else begin
            // ----------------------------------------------------------
            //  BATCH MNIST MODE
            // ----------------------------------------------------------
            $readmemb("C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/mnist_stimulus.mem", image_mem);
            $readmemh("C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/mnist_labels.mem",   label_mem);
            $display("[LOAD] image_mem[0] active pixels = %0d  (0 means readmemb failed)", $countones(image_mem[0]));
            $display("[LOAD] label_mem[0] = %0d", label_mem[0]);

            $display("==============================================");
            $display("  SNN MNIST Accuracy Test  (%0d images)", NUM_TESTS);
            $display("==============================================");

            start_cyc = cyc;

            for (int img_idx = 0; img_idx < NUM_TESTS; img_idx++) begin
                automatic bit [783:0] cur_img   = image_mem[img_idx];
                automatic int         true_lbl  = label_mem[img_idx];
                automatic string      lbl_str   = $sformatf("MNIST[%0d]  true=%0d", img_idx, true_lbl);

                if (img_idx % 100 == 0)
                    $display(">>> Progress: %0d / %0d", img_idx, NUM_TESTS);

                run_and_check(cur_img, 8'd1, lbl_str);

                predicted_digit = -1;
                for (int i = 0; i < 10; i++)
                    if (output_spike_o[i]) predicted_digit = i;

                if (predicted_digit == true_lbl) begin
                    correct_predictions++;
                    $display("[%4d] PASS  true=%0d  pred=%0d", img_idx, true_lbl, predicted_digit);
                end else begin
                    if (predicted_digit == -1)
                        $display("[%4d] FAIL  true=%0d  pred=SILENCE", img_idx, true_lbl);
                    else
                        $display("[%4d] FAIL  true=%0d  pred=%0d", img_idx, true_lbl, predicted_digit);
                end
            end

            total_cycles = cyc - start_cyc;
            total_sec    = real'(total_cycles) * 10.0e-9;
            img_per_sec  = real'(NUM_TESTS) / total_sec;

            $display("==============================================");
            $display("  Tested : %0d", NUM_TESTS);
            $display("  Correct: %0d", correct_predictions);
            $display("  Acc    : %0.1f %%", (real'(correct_predictions) / real'(NUM_TESTS)) * 100.0);
            $display("  Cycles : %0d", total_cycles);
            $display("  Cyc/img: %0.1f", real'(total_cycles) / real'(NUM_TESTS));
            $display("  Img/s  : %0.0f  (@ 100 MHz)", img_per_sec);
            $display("==============================================");
        end

        $finish;
    end

endmodule
