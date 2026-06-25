//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.12.2025 18:50:05
// Design Name: 
// Module Name: ALU
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


module ALU(
    input alu_en_i,
    input [31:0] a_i,
    input [31:0] b_i,
    input [3:0] ctrl_i,
    output [31:0] result_o,
    output zero_o,
    output negative_o,
    output carry_o,
    output overflow_o
    );
    
    `include "defs.v"
    
    reg  [31:0] tmp_result;
    reg carry, overflow ,zero, negative;
    
    always @ (*) begin
        tmp_result = 32'h0;
        {carry, overflow, zero, negative} = 4'b0;
        if(alu_en_i) begin
            case(ctrl_i)
                `ALU_ADD : begin
                    tmp_result = a_i + b_i;
                    carry = (tmp_result < a_i);
                    overflow = ((~a_i[31] & ~b_i[31] & tmp_result[31]) |
                                (a_i[31] & b_i[31] & ~tmp_result[31]));
                    end
                `ALU_SUB : begin
                    tmp_result = a_i - b_i;
                    carry = (a_i >= b_i);
                    overflow = ((~a_i[31] & b_i[31] & tmp_result[31]) |
                               (a_i[31] & ~b_i[31] & ~tmp_result[31]));
                    end 
                `ALU_OR  : tmp_result = a_i | b_i;
                `ALU_AND : tmp_result = a_i & b_i;
                `ALU_XOR : tmp_result = a_i ^ b_i;
                `ALU_SLT : begin
                    if (a_i[31] != b_i[31])
                        tmp_result = a_i[31] ? 32'h1 : 32'h0;
                    else
                        tmp_result = (a_i < b_i) ? 32'h1 : 32'h0;
                    end
                `ALU_SLTU: tmp_result = (a_i < b_i) ? 32'h1 : 32'h0;
                //Can modify with Barrel Shift Register inefficient synthesis
                `ALU_SLL    : tmp_result = a_i << b_i[4:0];
                `ALU_SRL    : tmp_result = a_i >> b_i[4:0];
                // >>> on an unsigned operand is a logical shift in Verilog
                `ALU_SRA    : tmp_result = $signed(a_i) >>> b_i[4:0];
                `ALU_PASS_B : tmp_result = b_i;
                default     : tmp_result = 32'h0;
            endcase
            zero     = &(~tmp_result);
            negative = tmp_result[31];
         end    
    end
    
    assign result_o = tmp_result;
    assign zero_o = zero;
    assign negative_o = negative;
    assign carry_o = carry;
    assign overflow_o = overflow;
                       
endmodule
