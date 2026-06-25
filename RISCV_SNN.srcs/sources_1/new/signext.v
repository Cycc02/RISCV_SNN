`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.12.2025 01:08:00
// Design Name: 
// Module Name: signext
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


module signext(
    input [31:7] instr_i,
    input [2:0]  ext_ctrl_i,
    output [31:0] instr_o
    );
    
    `include "defs.v"
    
    reg [31:0] ext;
    
    always @ (*) begin
        ext = 32'h0;
        case(ext_ctrl_i)
            `ITYPE: ext = {{20{instr_i[31]}},instr_i[31:20]};
            `STYPE: ext = {{20{instr_i[31]}},instr_i[31:25],instr_i[11:7]};
            `BTYPE: ext = {{19{instr_i[31]}},instr_i[31],instr_i[7],instr_i[30:25],instr_i[11:8],1'b0};
            `UTYPE: ext = {instr_i[31:12],12'b0};
            `JTYPE: ext = {{11{instr_i[31]}},instr_i[31],instr_i[19:12],instr_i[20],instr_i[30:21],1'b0};
            default: ext = 32'h0;
    endcase
end
    assign instr_o = ext;
  
endmodule
