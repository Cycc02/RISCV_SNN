`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.12.2025 12:14:21
// Design Name: 
// Module Name: alu_tb
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


module alu_tb();
reg alu_en_i;
reg [31:0] in1;
reg [31:0] in2;
reg [3:0]  alu_ctrl;
wire  [31:0] alu_result;
wire        zero_o;
wire        negative_o;
wire        carry_o;
wire        overflow_o;

`include "defs.v"

ALU dut_alu (
    .alu_en_i(alu_en_i),
    .a_i(in1),
    .b_i(in2),
    .ctrl_i(alu_ctrl),
    
    .result_o(alu_result),
    .zero_o(zero_o),
    .negative_o(negative_o),
    .carry_o(carry_o),
    .overflow_o(overflow_o)
);

integer rmin = 2;
integer rmax = 5;
reg [32:0] check_result;
reg alu_error;
reg flag_error;
reg [3:0] check_flag; //ZNCO order
int opcode[] = '{`ALU_ADD, `ALU_SUB, `ALU_SLL, `ALU_SLT, `ALU_SLTU, `ALU_XOR, `ALU_SRL, `ALU_SRA, `ALU_OR, `ALU_AND, `ALU_PASS_B};

initial begin
check_result = 33'h0;
alu_error = 1'b0;
flag_error = 1'b0;
check_flag = 4'b0; 
#10 
alu_en_i = 1'b1; 
alu_ctrl = `ALU_ADD; //Default ADD
in1 = 32'h0; 
in2 = 32'h0;

    foreach (opcode[i]) begin 
    //for(int i = 0; i < (2**$bits(alu_ctrl)) ; i++) begin
         $display("Operation Code: %0d", opcode[i]);
         repeat(5) begin
            check_flag = 4'b0000;
            #($urandom_range(rmin, rmax));
            
            alu_ctrl = opcode[i];
            in1 = $urandom();
            in2 = $urandom();
            #1;
            //check value
            case(alu_ctrl)
            `ALU_ADD: begin
                 check_result = {1'b0,in1} + {1'b0,in2};
                 check_flag[1] = ({1'b0,in1} + {1'b0,in2}) >> 32; //Add the SLL to show MSB
                 check_flag[0] = ((in1[31] == in2[31]) && (check_result[31] != in1[31]));  
             end    
            `ALU_SUB: begin
                 check_result = in1 - in2;
                 check_flag[1] = (in1 > in2);
                 check_flag[0] = ((in1[31] != in2[31]) && (check_result[31] != in1[31]));
             end  
            `ALU_SLL: check_result = (in1 << in2[4:0]);
            `ALU_SLT: check_result = ($signed(in1) < $signed(in2)) ? 1'b1 : 1'b0;
            `ALU_SLTU: check_result = (in1 < in2) ? 1'b1 : 1'b0;
            `ALU_XOR: check_result = in1 ^ in2;
            `ALU_SRL: check_result = in1 >> in2[4:0];
            `ALU_SRA: check_result = in1 >>> in2[4:0];
            `ALU_OR: check_result = in1 | in2;
            `ALU_AND: check_result = in1 & in2;
            `ALU_PASS_B: check_result = in2;
            default: begin
                check_result = 32'h0;
                check_flag = 4'b0000;
            end
            endcase
            
            //Check Flag
            check_flag[3] = (check_result[31:0] == 0);
            check_flag[2] = check_result[31];
            
            //Condition check
            if(check_result[31:0] !== alu_result) begin
                $error("Failed: Operation %h | in1: %h | in2: %h |expected result: %h | get_result: %h", alu_ctrl, in1, in2, check_result[31:0], alu_result);
                alu_error = 1'b1;
            end
            else alu_error = 1'b0; 
           
           if(check_flag !== {zero_o, negative_o, carry_o, overflow_o}) begin
                $error("Failed Flags: Operation %h | in1: %h | in2: %h |expected flag: %4b | get_result: %4b", alu_ctrl, in1, in2, check_flag, {zero_o, negative_o, carry_o, overflow_o});
                flag_error = 1'b1;
           end
           else flag_error = 1'b0;
  
        end
    end 
$display("Done Checking");
#50 $finish;
end

endmodule
