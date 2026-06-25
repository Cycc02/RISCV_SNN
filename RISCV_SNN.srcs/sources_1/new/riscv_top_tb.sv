`timescale 1ns / 1ps

// ISA Functional Testbench for riscv_top
//
// Pass/fail protocol (riscv_test.h):
//   PASS: CPU executes  sw a0(=1),  0(a1)  where a1 = &tohost (0x10000)
//   FAIL: CPU executes  sw TESTNUM, 0(a1)  where TESTNUM >= 2
//
// Detection: monitor the Execute→Memory pipeline register for a store to
// DTCM word 0 (byte addr 0x10000 = word addr 0x4000, [11:0]=0x000, bit28=0).
// This avoids hierarchical array access which is unreliable in xsim.
//
// Signals used (all plain regs in riscv_top, fully accessible via hierarchy):
//   uut.reg_exec_dtcm_wr_en    — store enable in mem stage
//   uut.reg_exec_dtcm_addr     — 30-bit word address
//   uut.reg_exec_dtcm_data     — data being written

module riscv_top_tb();

    reg clk_i;
    reg rstn_i;

    riscv_top uut (
        .clk_i  (clk_i),
        .rstn_i (rstn_i)
    );

    // 10 ns period → 100 MHz
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    localparam MAX_CYCLES = 100_000;
    integer cycle_count;

    // Detect write to tohost on any posedge
    always @(posedge clk_i) begin
        if (rstn_i                                     &&
            uut.reg_exec_dtcm_wr_en                    &&
            ~uut.reg_exec_dtcm_addr[28]                &&  // not UART
            (uut.reg_exec_dtcm_addr[11:0] == 12'h000)) begin  // word 0 = tohost

            if (uut.reg_exec_dtcm_data === 32'd1) begin
                $display("[PASS] Test passed after %0d cycles.", cycle_count);
            end else begin
                $display("[FAIL] Test failed at test case %0d after %0d cycles.",
                         uut.reg_exec_dtcm_data, cycle_count);
            end
            $finish;
        end
    end

    // Cycle-by-cycle hazard display
    always @(posedge clk_i) begin
        if (rstn_i) begin
            $display("CYC=%0d | PC=%08h rd=x%0d | FWD: rs1=%02b rs2=%02b stall=%0b | ALU: res=%08h | WB: x%0d=%08h",
                cycle_count,
                uut.reg_dec_pc, uut.reg_dec_rd,
                uut.hzrd_mux_rs1, uut.hzrd_mux_rs2, uut.hzrd_stall,
                uut.exec_result,
                uut.reg_wb_rd, uut.wb_result
            );
        end
    end

    // Timeout counter
    initial begin
        cycle_count = 0;
        rstn_i = 0;
        repeat(2) @(posedge clk_i);
        rstn_i = 1;

        repeat(MAX_CYCLES) begin
            @(posedge clk_i);
            cycle_count = cycle_count + 1;
        end

        $display("[FAIL] Timeout: tohost never written after %0d cycles.", MAX_CYCLES);
        $finish;
    end

endmodule
