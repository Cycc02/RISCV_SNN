`timescale 1ns / 1ps

module dtcm #(parameter MEM_DEPTH = `DTCM_DEPTH)
(
    input clk_i,
    input rstn_i,
    input rd_en_i,
    input wr_en_i,
    input [1:0] ld_ext_ctrl_i,
    input [3:0] mask_i,
    input [29:0] dtcm_addr_i,
    input [31:0] dtcm_data_i,
    output [1:0]  ld_ext_ctrl_o,
    output [31:0] dtcm_data_o,
    output ld_ack_o,
    output [3:0] ld_mask_o,

    //SNN Port
    input snn_rd_en_i,
    input [11:0] snn_addr_i,
    output [31:0] snn_data_o,

    //Cross-word halfword second-word read port (lh_cross)
    input  [29:0] dtcm_addr2_i,
    output [31:0] dtcm_data2_o
    // sh_cross write removed: riscv_top drives a second write cycle for addr+1
    );

    (* ram_style = "block" *) reg [31:0] reg_mem [0:((MEM_DEPTH)/4)-1];

    reg [31:0] reg_out;
    reg [31:0] reg_portb_out;
    reg [3:0]  reg_ld_mask;
    reg [1:0]  reg_ld_ext_ctrl;
    reg        reg_ld_ack;

    integer _i;
    initial begin
        for (_i = 0; _i < (MEM_DEPTH/4); _i = _i + 1)
            reg_mem[_i] = 32'd0;
        $readmemh("C:/Users/Administrator/Documents/FYP_Docs/RISCV_SNN/dtcm.hex", reg_mem);
    end

    // Port A write — single address per cycle (sh_cross handled externally)
    always @(posedge clk_i) begin
        if (wr_en_i) begin
            if (mask_i[0]) reg_mem[dtcm_addr_i[11:0]][7:0]   <= dtcm_data_i[7:0];
            if (mask_i[1]) reg_mem[dtcm_addr_i[11:0]][15:8]  <= dtcm_data_i[15:8];
            if (mask_i[2]) reg_mem[dtcm_addr_i[11:0]][23:16] <= dtcm_data_i[23:16];
            if (mask_i[3]) reg_mem[dtcm_addr_i[11:0]][31:24] <= dtcm_data_i[31:24];
        end
    end

    // Port A read — synchronous (BRAM); control signals registered to match data latency
    always @(posedge clk_i) begin
        if (~rstn_i) begin
            reg_out        <= 32'h0;
            reg_ld_ack     <= 1'b0;
            reg_ld_mask    <= 4'b0;
            reg_ld_ext_ctrl <= 2'b00;
        end else begin
            reg_out        <= rd_en_i ? reg_mem[dtcm_addr_i[11:0]] : 32'h0;
            reg_ld_ack     <= rd_en_i;
            reg_ld_mask    <= mask_i;
            reg_ld_ext_ctrl <= ld_ext_ctrl_i;
        end
    end

    assign dtcm_data_o  = reg_out;
    assign ld_ack_o     = reg_ld_ack;
    assign ld_mask_o    = reg_ld_mask;
    assign ld_ext_ctrl_o = reg_ld_ext_ctrl;

    // Port B — SNN read or cross-word read, multiplexed (SNN takes priority)
    wire [11:0] portb_addr = snn_rd_en_i ? snn_addr_i : dtcm_addr2_i[11:0];

    always @(posedge clk_i) begin
        reg_portb_out <= reg_mem[portb_addr];
    end

    assign snn_data_o   = reg_portb_out;
    assign dtcm_data2_o = reg_portb_out;

endmodule
