`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.12.2025 22:24:10
// Design Name: 
// Module Name: hazardunit
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


module hazardunit(
    input [4:0] dec_rs1_i,
    input [4:0] dec_rs2_i,
    input [4:0] exec_rs1_i,
    input [4:0] exec_rs2_i,
    input [4:0] exec_rd_i,
    input [4:0] mem_rd_i,
    input [4:0] wb_rd_i,
    input dtcm_rd_i,
    input exec_regfile_we_i,
    input wb_regfile_we_i,
    
    output [1:0] mux_rs1_o,
    output [1:0] mux_rs2_o,
    output stall_o
    );
    
    `include "defs.v"
    
    reg [1:0]   reg_mux_rs1;
    reg [1:0]   reg_mux_rs2;
    
    //Forward Operation
    always @ (*) begin
        if((exec_rs1_i == mem_rd_i) && exec_regfile_we_i && (mem_rd_i != 5'b0)) begin
            reg_mux_rs1 = `FWD_MEM;
        end
        else if ((exec_rs1_i == wb_rd_i) && wb_regfile_we_i && (wb_rd_i != 5'b0))begin
            reg_mux_rs1 = `FWD_WB;
        end
        else begin
            reg_mux_rs1 = `NORMAL_OP;
        end
    end
            
    always @ (*) begin
        if ((exec_rs2_i == mem_rd_i) && exec_regfile_we_i && (mem_rd_i != 5'b0))begin
            reg_mux_rs2 = `FWD_MEM;
        end    
        else if ((exec_rs2_i == wb_rd_i) && wb_regfile_we_i && (wb_rd_i != 5'b0))begin
            reg_mux_rs2 = `FWD_WB;
        end
        else begin
            reg_mux_rs2 = `NORMAL_OP;
        end
    end
    
    assign mux_rs1_o    = reg_mux_rs1;
    assign mux_rs2_o    = reg_mux_rs2;
    
    //Load-Use Operation
    assign stall_o = dtcm_rd_i &&
                    (exec_rd_i != 5'b0) && 
                    (dec_rs1_i == exec_rd_i ||
                    dec_rs2_i == exec_rd_i);             
                   
endmodule
