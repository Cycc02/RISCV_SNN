`timescale 1ns / 1ps
// End-to-end testbench for the RISC-V + SNN system.
//
// Workflow under test:
//   crt0  -> main() -> writes SNN_IMG_BASE -> writes SNN_KICK
//        -> CPU does parallel checksum loop -> polls SNN_KICK
//        -> reads SNN_OUT/SNN_HID_*  -> prints results over UART
//
// Build firmware first:
//   bash build_snn_e2e.sh                (or:  bash build_snn_e2e.sh 6767)
//
// Then simulate this file as the top-level sim source.
//
// PS7 bypass: riscv_top has no top-level clk/rstn ports — the clock and
// reset come from the PS7 stub via FCLK0/FCLK_RESET0_N. In simulation
// the PS7 model usually does not toggle FCLK0, so we override the
// internal `clk` and `rstn` nets directly with hierarchical `force`.

module snn_e2e_tb;

    parameter CLK_PERIOD_NS = 10;            // 100 MHz (matches FCLK0)
    parameter [63:0] MAX_CYCLES = 64'd20_000_000;

    // ----------------------------------------------------------------
    // Clock + reset (forced into dut)
    // ----------------------------------------------------------------
    reg clk  = 1'b0;
    reg rstn = 1'b0;

    always #(CLK_PERIOD_NS / 2) clk = ~clk;

    // ----------------------------------------------------------------
    // DUT — leave FIXED_IO dangling; we'll override clk/rstn below.
    // ----------------------------------------------------------------
    wire [53:0] mio;
    wire        ps_clk_w, ps_porb_w, ps_srstb_w;
    wire [4:0]  gpr;
    wire        uart_tx_w;

    riscv_top dut (
        .FIXED_IO_mio    (mio),
        .FIXED_IO_ps_clk (ps_clk_w),
        .FIXED_IO_ps_porb(ps_porb_w),
        .FIXED_IO_ps_srstb(ps_srstb_w),
        .gpr_data_o      (gpr),
        .uart_tx_o       (uart_tx_w),
        .uart_rx_i       (1'b1)
    );

    // Force internal clk + rstn so the CPU runs without the PS7 model.
    initial begin
        force dut.clk  = clk;
        force dut.rstn = rstn;
    end

    // ----------------------------------------------------------------
    // UART capture — same approach as coremark_tb
    // ----------------------------------------------------------------
    integer uart_fd;
    initial uart_fd = $fopen("snn_e2e_uart.txt", "w");

    wire       uart_valid = dut.uart_valid_o;
    wire [7:0] uart_char  = dut.uart_char_o;

    reg uart_seen = 1'b0;
    always @(posedge clk) begin
        if (uart_valid) begin
            $fwrite(uart_fd, "%c", uart_char);
            $fflush(uart_fd);
            $write("%c", uart_char);
            uart_seen <= 1'b1;
        end
    end

    // ----------------------------------------------------------------
    // SNN activity probes for waveform inspection.
    // ----------------------------------------------------------------
    wire        snn_kick      = dut.snn_kick;     // one-cycle pulse
    wire        snn_busy      = dut.exec.csr.csr_rf.reg_snn_busy;
    wire        snn_done      = dut.snn_done;
    wire        snn_rd_en     = dut.snn_dtcm_rd_en;
    wire [11:0] snn_addr      = dut.snn_dtcm_addr;
    wire [9:0]  snn_out_spike = dut.snn_output_spike;
    wire [63:0] snn_hid_spike = dut.snn_hidden_spike;

    // Extra SNN diagnostics: log scan_done, scan_chunk_num, state at intervals.
    wire        snn_scan_done_w  = dut.snn.scan_done;
    wire [4:0]  snn_chunk_num_w  = dut.snn.scan_chunk_num;
    wire        snn_chunk_req_w  = dut.snn.chunk_req;
    wire [2:0]  snn_state_w      = dut.snn.ctrl_unit.state;
    reg snn_scan_done_d = 0;
    reg [2:0] snn_state_d = 0;
    always @(posedge clk) begin
        snn_scan_done_d <= snn_scan_done_w;
        snn_state_d     <= snn_state_w;
        if (rstn && snn_scan_done_w && !snn_scan_done_d)
            $display("[%0t] cy%0d snn_scan_done rising", $time, cycle_count);
        if (rstn && snn_state_w !== snn_state_d)
            $display("[%0t] cy%0d snn_state %0d->%0d chunk=%0d fifo_empty=%0b sticky=%0b",
                     $time, cycle_count, snn_state_d, snn_state_w,
                     dut.snn.scan_chunk_num, dut.snn.fifo_empty, dut.snn.scan_done_sticky);
    end

    // SNN FSM probes
    wire        snn_layer_sel = dut.snn.layer_sel;
    wire        snn_layer_sel_prev = dut.snn.layer_sel_prev;
    wire        snn_eval_l1 = dut.snn.eval_l1;
    wire        snn_fifo_empty = dut.snn.fifo_empty;
    wire        snn_scan_done_sticky = dut.snn.scan_done_sticky;
    reg snn_layer_sel_d = 0;
    reg snn_eval_l1_d = 0;
    always @(posedge clk) begin
        snn_layer_sel_d <= snn_layer_sel;
        snn_eval_l1_d <= snn_eval_l1;
        if (rstn && snn_layer_sel !== snn_layer_sel_d)
            $display("[%0t] cy%0d snn_layer_sel %0b->%0b", $time, cycle_count, snn_layer_sel_d, snn_layer_sel);
        if (rstn && snn_eval_l1 !== snn_eval_l1_d)
            $display("[%0t] cy%0d snn_eval_l1   %0b->%0b", $time, cycle_count, snn_eval_l1_d, snn_eval_l1);
    end

    // Log every CSR access in EX stage so we can correlate with the firmware.
    wire        csr_we_ex   = dut.exec.csr.csr_we;
    wire [11:0] csr_addr_ex = dut.exec.csr.csr_addr_i;
    wire [31:0] csr_i_ex    = dut.exec.csr.csr_regfile_i;
    wire [31:0] csr_o_ex    = dut.exec.csr.csr_regfile_o;
    wire [2:0]  csr_ctrl_ex = dut.exec.csr.csr_ctrl_i;
    wire        csr_rwe_ex  = dut.exec.csr.csr_rwe_i;
    // Log CSR writes (always) but only every 200th csrr to 0xbc2 (avoid spam).
    reg [9:0] poll_cnt = 0;
    always @(posedge clk) begin
        if (rstn && csr_rwe_ex && (csr_addr_ex[11:4] == 8'hBC || csr_addr_ex == 12'hC00)) begin
            if (csr_we_ex || csr_addr_ex != 12'hBC2) begin
                $display("[%0t] cy%0d CSR access: ctrl=%0d we=%0b addr=0x%03x csr_i=0x%08x csr_o=0x%08x",
                         $time, cycle_count, csr_ctrl_ex, csr_we_ex, csr_addr_ex, csr_i_ex, csr_o_ex);
            end else begin
                poll_cnt <= poll_cnt + 1;
                if (poll_cnt == 0)
                    $display("[%0t] cy%0d poll BC2 csr_o=0x%08x", $time, cycle_count, csr_o_ex);
            end
        end
    end

    // Log every transition of reg_snn_busy + reg_snn_kick + done pulses.
    reg snn_busy_d = 1'b0;
    reg snn_done_d = 1'b0;
    always @(posedge clk) begin
        snn_busy_d <= snn_busy;
        snn_done_d <= snn_done;
        if (rstn && (snn_busy !== snn_busy_d))
            $display("[%0t] cycle %0d: snn_busy %0b -> %0b (kick=%0b done=%0b)",
                     $time, cycle_count, snn_busy_d, snn_busy, snn_kick, snn_done);
        if (rstn && snn_done && !snn_done_d)
            $display("[%0t] cycle %0d: snn_done rising edge", $time, cycle_count);
    end

    // Parallel-execution proof: count CPU instructions retiring while SNN busy.
    reg [31:0] cpu_retire_during_snn = 32'd0;
    reg [31:0] cpu_retire_total      = 32'd0;
    always @(posedge clk) begin
        if (rstn) begin
            if (dut.reg_wb_regfile_we && (dut.reg_wb_rd != 5'd0))
                cpu_retire_total <= cpu_retire_total + 1;
            if (snn_busy && dut.reg_wb_regfile_we && (dut.reg_wb_rd != 5'd0))
                cpu_retire_during_snn <= cpu_retire_during_snn + 1;
        end
    end

    // ----------------------------------------------------------------
    // Cycle counter + timeout + done-detect
    // ----------------------------------------------------------------
    reg [63:0] cycle_count = 64'd0;
    reg [63:0] last_uart_cycle = 64'd0;
    reg [63:0] kick_cycle = 64'd0;
    reg [63:0] done_cycle = 64'd0;
    reg        kick_seen  = 1'b0;
    reg        done_seen  = 1'b0;

    always @(posedge clk) if (rstn) cycle_count <= cycle_count + 1;
    always @(posedge clk) if (uart_valid) last_uart_cycle <= cycle_count;

    always @(posedge clk) begin
        if (rstn) begin
            if (snn_kick && !kick_seen) begin
                kick_seen  <= 1'b1;
                kick_cycle <= cycle_count;
                $display("[%0t] SNN kicked at cycle %0d", $time, cycle_count);
            end
            if (snn_done && kick_seen && !done_seen) begin
                done_seen  <= 1'b1;
                done_cycle <= cycle_count;
                $display("[%0t] SNN done_layer2 at cycle %0d (SNN busy = %0d cycles)",
                         $time, cycle_count, cycle_count - kick_cycle);
            end
        end
    end

    // ----------------------------------------------------------------
    // Reset + run
    // ----------------------------------------------------------------
    initial begin
        $display("=== SNN end-to-end simulation ===");
        rstn = 1'b0;
        repeat (20) @(posedge clk);
        rstn = 1'b1;
        $display("[%0t] Reset released.", $time);
    end

    always @(posedge clk) begin
        if (rstn) begin
            if (cycle_count >= MAX_CYCLES) begin
                $display("\n[TIMEOUT] %0d cycles elapsed.", MAX_CYCLES);
                report_and_finish;
            end
            if (uart_seen && (cycle_count - last_uart_cycle) > 50_000) begin
                $display("\n[DONE] UART quiet for 5K cycles after last byte.");
                report_and_finish;
            end
        end
    end

    task report_and_finish;
        begin
            $display("\n----- Summary -----");
            $display("  Cycles total                : %0d", cycle_count);
            if (kick_seen && done_seen)
                $display("  SNN inference window        : %0d cycles", done_cycle - kick_cycle);
            $display("  CPU retire (total)          : %0d", cpu_retire_total);
            $display("  CPU retire while SNN busy   : %0d", cpu_retire_during_snn);
            $display("  Final output_spike (10b)    : %010b", snn_out_spike);
            $display("  Final hidden_spike (64b)    : %064b", snn_hid_spike);
            $fclose(uart_fd);
            #1000 $finish;
        end
    endtask

endmodule
