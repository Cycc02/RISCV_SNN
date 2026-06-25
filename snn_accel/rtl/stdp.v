`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2026 15:29:04
// Design Name: 
// Module Name: stdp
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


module stdp #(
    parameter TIMESTEP_WIDTH = 8,
    parameter WEIGHT_WIDTH = 8,
    parameter ALPHA_SHIFT = 3,
    parameter TIME_WINDOW = 8
   )(
    input update_en_i, 
   
    input [TIMESTEP_WIDTH - 1 :0] time_pre_i,
    input [TIMESTEP_WIDTH - 1 :0] time_post_i,
    input signed [WEIGHT_WIDTH - 1:0] weight_i,
    
    output reg signed [WEIGHT_WIDTH - 1 : 0] weight_o
    );
    
    localparam signed [WEIGHT_WIDTH : 0] MAX_WEIGHT = ((1 << (WEIGHT_WIDTH - 1)) - 1);
    localparam signed [WEIGHT_WIDTH : 0] MIN_WEIGHT = -(1 << (WEIGHT_WIDTH - 1));
        
    wire signed [TIMESTEP_WIDTH : 0] dt; //Extra 1bit to prevent overflow
    
    assign dt = {1'b0, time_post_i} - {1'b0, time_pre_i};
    
    reg signed [WEIGHT_WIDTH : 0] delta;
    reg signed [WEIGHT_WIDTH : 0] dw;
    reg signed [WEIGHT_WIDTH : 0] new_weight_calc;
        
    always @ (*) begin
        weight_o = weight_i;
        new_weight_calc = 0;
        delta = 0;
        dw = 0;
        if(update_en_i) begin
            if(dt > 0 && dt <= TIME_WINDOW) begin
                delta = MAX_WEIGHT - weight_i;
                dw = delta >>> ALPHA_SHIFT;
                new_weight_calc = weight_i + dw;
                weight_o = new_weight_calc[WEIGHT_WIDTH - 1 : 0];
                $display("[STDP    @%0t] POTENTIATE  dt=%0d  w_in=%0d  dw=+%0d  w_out=%0d",
                         $time, $signed(dt), $signed(weight_i), $signed(dw), $signed(weight_o));
            end
            else if (dt < 0 && dt >= -TIME_WINDOW) begin
                delta = weight_i - MIN_WEIGHT;
                dw = delta >>> ALPHA_SHIFT;
                new_weight_calc = weight_i - dw;
                weight_o = new_weight_calc[WEIGHT_WIDTH - 1 : 0];
                $display("[STDP    @%0t] DEPRESS     dt=%0d  w_in=%0d  dw=-%0d  w_out=%0d",
                         $time, $signed(dt), $signed(weight_i), $signed(dw), $signed(weight_o));
            end
       end
    end
endmodule
