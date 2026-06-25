`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2026 23:37:12
// Design Name: 
// Module Name: spike_time_mem
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


module spike_time_mem #(
    parameter DEPTH = 64, //64 Hidden Layer
    parameter TIMESTEP_WIDTH = 16,
    parameter ADDR_WIDTH = 6 
)(
    input clk,
    
    //Port A (Read Spike)
    input rd_en,
    input [ADDR_WIDTH - 1 : 0] rd_addr,
    output reg [TIMESTEP_WIDTH - 1 :0] rd_tstep,
    
    //Port B (Write Spike)
    input wr_en,
    input [ADDR_WIDTH - 1 : 0] wr_addr,
    input [TIMESTEP_WIDTH - 1 : 0] wr_tstep
);

    reg [TIMESTEP_WIDTH - 1 : 0] tstep_mem [0 : DEPTH - 1];
    
    always @ (posedge clk) begin
        if(rd_en) begin
            rd_tstep <= tstep_mem[rd_addr];
        end
    end
    
    always @ (posedge clk) begin
        if(wr_en) begin
            tstep_mem[wr_addr] <= wr_tstep;
        end
    end
    
endmodule
