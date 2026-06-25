`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.12.2025 13:43:44
// Design Name: 
// Module Name: exec_lsu_tb
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


module exec_lsu_tb();
reg [31:0]  addr_i;
reg [31:0]  data_rd2_i;
reg [3:0]   lsu_ctrl_i;
reg         lsu_en_i;

wire [31:0] dtcm_data_o;
wire [29:0] dtcm_addr_o;
wire [3:0]  mask_o;
wire [1:0]  ld_ext_ctrl_o;
wire        dtcm_rd_en_o;
wire        dtcm_wr_en_o;
wire        ld_addr_mis_ex_o;
wire        st_addr_mis_ex_o;

`include "defs.v"

loadstoreunit dut_lsu (
    .addr_i            (addr_i),
    .data_rd2_i        (data_rd2_i),
    .lsu_ctrl_i        (lsu_ctrl_i),
    .lsu_en_i          (lsu_en_i),

    .dtcm_data_o       (dtcm_data_o),
    .dtcm_addr_o       (dtcm_addr_o),
    .mask_o            (mask_o),
    .ld_ext_ctrl_o     (ld_ext_ctrl_o),
    .dtcm_rd_en_o      (dtcm_rd_en_o),
    .dtcm_wr_en_o      (dtcm_wr_en_o),
    .ld_addr_mis_ex_o  (ld_addr_mis_ex_o),
    .st_addr_mis_ex_o  (st_addr_mis_ex_o)
);

int load_op[] = '{`LB, `LH, `LW, `LBU, `LHU};
int store_op[] = '{`SB, `SH, `SW};
logic [1:0] lane;

reg [3:0] expected_mask;
reg ld_excp_error;
reg st_excp_error;
reg mask_error;
reg rd_error;
reg wr_error;
reg dout_error;
reg addr_error;
reg ld_ctrl_error;

reg expected_rd;
reg expected_wr;
reg expected_ld_excp;
reg expected_st_excp;
reg [1:0] expected_ld_ctrl;
reg [31:0] expected_dout;
reg [29:0] expected_addr;
int op_pass, op_fail;


initial begin
lsu_en_i = 1'b1;
ld_excp_error = 1'b0;
st_excp_error = 1'b0;
mask_error = 1'b0;
ld_ctrl_error = 1'b0;
rd_error = 1'b0;
wr_error = 1'b0;
dout_error = 1'b0;
addr_error = 1'b0;

expected_ld_excp = 1'b0;
expected_st_excp = 1'b0;
expected_rd = 1'b0;
expected_wr = 1'b0;
expected_mask = 4'b0000;
expected_ld_ctrl = 2'b00;
expected_dout = 32'h0;
expected_addr = 30'h0;

//Load Operation
foreach (load_op[i]) begin
    lsu_ctrl_i = load_op[i];
    op_pass = 0; op_fail = 0;
    repeat(5) begin
        #($urandom_range(5,10));
        
        expected_rd = 1'b0;
        expected_wr = 1'b0;
        expected_mask = 4'b0000;
        expected_ld_ctrl = 2'b0;
        expected_ld_excp = 1'b0;
        expected_st_excp = 1'b0;
        
        addr_i = $urandom();
        data_rd2_i = $urandom();
        lane = addr_i[1:0];
        
        expected_addr = addr_i[31:2];
        
        case(load_op[i])
        `LB: begin
            expected_rd = 1'b1;
            expected_ld_ctrl = `SEXT;
            if(lane == 2'b00) expected_mask = 4'b0001;
            else if (lane == 2'b01) expected_mask = 4'b0010;
            else if (lane == 2'b10) expected_mask = 4'b0100;
            else if (lane == 2'b11) expected_mask = 4'b1000;
            else expected_ld_excp = 1'b1;
        end
        `LH: begin
            expected_rd = 1'b1;
            expected_ld_ctrl = `SEXT;
            if(lane == 2'b00) expected_mask = 4'b0011;
            else if (lane == 2'b10) expected_mask = 4'b1100;
            else expected_ld_excp = 1'b1;
        end
        `LW: begin
            expected_rd = 1'b1;
            expected_mask = 4'b1111;
            if(lane !== 2'b00) expected_ld_excp = 1'b1;
        end
        `LBU: begin
            expected_rd = 1'b1;
            expected_ld_ctrl = `ZEXT;
            if(lane == 2'b00) expected_mask = 4'b0001;
            else if (lane == 2'b01) expected_mask = 4'b0010;
            else if (lane == 2'b10) expected_mask = 4'b0100;
            else if (lane == 2'b11) expected_mask = 4'b1000;
            else expected_ld_excp = 1'b1;
        end
        `LHU: begin
            expected_rd = 1'b1;
            expected_ld_ctrl = `ZEXT;
            if(lane == 2'b00) expected_mask = 4'b0011;
            else if (lane == 2'b10) expected_mask = 4'b1100;
            else expected_ld_excp = 1'b1;
       end
       endcase
       
       #1;
       
       //Inspection
       ld_excp_error = (expected_ld_excp !== ld_addr_mis_ex_o);
       if(ld_excp_error) $error("Load Exception Error, Operation: %4b | Expected LD Error: %1b | LSU LD Error: %1b", load_op[i], expected_ld_excp, ld_addr_mis_ex_o);
       mask_error = !expected_ld_excp && !expected_st_excp &&(expected_mask !== mask_o);
       if(mask_error) $error("Load Mask Error, Operation: %4b | Expected Mask: %4b | LSU Mask: %4b", load_op[i], expected_mask, mask_o);
       ld_ctrl_error = !expected_ld_excp && !expected_st_excp &&(expected_ld_ctrl !== ld_ext_ctrl_o);
       if(ld_ctrl_error) $error("Load Control Error, Operation: %4b | Expected Load Control: %2b | LSU Load Control: %2b", load_op[i], expected_ld_ctrl, ld_ext_ctrl_o);  
       rd_error = !expected_ld_excp && !expected_st_excp &&(expected_rd !== dtcm_rd_en_o);
       if(rd_error) $error("Load Read Enable Error, Operation: %4b | Expected Read Enable: %1b | LSU Read Enable: %1b", load_op[i], expected_rd, dtcm_rd_en_o);
       wr_error = !expected_ld_excp && !expected_st_excp &&(expected_wr != dtcm_wr_en_o);
       if(wr_error) $error("Load Write Enable Error, Operation: %4b | Expected Write Enable: %1b | LSU Write Enable: %1b", load_op[i], expected_wr, dtcm_wr_en_o);   
        addr_error = !expected_ld_excp && !expected_st_excp &&(expected_addr !== dtcm_addr_o);
        if(addr_error) $error("LoadAddress Error, Operation: %4b | Expected Addr: %1b | LSU Addr: %1b", store_op[i], expected_addr, dtcm_addr_o);
        if(!ld_excp_error && !mask_error && !ld_ctrl_error && !rd_error && !wr_error && !addr_error)
            op_pass++;
        else
            op_fail++;
    end
    case(load_op[i])
        `LB:  $display("  LB  (Load Byte Signed)       : %s (%0d/5)", op_fail ? "FAIL" : "PASS", op_pass);
        `LH:  $display("  LH  (Load Halfword Signed)   : %s (%0d/5)", op_fail ? "FAIL" : "PASS", op_pass);
        `LW:  $display("  LW  (Load Word)              : %s (%0d/5)", op_fail ? "FAIL" : "PASS", op_pass);
        `LBU: $display("  LBU (Load Byte Unsigned)     : %s (%0d/5)", op_fail ? "FAIL" : "PASS", op_pass);
        `LHU: $display("  LHU (Load Halfword Unsigned) : %s (%0d/5)", op_fail ? "FAIL" : "PASS", op_pass);
    endcase
end
$display("Load Operation Validation Complete");

foreach (store_op[i]) begin
    lsu_ctrl_i = store_op[i];
    op_pass = 0; op_fail = 0;
    repeat(5) begin
        #($urandom_range(5,10));
        
        expected_rd = 1'b0;
        expected_wr = 1'b0;
        expected_mask = 4'b0000;
        expected_ld_ctrl = 2'b0;        
        expected_st_excp = 1'b0;
        expected_ld_excp = 1'b0;
        
        addr_i = $urandom();
        data_rd2_i = $urandom();
        
        lane = addr_i[1:0];
        expected_addr = addr_i[31:2];
        
        case(store_op[i])
        `SB: begin
            expected_wr = 1'b1;
            expected_dout = {24'h0, data_rd2_i[7:0]} << (lane * 8);
            expected_mask = (1'b1 << lane);
        end
        `SH: begin
            expected_wr = 1'b1;
            expected_dout = {16'h0, data_rd2_i[15:0]} << (lane[1] * 16);
            expected_mask = 4'b0011 << (lane[1] * 2);
            expected_st_excp = lane[0];
        end
        `SW: begin
            expected_wr = 1'b1;
            expected_dout = data_rd2_i[31:0];
            expected_st_excp = lane[0] || lane[1];
            expected_mask = 4'b1111;
        end
        endcase
        
        #1;
        
        st_excp_error = (expected_st_excp !== st_addr_mis_ex_o);
        if(st_excp_error) $error("Store Excp Error, Operation: %4b | Expected Excp: %1b | LSU Excp: %1b", store_op[i], expected_st_excp, st_addr_mis_ex_o);  
        wr_error = !expected_ld_excp && !expected_st_excp &&(expected_wr !== dtcm_wr_en_o);
        if(wr_error) $error("Store Write Enable Error, Operation: %4b | Expected Write Enable: %1b | LSU Write Enable: %1b", store_op[i], expected_wr, dtcm_wr_en_o);
        rd_error = !expected_ld_excp && !expected_st_excp &&(expected_rd !== dtcm_rd_en_o);
        if(rd_error) $error("Store Read Enable Error,  Operation: %4b | Expected Read Enable: %1b | LSU Read Enable: %1b", store_op[i], expected_rd, dtcm_rd_en_o);    
        dout_error = !expected_ld_excp && !expected_st_excp &&(expected_dout !== dtcm_data_o);
        if(dout_error) $error("Store Dout Error, Operation: %4b | Expected Dout: %1b | LSU Dout: %1b", store_op[i], expected_dout, dtcm_data_o);
        mask_error = !expected_ld_excp && !expected_st_excp &&(expected_mask !== mask_o);
        if(mask_error) $error("Store Mask Error, Operation: %4b | Expected Mask: %1b | LSU Mask: %1b", store_op[i], expected_mask, mask_o);    
        addr_error = !expected_ld_excp && !expected_st_excp &&(expected_addr !== dtcm_addr_o);
        if(addr_error) $error("Store Address Error, Operation: %4b | Expected Addr: %1b | LSU Addr: %1b", store_op[i], expected_addr, dtcm_addr_o);
        if(!st_excp_error && !wr_error && !rd_error && !dout_error && !mask_error && !addr_error)
            op_pass++;
        else
            op_fail++;
    end
    case(store_op[i])
        `SB: $display("  SB  (Store Byte)             : %s (%0d/5)", op_fail ? "FAIL" : "PASS", op_pass);
        `SH: $display("  SH  (Store Halfword)         : %s (%0d/5)", op_fail ? "FAIL" : "PASS", op_pass);
        `SW: $display("  SW  (Store Word)             : %s (%0d/5)", op_fail ? "FAIL" : "PASS", op_pass);
    endcase
end
$display("Store Operation Validation Complete");
 #1 $finish;
end

endmodule
