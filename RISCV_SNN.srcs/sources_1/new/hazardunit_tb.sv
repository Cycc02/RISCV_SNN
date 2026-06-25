`timescale 1ns / 1ps
`include "defs.v"

module hazardunit_tb();

    reg [4:0] dec_rs1_i;
    reg [4:0] dec_rs2_i;
    reg [4:0] exec_rs1_i;
    reg [4:0] exec_rs2_i;
    reg [4:0] exec_rd_i;
    reg [4:0] mem_rd_i;
    reg [4:0] wb_rd_i;
    reg       dtcm_rd_i;
    reg       exec_regfile_we_i;
    reg       wb_regfile_we_i;

    wire [1:0] mux_rs1_o;
    wire [1:0] mux_rs2_o;
    wire       stall_o;

    hazardunit uut (
        .dec_rs1_i        (dec_rs1_i),
        .dec_rs2_i        (dec_rs2_i),
        .exec_rs1_i       (exec_rs1_i),
        .exec_rs2_i       (exec_rs2_i),
        .exec_rd_i        (exec_rd_i),
        .mem_rd_i         (mem_rd_i),
        .wb_rd_i          (wb_rd_i),
        .dtcm_rd_i        (dtcm_rd_i),
        .exec_regfile_we_i(exec_regfile_we_i),
        .wb_regfile_we_i  (wb_regfile_we_i),
        .mux_rs1_o        (mux_rs1_o),
        .mux_rs2_o        (mux_rs2_o),
        .stall_o          (stall_o)
    );

    int pass_count = 0;
    int fail_count = 0;

    // Apply inputs and wait for combinational propagation
    task apply(
        input [4:0] drs1, drs2, ers1, ers2, erd, mrd, wrd,
        input       dtcm, ewe, wwe
    );
        dec_rs1_i        = drs1;
        dec_rs2_i        = drs2;
        exec_rs1_i       = ers1;
        exec_rs2_i       = ers2;
        exec_rd_i        = erd;
        mem_rd_i         = mrd;
        wb_rd_i          = wrd;
        dtcm_rd_i        = dtcm;
        exec_regfile_we_i = ewe;
        wb_regfile_we_i  = wwe;
        #5;
    endtask

    task check(
        input string   test_name,
        input [1:0]    exp_rs1, exp_rs2,
        input          exp_stall
    );
        if (mux_rs1_o === exp_rs1 && mux_rs2_o === exp_rs2 && stall_o === exp_stall) begin
            $display("  [PASS] %-45s | rs1_mux=%2b rs2_mux=%2b stall=%b",
                     test_name, mux_rs1_o, mux_rs2_o, stall_o);
            pass_count++;
        end else begin
            $display("  [FAIL] %-45s | Got rs1=%2b rs2=%2b stall=%b | Exp rs1=%2b rs2=%2b stall=%b",
                     test_name, mux_rs1_o, mux_rs2_o, stall_o, exp_rs1, exp_rs2, exp_stall);
            fail_count++;
        end
    endtask

    initial begin
        // Default all inputs to inactive
        {dec_rs1_i, dec_rs2_i, exec_rs1_i, exec_rs2_i,
         exec_rd_i, mem_rd_i, wb_rd_i}    = '0;
        {dtcm_rd_i, exec_regfile_we_i, wb_regfile_we_i} = '0;

        $display("=== STARTING HAZARD UNIT SIMULATION ===");
        #5;

        // -------------------------------------------------------
        $display("\n--- Section 1: No Hazard ---");
        // -------------------------------------------------------
        apply(5'd1, 5'd2, 5'd3, 5'd4, 5'd5, 5'd6, 5'd7, 0, 1, 1);
        check("No Hazard (all regs differ)",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        apply(5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 5'd0, 0, 1, 1);
        check("All x0 (no forward to x0)",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        // -------------------------------------------------------
        $display("\n--- Section 2: EX/MEM Forwarding ---");
        // -------------------------------------------------------
        apply(0, 0, 5'd5, 5'd2, 0, 5'd5, 5'd9, 0, 1, 0);
        check("FWD_MEM: exec_rs1 == mem_rd",
              `FWD_MEM, `NORMAL_OP, 1'b0);

        apply(0, 0, 5'd2, 5'd7, 0, 5'd7, 5'd9, 0, 1, 0);
        check("FWD_MEM: exec_rs2 == mem_rd",
              `NORMAL_OP, `FWD_MEM, 1'b0);

        apply(0, 0, 5'd8, 5'd8, 0, 5'd8, 5'd9, 0, 1, 0);
        check("FWD_MEM: both rs1 and rs2 == mem_rd",
              `FWD_MEM, `FWD_MEM, 1'b0);

        // -------------------------------------------------------
        $display("\n--- Section 3: MEM/WB Forwarding ---");
        // -------------------------------------------------------
        apply(0, 0, 5'd3, 5'd2, 0, 5'd9, 5'd3, 0, 0, 1);
        check("FWD_WB: exec_rs1 == wb_rd",
              `FWD_WB, `NORMAL_OP, 1'b0);

        apply(0, 0, 5'd2, 5'd6, 0, 5'd9, 5'd6, 0, 0, 1);
        check("FWD_WB: exec_rs2 == wb_rd",
              `NORMAL_OP, `FWD_WB, 1'b0);

        apply(0, 0, 5'd4, 5'd4, 0, 5'd9, 5'd4, 0, 0, 1);
        check("FWD_WB: both rs1 and rs2 == wb_rd",
              `FWD_WB, `FWD_WB, 1'b0);

        // -------------------------------------------------------
        $display("\n--- Section 4: EX/MEM Priority over MEM/WB ---");
        // -------------------------------------------------------
        // rs1 matches both mem_rd and wb_rd -> MEM wins
        apply(0, 0, 5'd5, 5'd2, 0, 5'd5, 5'd5, 0, 1, 1);
        check("Priority: rs1 matches MEM and WB -> FWD_MEM wins",
              `FWD_MEM, `NORMAL_OP, 1'b0);

        apply(0, 0, 5'd2, 5'd5, 0, 5'd5, 5'd5, 0, 1, 1);
        check("Priority: rs2 matches MEM and WB -> FWD_MEM wins",
              `NORMAL_OP, `FWD_MEM, 1'b0);

        // rs1->MEM, rs2->WB simultaneously
        apply(0, 0, 5'd5, 5'd6, 0, 5'd5, 5'd6, 0, 1, 1);
        check("Mixed: rs1=FWD_MEM, rs2=FWD_WB simultaneously",
              `FWD_MEM, `FWD_WB, 1'b0);

        // -------------------------------------------------------
        $display("\n--- Section 5: Forwarding Guards ---");
        // -------------------------------------------------------
        // exec_regfile_we=0 -> no MEM forward
        apply(0, 0, 5'd5, 5'd2, 0, 5'd5, 5'd9, 0, 0, 0);
        check("No FWD_MEM when exec_regfile_we=0",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        // wb_regfile_we=0 -> no WB forward
        apply(0, 0, 5'd3, 5'd2, 0, 5'd9, 5'd3, 0, 0, 0);
        check("No FWD_WB when wb_regfile_we=0",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        // mem_rd = x0 -> no forward even if exec_rs1 = x0
        apply(0, 0, 5'd0, 5'd2, 0, 5'd0, 5'd9, 0, 1, 0);
        check("No FWD_MEM when mem_rd=x0",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        // wb_rd = x0 -> no forward
        apply(0, 0, 5'd0, 5'd2, 0, 5'd9, 5'd0, 0, 0, 1);
        check("No FWD_WB when wb_rd=x0",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        // -------------------------------------------------------
        $display("\n--- Section 6: Load-Use Stall ---");
        // -------------------------------------------------------
        // dtcm_rd=1, exec_rd!=0, dec_rs1==exec_rd -> stall
        apply(5'd4, 5'd2, 0, 0, 5'd4, 0, 0, 1, 0, 0);
        check("Stall: dec_rs1 == exec_rd (load-use)",
              `NORMAL_OP, `NORMAL_OP, 1'b1);

        // dtcm_rd=1, exec_rd!=0, dec_rs2==exec_rd -> stall
        apply(5'd2, 5'd4, 0, 0, 5'd4, 0, 0, 1, 0, 0);
        check("Stall: dec_rs2 == exec_rd (load-use)",
              `NORMAL_OP, `NORMAL_OP, 1'b1);

        // dtcm_rd=0 -> no stall even if registers match
        apply(5'd4, 5'd2, 0, 0, 5'd4, 0, 0, 0, 0, 0);
        check("No stall when dtcm_rd=0",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        // exec_rd=x0 -> no stall (x0 guard)
        apply(5'd0, 5'd2, 0, 0, 5'd0, 0, 0, 1, 0, 0);
        check("No stall when exec_rd=x0",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        // dec_rs1 and dec_rs2 both differ from exec_rd -> no stall
        apply(5'd3, 5'd5, 0, 0, 5'd4, 0, 0, 1, 0, 0);
        check("No stall when neither rs1 nor rs2 matches exec_rd",
              `NORMAL_OP, `NORMAL_OP, 1'b0);

        $display("\n=== HAZARD UNIT RESULT: Pass=%0d / Fail=%0d / Total=%0d ===",
                 pass_count, fail_count, pass_count + fail_count);
        $display("=== SIMULATION COMPLETE ===");
        $finish;
    end

endmodule
