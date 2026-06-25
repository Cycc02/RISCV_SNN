`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 22:08:06
// Design Name: 
// Module Name: 2dff_sync
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


module dff_sync(
    input clk_i,
    input rstn_i,
    input d,
    output q
    );
    
    reg q_reg;
    
    always @ (posedge clk_i or negedge rstn_i)
    begin
        if(~rstn_i)
            q_reg <= 1'b0;
        else
            q_reg <= d;
    end
    
    assign q = q_reg;
endmodule
