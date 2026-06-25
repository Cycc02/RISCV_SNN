`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.12.2025 22:49:59
// Design Name: 
// Module Name: loadstoreunit
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


module loadstoreunit(
    input [31:0] addr_i,
    input [31:0] data_rd2_i,
    input [3:0] lsu_ctrl_i,
    input  lsu_en_i,
    output [31:0] dtcm_data_o,
    output [29:0] dtcm_addr_o,
    output [3:0] mask_o,
    output [1:0] ld_ext_ctrl_o,
    output dtcm_rd_en_o,
    output dtcm_wr_en_o,
    output lh_cross_o,
    output sh_cross_o,
    output ld_addr_mis_ex_o,
    output st_addr_mis_ex_o
    );
    
    `include "defs.v"
    
    wire [29:0] alu_addr;
    wire [1:0] lane;
    
    reg [31:0]  reg_data;
    reg [3:0]   reg_mask;
    reg [1:0]   reg_ext_ctrl;
    reg         reg_rd;
    reg         reg_wr;
    reg         reg_lh_cross;
    reg         reg_sh_cross;
    reg         reg_ld_excp;
    reg         reg_st_excp;
    
    assign {alu_addr,lane} = addr_i;
    
    always @ (*) begin
        reg_ld_excp = 1'b0;
        reg_st_excp = 1'b0;
        
        if(lsu_en_i) begin
            case(lsu_ctrl_i)
            `SW: if(lane != 2'b00) reg_st_excp = 1'b1;
            `LW: if(lane != 2'b00) reg_ld_excp = 1'b1;
            default: begin
                end
            endcase
        end
    end
        
    always @ (*) begin
        reg_data = 32'h0;
        reg_mask = 4'b0000;
        reg_ext_ctrl = 2'b00;
        reg_rd = 1'b0;
        reg_wr = 1'b0;
        reg_lh_cross = 1'b0;
        reg_sh_cross = 1'b0;

        if (lsu_en_i && !reg_ld_excp && !reg_st_excp) begin
            case(lsu_ctrl_i)
            `SB: begin
                reg_wr = 1'b1;
                case(lane)
                2'b00: begin
                    reg_data = {24'b0,data_rd2_i[7:0]};
                    reg_mask = 4'b0001;
                end
                2'b01: begin
                    reg_data = {16'b0,data_rd2_i[7:0],8'b0};
                    reg_mask = 4'b0010;
                end
                2'b10: begin
                    reg_data = {8'b0, data_rd2_i[7:0], 16'b0};
                    reg_mask = 4'b0100;
                end
                2'b11: begin
                    reg_data = {data_rd2_i[7:0], 24'b0};
                    reg_mask = 4'b1000;
                end
                default: begin
                    reg_data = 32'h0;
                    reg_mask = 4'b0000;
                end
             endcase
           end
            
            `SH: begin
                reg_wr = 1'b1;
                case(lane)
                2'b00: begin
                    reg_data = {16'b0, data_rd2_i[15:0]};
                    reg_mask = 4'b0011;
                end
                2'b01: begin
                    reg_data = {8'b0, data_rd2_i[15:8], data_rd2_i[7:0], 8'b0};
                    reg_mask = 4'b0110;
                end
                2'b10: begin
                    reg_data = {data_rd2_i[15:0], 16'b0};
                    reg_mask = 4'b1100;
                end
                /* lane=0b11: halfword spans word N[31:24] and word N+1[7:0].
                 * Pack low byte into data[31:24] (written to word N via mask[3])
                 * and high byte into data[7:0] (written to word N+1 via sh_cross). */
                2'b11: begin
                    reg_data = {data_rd2_i[7:0], 16'b0, data_rd2_i[15:8]};
                    reg_mask = 4'b1000;
                    reg_sh_cross = 1'b1;
                end
                default: begin
                    reg_data = 32'h0;
                    reg_mask = 4'b0000;
                end
              endcase
            end
            
            `SW: begin
                reg_wr = 1'b1;
                reg_data = data_rd2_i[31:0];
                reg_mask = 4'b1111; 
            end
            
            `LB: begin
                reg_rd = 1'b1;
                reg_ext_ctrl = `SEXT;
                case(lane)
                2'b00: reg_mask = 4'b0001;
                2'b01: reg_mask = 4'b0010;
                2'b10: reg_mask = 4'b0100;
                2'b11: reg_mask = 4'b1000;
                default: reg_mask = 4'b0000;
                endcase
             end 
            `LH:  begin
                reg_rd = 1'b1;
                reg_ext_ctrl = `SEXT;
                case(lane)
                2'b00: reg_mask = 4'b0011;
                2'b01: reg_mask = 4'b0110;
                2'b10: reg_mask = 4'b1100;
                2'b11: begin reg_mask = 4'b1000; reg_lh_cross = 1'b1; end
                default: reg_mask = 4'b0000;
                endcase
             end
            `LW:  begin
                reg_rd = 1'b1;
                reg_mask = 4'b1111;
             end
            `LBU: begin
                reg_rd = 1'b1;
                reg_ext_ctrl = `ZEXT;
                case(lane)
                2'b00: reg_mask = 4'b0001;
                2'b01: reg_mask = 4'b0010;
                2'b10: reg_mask = 4'b0100;
                2'b11: reg_mask = 4'b1000;
                default: reg_mask = 4'b0000;
                endcase
             end
            `LHU: begin
                reg_rd = 1'b1;
                reg_ext_ctrl = `ZEXT;
                case(lane)
                2'b00: reg_mask = 4'b0011;
                2'b01: reg_mask = 4'b0110;
                2'b10: reg_mask = 4'b1100;
                2'b11: begin reg_mask = 4'b1000; reg_lh_cross = 1'b1; end
                default: reg_mask = 4'b0000;
                endcase
             end
            default: begin
                reg_data = 32'h0;
                reg_mask = 4'b0000;
                reg_ext_ctrl = 2'b00;
                reg_rd = 1'b0;
                reg_wr = 1'b0;
            end
          endcase
       end
   end
   
   assign dtcm_addr_o = alu_addr;
   assign dtcm_data_o = reg_data;
   assign dtcm_rd_en_o = reg_rd;
   assign dtcm_wr_en_o = reg_wr;
   assign mask_o = reg_mask;
   assign ld_ext_ctrl_o = reg_ext_ctrl;
   assign lh_cross_o = reg_lh_cross;
   assign sh_cross_o = reg_sh_cross;
   assign ld_addr_mis_ex_o = reg_ld_excp;
   assign st_addr_mis_ex_o = reg_st_excp;

endmodule
