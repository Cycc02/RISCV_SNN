`timescale 1ns / 1ps
// CoreMark testbench for riscv_top.v
//
// 1. Build firmware:  bash build_coremark.sh  (generates itcm.hex + dtcm.hex)
// 2. Simulate this file in Vivado (or xsim).

module coremark_tb;

    // ----------------------------------------------------------------
    //  Parameters
    // ----------------------------------------------------------------
    parameter CLK_PERIOD_NS = 20;              // 50 MHz

    parameter [63:0] MAX_CYCLES = 64'd30_000_000;

    // ----------------------------------------------------------------
    //  DUT signals — clk/rstn now come from the PS7 VIP + internal POR
    // ----------------------------------------------------------------
    wire [4:0] gpr_data;
    wire       uart_tx;

    // Simulation probes via hierarchical reference
    wire       uart_valid = dut.uart_valid_o;
    wire [7:0] uart_char  = dut.uart_char_o;

    // ----------------------------------------------------------------
    //  DUT — FIXED_IO left unconnected (PS7 VIP self-clocks in sim)
    // ----------------------------------------------------------------
    riscv_top dut (
        .gpr_data_o (gpr_data),
        .uart_tx_o  (uart_tx),
        .uart_rx_i  (1'b1)
    );

    wire clk  = dut.clk;
    wire rstn = dut.rstn;

    // ----------------------------------------------------------------
    //  Pipeline probes (hierarchical access into dut)
    // ----------------------------------------------------------------
    wire [31:0] pc_in_ex     = dut.reg_dec_pc;
    wire [4:0]  ex_rd        = dut.reg_dec_rd;
    wire [4:0]  ex_rs1       = dut.reg_dec_rs1;
    wire [1:0]  fwd_rs1      = dut.hzrd_mux_rs1;
    wire [31:0] ex_alu_result= dut.exec_result;
    wire [4:0]  wb_rd        = dut.reg_wb_rd;
    wire        wb_we        = dut.reg_wb_regfile_we;
    wire [31:0] wb_val       = dut.wb_result;

    wire [31:0] uart_sw_pc   = dut.reg_exec_pc_plus4 - 32'd4;
    wire [31:0] uart_sw_data = dut.reg_exec_dtcm_data;
    wire [29:0] uart_sw_addr = dut.reg_exec_dtcm_addr;

    // ----------------------------------------------------------------
    //  UART capture — write to file AND console so output survives
    //  the xsim socket-close race condition at simulation end.
    // ----------------------------------------------------------------
    integer uart_fd;
    initial uart_fd = $fopen("uart_output.txt", "w");

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
    //  Cycle counter + progress + timeout
    // ----------------------------------------------------------------
    reg [63:0] cycle_count;
    initial cycle_count = 64'd0;

    always @(posedge clk) begin
        if (rstn) begin
            cycle_count <= cycle_count + 1;

            // Progress report every 100M cycles
            if (cycle_count % 100_000_000 == 0 && cycle_count > 0)
                $display("\n[%0d M cycles] IF_PC=0x%08x", cycle_count / 1_000_000, dut.fe_pc);

            // Hard timeout
            if (cycle_count >= MAX_CYCLES) begin
                $display("\n[TIMEOUT] %0d M cycles elapsed. CoreMark did not complete.", MAX_CYCLES / 1_000_000);
                $fclose(uart_fd);
                $finish;
            end
        end
    end

    // ----------------------------------------------------------------
    //  Reset sequence
    // ----------------------------------------------------------------
    initial begin
        $display("=== CoreMark Simulation  (MAX_CYCLES=%0d M) ===", MAX_CYCLES / 1_000_000);
        wait (rstn === 1'b1);
        $display("[%0t ns] Reset released (internal POR).", $time);
    end

    // ----------------------------------------------------------------
    //  Trap counter — fires whenever csr trap_trigger pulses high.
    //  With mtvec→end_loop (set in crt0.S), any exception goes to
    //  end_loop (0x3c) and the simulation reports below instead of
    //  silently restarting the CPU.
    // ----------------------------------------------------------------
    // Monitor writes to a0 (x10) — show last 8 before any trap
    reg [63:0] a0_wr_cycle [0:7];
    reg [31:0] a0_wr_val   [0:7];
    reg [31:0] a0_wr_pc    [0:7];
    integer    a0_wr_idx = 0;
    integer    a0_wr_k;
    initial begin
        for (a0_wr_k = 0; a0_wr_k < 8; a0_wr_k = a0_wr_k + 1) begin
            a0_wr_cycle[a0_wr_k] = 0;
            a0_wr_val  [a0_wr_k] = 0;
            a0_wr_pc   [a0_wr_k] = 0;
        end
    end
    always @(posedge clk) begin
        if (rstn && dut.reg_wb_regfile_we && (dut.reg_wb_rd == 5'd10)) begin
            a0_wr_cycle[a0_wr_idx % 8] = cycle_count;
            a0_wr_val  [a0_wr_idx % 8] = dut.wb_result;
            a0_wr_pc   [a0_wr_idx % 8] = dut.reg_wb_pc_plus4 - 32'd4;
            a0_wr_idx = a0_wr_idx + 1;
        end
    end

    // Log every write to ra (x1) — hardware showed ra corrupted to 0x54
    // (cmp_idx entry), causing an infinite ret-to-self loop.
    always @(posedge clk) begin
        if (rstn && dut.reg_wb_regfile_we && (dut.reg_wb_rd == 5'd1))
            $display("[RA] cycle=%0d PC=0x%08x ra<=0x%08x",
                     cycle_count, dut.reg_wb_pc_plus4 - 32'd4, dut.wb_result);
    end

    // Cycle-level pipeline trace around the ra-corruption window
    always @(posedge clk) begin
        if (rstn && cycle_count >= 2405 && cycle_count <= 2425)
            $display("[TR] cyc=%0d EXpc=%05x jmp=%b taken=%b memstall=%b hzstall=%b | EXMEM rd=x%0d rsrc=%b res=%08x pc4=%08x | WB rd=x%0d we=%b rsrc=%b out=%08x",
                     cycle_count, dut.reg_dec_pc[19:0], dut.reg_dec_jump_en,
                     dut.exec_pc_taken, mem_stall_tr, dut.hzrd_stall,
                     dut.reg_exec_rd, dut.reg_result_src, dut.reg_exec_result, dut.reg_exec_pc_plus4,
                     dut.reg_wb_rd, dut.reg_wb_regfile_we, dut.reg_wb_result_src, dut.wb_result);
    end
    wire mem_stall_tr = dut.mem_stall;

    // Load-path trace: EX-stage LSU controls + MEM-stage extension result
    always @(posedge clk) begin
        if (rstn && cycle_count < 30000) begin
            if (dut.exec.lsu.dtcm_rd_en_o && dut.exec.lsu.ld_ext_ctrl_o != 2'b00)
                $display("[EXLD] cyc=%0d pc=%05x lsuctrl=%h ext=%b mask=%b addr=%h",
                         cycle_count, dut.reg_dec_pc[19:0], dut.exec.lsu.lsu_ctrl_i,
                         dut.exec.lsu.ld_ext_ctrl_o, dut.exec.lsu.mask_o, dut.exec.lsu.dtcm_addr_o);
            if (dut.mem.dmem.reg_ld_ack)
                $display("[MEMLD] cyc=%0d ext=%b mask=%b raw=%08x out=%08x",
                         cycle_count, dut.mem.dmem.reg_ld_ext_ctrl, dut.mem.dmem.reg_ld_mask,
                         dut.mem.dmem.reg_out, dut.mem.ld_data_o);
        end
    end

    integer trap_count = 0;
    always @(posedge clk) begin
        if (rstn && dut.trap_trigger) begin
            trap_count = trap_count + 1;
            if (trap_count <= 5) begin
                $display("[TRAP #%0d] cycle=%0d exec_PC=0x%08x alu_result=0x%08x rs1=x%0d fwd_rs1=%0b lsu_en=%0b lsu_ctrl=0x%01x",
                         trap_count, cycle_count, pc_in_ex,
                         dut.exec_result, dut.reg_dec_rs1,
                         dut.hzrd_mux_rs1, dut.reg_dec_lsu_en, dut.reg_dec_lsu_ctrl);
                $display("[TRAP] Last a0 writes (pc -> val):");
                for (a0_wr_k = 0; a0_wr_k < 8; a0_wr_k = a0_wr_k + 1)
                    if (a0_wr_cycle[a0_wr_k] > 0)
                        $display("  cycle=%0d PC=0x%08x a0=0x%08x",
                                 a0_wr_cycle[a0_wr_k], a0_wr_pc[a0_wr_k], a0_wr_val[a0_wr_k]);
            end
        end
    end

    // ----------------------------------------------------------------
    //  Halt detector
    //  NOTE: "j end_loop" causes the fetch PC to cycle through 3
    //  addresses (end_loop, end_loop+4, end_loop+8) due to the
    //  2-cycle branch penalty, so pc_stable_cnt never reaches 64
    //  in a tight branch loop.  Use cycle-count-based detection
    //  instead, relying on uart_seen and trap_count.
    // ----------------------------------------------------------------
    wire [31:0] cpu_pc;
    assign cpu_pc = dut.fe_pc;

    reg  [31:0] prev_pc       = 32'hFFFF_FFFF;
    integer     pc_stable_cnt = 0;

    // Track last cycle when a UART character was output
    reg [63:0] last_uart_cycle = 64'd0;
    always @(posedge clk) begin
        if (uart_valid)
            last_uart_cycle <= cycle_count;
    end

    always @(posedge clk) begin
        if (rstn) begin
            if (cpu_pc === prev_pc)
                pc_stable_cnt <= pc_stable_cnt + 1;
            else begin
                pc_stable_cnt <= 0;
                prev_pc       <= cpu_pc;
            end

            // Early halt: CPU stuck before any UART output (startup crash)
            // Only for very early cycles when the PC should be advancing
            if (pc_stable_cnt >= 64 && cycle_count < 100) begin
                $display("\n[HALT] CPU stuck at PC=0x%08x too early (cycle %0d).",
                         cpu_pc, cycle_count);
                $display("[HALT] WB: rd=x%0d we=%b val=0x%08x",
                         wb_rd, wb_we, wb_val);
                $display("[HALT] EX: PC=0x%08x rd=x%0d rs1=x%0d fwd=%02b alu=0x%08x",
                         pc_in_ex, ex_rd, ex_rs1, fwd_rs1, ex_alu_result);
                #100;
                $finish;
            end

            // Normal end: UART output seen and quiet for 50K cycles
            // (covers the case where main() returns into end_loop)
            if (uart_seen && (cycle_count - last_uart_cycle) > 50_000) begin
                $display("\n[DONE] UART output complete at cycle %0d (%0d M cycles).",
                         cycle_count, cycle_count / 1_000_000);
                $fclose(uart_fd);
                #10000;   // 10 us: give socket buffer time to drain before finish
                $finish;
            end

            // Trap-halt: any trap occurred and no UART output after 50K cycles.
            // Does not rely on pc_stable_cnt (j end_loop oscillates fetch PC).
            if (trap_count > 0 && !uart_seen && cycle_count > 50_000) begin
                $display("\n[TRAP-HALT] %0d trap(s), no UART output (cycle=%0d).",
                         trap_count, cycle_count);
                $display("[TRAP-HALT] CPU PC=0x%08x, last trap exec_PC=0x%08x.",
                         cpu_pc, pc_in_ex);
                $fclose(uart_fd);
                #100;
                $finish;
            end
        end
    end

endmodule
