`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.12.2025 16:55:02
// Design Name: 
// Module Name: memloadunit
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


module memloadunit(
    input [31:0] ld_data_i,
    input [3:0]  ld_mask_i,
    input [1:0]  ld_ext_ctrl_i,
    input        ld_ack_i,
    output [31:0] ld_data_o
    );
    
    reg [31:0] reg_data_out;
    
    always @ (*) begin
        if(ld_ack_i) begin
            case(ld_mask_i)
            4'b0001: begin
                if(ld_ext_ctrl_i == `SEXT)
                    reg_data_out = {{24{ld_data_i[7]}},ld_data_i[7:0]};
                else if (ld_ext_ctrl_i == `ZEXT)
                    reg_data_out = {24'b0,ld_data_i[7:0]};
                else
                    reg_data_out = ld_data_i;
            end
            
            4'b0010: begin
                if(ld_ext_ctrl_i == `SEXT)
                    reg_data_out = {{24{ld_data_i[15]}},ld_data_i[15:8]};
                else if (ld_ext_ctrl_i == `ZEXT)
                    reg_data_out = {24'b0,ld_data_i[15:8]};
                else
                    reg_data_out = ld_data_i;
            end
                    
            4'b0100: begin
                if(ld_ext_ctrl_i == `SEXT)
                    reg_data_out = {{24{ld_data_i[23]}},ld_data_i[23:16]};
                else if (ld_ext_ctrl_i == `ZEXT)
                    reg_data_out = {24'b0,ld_data_i[23:16]};
                else
                    reg_data_out = ld_data_i;
            end
            
            4'b1000: begin
                if(ld_ext_ctrl_i == `SEXT)
                    reg_data_out = {{24{ld_data_i[31]}},ld_data_i[31:24]};
                else if (ld_ext_ctrl_i == `ZEXT)
                    reg_data_out = {24'b0,ld_data_i[31:24]};
                else
                    reg_data_out = ld_data_i;
            end
            
            4'b0011: begin
                if(ld_ext_ctrl_i == `SEXT)
                    reg_data_out = {{16{ld_data_i[15]}},ld_data_i[15:0]};
                else if (ld_ext_ctrl_i == `ZEXT)
                    reg_data_out = {16'b0,ld_data_i[15:0]};
                else
                    reg_data_out = ld_data_i;
           end

           4'b0110: begin
                if(ld_ext_ctrl_i == `SEXT)
                    reg_data_out = {{16{ld_data_i[23]}},ld_data_i[23:8]};
                else if (ld_ext_ctrl_i == `ZEXT)
                    reg_data_out = {16'b0,ld_data_i[23:8]};
                else
                    reg_data_out = ld_data_i;
           end
           
           4'b1100: begin
                if(ld_ext_ctrl_i == `SEXT)
                    reg_data_out = {{16{ld_data_i[31]}},ld_data_i[31:16]};
                else if (ld_ext_ctrl_i == `ZEXT)
                    reg_data_out = {16'b0,ld_data_i[31:16]};
                else
                    reg_data_out = ld_data_i;
           end
           
           4'b1111: reg_data_out = ld_data_i;
           default: reg_data_out = 32'h0;
         endcase
       end
       else
            reg_data_out = 32'h0;
    end
   
   assign ld_data_o = reg_data_out;         
        
endmodule
