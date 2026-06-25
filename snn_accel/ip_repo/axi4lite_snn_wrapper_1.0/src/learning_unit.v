`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2026 16:06:27
// Design Name: 
// Module Name: learning_unit
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


module learning_unit #(
    parameter WEIGHT_WIDTH = 8,
    parameter TIMESTEP_WIDTH = 8,
    parameter ALPHA_SHIFT = 3,
    parameter TIME_WINDOW = 8,
    parameter BRAM_DEPTH = 6272,
    parameter ADDR_WIDTH = 13
    ) (
    input clk_i,
    input rstn_i,
    
    //learning unit control
    input lr_en_i,
    output reg lr_done_o,
    
    output reg [ADDR_WIDTH - 1 : 0] ram_addr_o,
    output reg ram_rd_en_o,
    output reg ram_wr_en_o,
    input  [63:0] ram_weight_i,
    output [63:0] ram_weight_o,
    
    output [9:0] t_pre_addr_o,
    input [TIMESTEP_WIDTH - 1 : 0] t_pre_data_i,
    
    output [2:0] t_post_addr_o,
    input [63:0] t_post_data_i
    );
    
    reg math_update_en;
    
    assign t_pre_addr_o = ram_addr_o[ADDR_WIDTH - 1 : 3];
    assign t_post_addr_o = ram_addr_o[2:0];
    
    genvar i;
    generate
        for(i = 0 ; i < 8; i = i + 1) begin:stdp_lanes
            wire signed [WEIGHT_WIDTH - 1 : 0] old_weight = ram_weight_i[(i*WEIGHT_WIDTH) +: WEIGHT_WIDTH];
            wire [TIMESTEP_WIDTH - 1 : 0] t_post = t_post_data_i[(i*TIMESTEP_WIDTH) +: TIMESTEP_WIDTH];
            wire signed [WEIGHT_WIDTH - 1 : 0] new_weight;
            
            stdp #(
                .TIMESTEP_WIDTH(TIMESTEP_WIDTH),
                .WEIGHT_WIDTH(WEIGHT_WIDTH),
                .ALPHA_SHIFT(ALPHA_SHIFT),
                .TIME_WINDOW(TIME_WINDOW)
            ) stdp_mod (
                .update_en_i(math_update_en),
                .time_pre_i(t_pre_data_i),
                .time_post_i(t_post),
                .weight_i(old_weight),
                .weight_o(new_weight)
            );
            
            assign ram_weight_o[(i*WEIGHT_WIDTH) +: WEIGHT_WIDTH] = new_weight;
        end
    endgenerate
    //WEIGHT UPDATE FSM
    localparam IDLE = 2'd0;
    localparam FETCH_MEM =  2'd1;
    localparam LATCH_WAIT = 2'd2;
    localparam EXEC = 2'd3;

    reg [1:0] state, next_state;

    // state names: 0=IDLE 1=FETCH_MEM 2=LATCH_WAIT 3=EXEC
    reg [1:0] state_prev_log;
    always @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            state_prev_log <= 2'd0;
        end else begin
            state_prev_log <= state;
            if (state != state_prev_log)
                $display("[LR_UNIT @%0t] STATE %0d -> %0d",
                         $time, state_prev_log, state);
            if (state == 2'd1)  // FETCH_MEM
                $display("[LR_UNIT @%0t] FETCH  addr=%0d", $time, ram_addr_o);
            if (state == 2'd3) begin  // EXEC
                $display("[LR_UNIT @%0t] EXEC   addr=%0d  w_in=%016h  w_out=%016h",
                         $time, ram_addr_o, ram_weight_i, ram_weight_o);
                if (ram_addr_o == BRAM_DEPTH - 1)
                    $display("[LR_UNIT @%0t] LEARNING DONE  (final addr=%0d)", $time, ram_addr_o);
            end
        end
    end
    
    always @ (posedge clk_i or negedge rstn_i) begin
        if(~rstn_i) begin
            state <= IDLE;
            ram_addr_o <= 13'd0;
        end else begin
            state <= next_state;
            
            if(state == IDLE) begin
                ram_addr_o <= 13'd0;
            end else if (state == EXEC) begin
                ram_addr_o <= ram_addr_o + 1'b1;
            end
        end
     end
     
     always @ (*) begin
        next_state = state;
        ram_rd_en_o = 1'b0;
        ram_wr_en_o = 1'b0;
        math_update_en = 1'b0;
        lr_done_o = 1'b0;
        
        case(state)
            IDLE: begin
                if(lr_en_i) begin
                    next_state = FETCH_MEM;
                end
            end
            FETCH_MEM: begin
                ram_rd_en_o = 1'b1;
                next_state = LATCH_WAIT;
            end
            LATCH_WAIT: begin
                next_state = EXEC;
            end
            EXEC: begin
                math_update_en = 1'b1;
                ram_wr_en_o = 1'b1;
                
                if(ram_addr_o == BRAM_DEPTH - 1) begin
                    lr_done_o = 1'b1;
                    next_state = IDLE;
                end else begin
                    next_state = FETCH_MEM;
                end
            end
            default: next_state = IDLE;
        endcase
     end
     
endmodule
