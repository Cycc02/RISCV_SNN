`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.12.2025 20:50:42
// Design Name: 
// Module Name: branchjump_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module branchjump_tb();
reg [31:0]  pc_i;
reg [31:0]  addr_imm_i;
reg [31:0]  data_rs1_i;
reg [2:0]   branch_sel_i;
reg         jump_sel_i;
reg         branch_en_i;
reg         jump_en_i;
reg         zero_i;
reg         carry_i;
reg         negative_i;
reg         overflow_i;

wire        pc_taken_o;
wire        instr_mis_ex_o;
wire [31:0] pc_mask_o;

`include "defs.v"

branchjumpunit dut_bju (
    .pc_i           (pc_i),
    .addr_imm_i     (addr_imm_i),
    .data_rs1_i     (data_rs1_i),
    .branch_sel_i   (branch_sel_i),
    .jump_sel_i     (jump_sel_i),
    .branch_en_i    (branch_en_i),
    .jump_en_i      (jump_en_i),
    .zero_i         (zero_i),
    .carry_i        (carry_i),
    .negative_i     (negative_i),
    .overflow_i     (overflow_i),
    
    .pc_taken_o     (pc_taken_o),
    .instr_mis_ex_o (instr_mis_ex_o),
    .pc_mask_o      (pc_mask_o)
);

int branch_op[] = '{`BREQ, `BRNEQ, `BRLT, `BRMTEQ, `BRLTU, `BRMTEQU};

wire [3:0] flags = {zero_i,carry_i,negative_i,overflow_i};
reg expected_flags;
reg expected_trap;
reg branch_error;
reg jump_error;
reg branch_out_err;
reg jump_out_err;
reg trap_trigger_err;
reg [31:0] branch_target;
reg [31:0] expected_jump;

typedef struct {
        logic z, c, n, v;
        string name;
} flag_t;

// Create a pool of scenarios specifically for your code's logic
flag_t pool[6] = '{
    '{z:1, c:0, n:0, v:0, name:"BREQ"},    // Triggers zero_i
    '{z:0, c:0, n:0, v:0, name:"BRNEQ"},   // Triggers ~zero_i
    '{z:0, c:0, n:1, v:0, name:"BRLT"},    // n != v (1 != 0)
    '{z:0, c:0, n:1, v:1, name:"BRMTEQ"},  // n == v (1 == 1)
    '{z:0, c:0, n:0, v:0, name:"BRLTU"},   // ~carry_i (~0)
    '{z:0, c:1, n:0, v:0, name:"BRMTEQU"}  // carry_i (1)
};

function bit predict_branch (logic [2:0] branch_ctrl, logic z,c,n,v);
    case(branch_ctrl)
    `BREQ: return z;
    `BRNEQ: return !z;
    `BRLT: return (n != v);
    `BRMTEQ: return (n == v);
    `BRLTU: return !c;
    `BRMTEQU: return c;
    default: return 1'b0;
    endcase
endfunction
 
//Normal Operation
initial begin
    jump_en_i = 1'b0;
    branch_en_i = 1'b0;
    jump_out_err = 1'b0;
    jump_error = 1'b0;
    branch_out_err = 1'b0;
    branch_error = 1'b0;
    
    //Branch Operation
    #10 branch_en_i = 1'b1;
    foreach (branch_op[i]) begin
        $display("Branch Operation Code: %4b",branch_op[i]);
        repeat(5) begin
            #($urandom_range(2, 5));
            expected_trap = 1'b0;
        
                foreach (pool[i]) begin                    
                    zero_i = pool[i].z;
                    carry_i = pool[i].c;
                    negative_i = pool[i].n;
                    overflow_i = pool[i].v;

                    branch_sel_i = branch_op[i];
                    pc_i = $urandom();
                    addr_imm_i = $urandom();
                    data_rs1_i = 32'h0;
                    
                    #1;
                    
                    expected_flags = predict_branch(branch_op[i], flags[3], flags[2], flags[1], flags[0]);
               
                    branch_error = (pc_taken_o ^ expected_flags);
                    branch_target = pc_i + addr_imm_i;
                    
                    if(!branch_error && expected_flags == 1'b1) begin
                        branch_out_err = (pc_mask_o !== branch_target);
                end

                if(branch_error) 
                    $error("Branch Failed Flags: Operation %h | pc_i: %h | addr: %h | pc_taken_o: %b | expected: %b", branch_op[i], pc_i, addr_imm_i, pc_taken_o, expected_flags);
                else if (branch_out_err)
                    $error("Branch Failed Output: Operation %h | pc_i: %h | addr: %h | pc_mask_o: %h | expected: %h", branch_op[i], pc_i, addr_imm_i, pc_mask_o, branch_target);
                else begin
                    expected_trap = pc_taken_o && (branch_target[1:0] !== 2'b00);
                    trap_trigger_err = (expected_trap !== instr_mis_ex_o);
                    
                    if(trap_trigger_err) begin
                        $error("TRAP: Branch Address Misaligned: %h", branch_target);
                    end
                 end
              end
          end       
    end
 
//Jump Operation
    #10 branch_en_i = 1'b0; jump_en_i = 1'b1;
    repeat(5) begin
        for(int i = 0; i < 2; i++) begin
            jump_out_err = 1'b0;
            
            jump_sel_i = i;
            data_rs1_i = $urandom();
            pc_i = $urandom();
            addr_imm_i = $urandom();
            expected_trap = 1'b0;
            
            #1;
            jump_error = pc_taken_o ^ jump_en_i;
            if (!jump_error && pc_taken_o) begin
                case(i)
                1'b0: begin
                    expected_jump = (data_rs1_i + addr_imm_i) & ~32'h1;
                    #1 expected_trap = pc_taken_o && (expected_jump[1:0] !== 2'b00);
                    #1 jump_out_err = (pc_mask_o !== expected_jump);
                end
                1'b1: begin 
                    expected_jump = (pc_i + addr_imm_i);
                    #1 expected_trap = pc_taken_o && (expected_jump[1:0] !== 2'b00);               
                    #1 jump_out_err = (pc_mask_o !== expected_jump);
                end
                endcase
            end
            
            if(jump_error) 
                $error("Jump Failed Flags: Operation %h | pc_i: %h | addr: %h | pc_taken_o: %b | expected: %b", jump_sel_i, pc_i, addr_imm_i, pc_taken_o, jump_en_i);
            else if (jump_out_err)
                $error("Jump Failed Output: Operation %h | pc_i: %h | addr: %h | pc_mask_o: %h | expected: %h", jump_sel_i, pc_i, addr_imm_i, pc_mask_o, expected_jump);
            else begin
                trap_trigger_err = (expected_trap !== instr_mis_ex_o);
                if(trap_trigger_err) begin
                    $error("Trap: Jump Operation Address Misaligned: %h | expected_trap: %b | instr_mis_ex_o: %b", expected_jump, expected_trap, instr_mis_ex_o);
                end
             end
          end
      end
      $display("Simulation ends");
      #1 $finish;
 end                    

endmodule
