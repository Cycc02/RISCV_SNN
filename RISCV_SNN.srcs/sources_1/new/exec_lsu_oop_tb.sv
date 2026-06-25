`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2026 18:26:48
// Design Name: 
// Module Name: exec_lsu_oop_tb
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
`include "defs.v"

interface lsu_if();
//Inputs to DUT
logic [31:0] addr_i;
logic [31:0] data_rd2_i;
logic [3:0]  lsu_ctrl_i;
logic        lsu_en_i;

// Output from DUT
logic [31:0] dtcm_data_o;
logic [29:0] dtcm_addr_o;
logic [3:0]  mask_o;
logic [1:0]  ld_ext_ctrl_o;
logic        dtcm_rd_en_o;
logic        dtcm_wr_en_o;
logic        ld_addr_mis_ex_o;
logic        st_addr_mis_ex_o;
endinterface

class LsuTransaction;
rand bit [31:0] addr_i;
rand bit [31:0] data_rd2_i;
rand bit [3:0]  lsu_ctrl_i;
rand bit        lsu_en_i;

bit [31:0]  dtcm_data_o;
bit [29:0]  dtcm_addr_o;
bit [3:0]   mask_o;
bit [1:0]   ld_ext_ctrl_o;
bit         dtcm_rd_en_o;
bit         dtcm_wr_en_o;
bit         ld_addr_mis_ex_o;
bit         st_addr_mis_ex_o;

constraint valid_ctrl {
lsu_ctrl_i inside {`LB, `LH, `LW, `LBU, `LHU, `SB, `SH, `SW};
}

function void display(input string name);
    $display("[%s] Addr: %0h | Ctrl: %0b | Mask: %0b | Misaligned Excp: %0b", name, addr_i, lsu_ctrl_i, mask_o, (ld_addr_mis_ex_o | st_addr_mis_ex_o));
endfunction
endclass

class LsuDriver;
    virtual lsu_if vif;
    mailbox #(LsuTransaction) gen2drv_mbx; //#(LsuTransaction) is to fix the specific class can be transmit / receive from this mailbox
    mailbox #(LsuTransaction) drv2scb_mbx;
    
    function new(virtual lsu_if vif, mailbox #(LsuTransaction) g2d, mailbox #(LsuTransaction) d2s);
        this.vif = vif;
        this.gen2drv_mbx = g2d;
        this.drv2scb_mbx = d2s;
    endfunction
    
    task run();
        forever begin
        LsuTransaction tx;
        
        gen2drv_mbx.get(tx);
        
        vif.addr_i = tx.addr_i;
        vif.data_rd2_i = tx.data_rd2_i;
        vif.lsu_ctrl_i = tx.lsu_ctrl_i;
        vif.lsu_en_i = tx.lsu_en_i;
        
        #5; //Wait for combinational logic to settle
        
        tx.dtcm_data_o      = vif.dtcm_data_o;
        tx.dtcm_addr_o      = vif.dtcm_addr_o;
        tx.mask_o           = vif.mask_o;
        tx.ld_ext_ctrl_o    = vif.ld_ext_ctrl_o;
        tx.dtcm_wr_en_o     = vif.dtcm_wr_en_o;
        tx.dtcm_rd_en_o     = vif.dtcm_rd_en_o;
        tx.ld_addr_mis_ex_o = vif.ld_addr_mis_ex_o;
        tx.st_addr_mis_ex_o = vif.st_addr_mis_ex_o;
        
        drv2scb_mbx.put(tx);
        end
     endtask
endclass

class LsuScoreboard;
    mailbox #(LsuTransaction) drv2scb_mbx;
    
    function new(mailbox #(LsuTransaction) d2s);
        this.drv2scb_mbx = d2s;
    endfunction
    
    task run();
        forever begin
            LsuTransaction tx;
            drv2scb_mbx.get(tx);
            checklsu(tx);
        end
    endtask
    
    function void checklsu(input LsuTransaction tx);
        //Local Golden Rule Expected Results
        bit        expected_rd      = 1'b0;
        bit        expected_wr      = 1'b0;
        bit [3:0]  expected_mask    = 4'b0000;
        bit [1:0]  expected_ld_ctrl = 2'b00;
        bit        expected_ld_excp = 1'b0;
        bit        expected_st_excp = 1'b0;
        bit [31:0] expected_dout    = 32'h0;
        
        bit [29:0] expected_addr    = tx.addr_i[31:2];
        bit [1:0]  lane             = tx.addr_i[1:0];
        
        if (tx.lsu_en_i) begin
            case(tx.lsu_ctrl_i)
                // --- LOAD OPERATIONS ---
                `LB: begin
                    expected_rd = 1'b1;
                    expected_ld_ctrl = `SEXT;
                    if(lane == 2'b00) expected_mask = 4'b0001;
                    else if (lane == 2'b01) expected_mask = 4'b0010;
                    else if (lane == 2'b10) expected_mask = 4'b0100;
                    else if (lane == 2'b11) expected_mask = 4'b1000;
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
                end
                `LHU: begin
                    expected_rd = 1'b1;
                    expected_ld_ctrl = `ZEXT;
                    if(lane == 2'b00) expected_mask = 4'b0011;
                    else if (lane == 2'b10) expected_mask = 4'b1100;
                    else expected_ld_excp = 1'b1;
                end

                // --- STORE OPERATIONS ---
                `SB: begin
                    expected_wr = 1'b1;
                    expected_dout = {24'h0, tx.data_rd2_i[7:0]} << (lane * 8);
                    expected_mask = (1'b1 << lane);
                end
                `SH: begin
                    expected_wr = 1'b1;
                    expected_dout = {16'h0, tx.data_rd2_i[15:0]} << (lane[1] * 16);
                    expected_mask = 4'b0011 << (lane[1] * 2);
                    expected_st_excp = lane[0];
                end
                `SW: begin
                    expected_wr = 1'b1;
                    expected_dout = tx.data_rd2_i[31:0];
                    expected_st_excp = lane[0] || lane[1];
                    expected_mask = 4'b1111;
                end
            endcase
        end
        
        //Inspection
        // Check Exceptions First
        if (expected_ld_excp !== tx.ld_addr_mis_ex_o) 
            $error("Load Exception Error! Op: %4b | Expected: %1b | Actual: %1b", tx.lsu_ctrl_i, expected_ld_excp, tx.ld_addr_mis_ex_o);
            
        if (expected_st_excp !== tx.st_addr_mis_ex_o) 
            $error("Store Exception Error! Op: %4b | Expected: %1b | Actual: %1b", tx.lsu_ctrl_i, expected_st_excp, tx.st_addr_mis_ex_o);

        // Check normal outputs only if there are no exceptions
        if (!expected_ld_excp && !expected_st_excp) begin
            
            if (expected_mask !== tx.mask_o) 
                $error("Mask Error! Op: %4b | Expected: %4b | Actual: %4b", tx.lsu_ctrl_i, expected_mask, tx.mask_o);
                
            if (expected_rd !== tx.dtcm_rd_en_o) 
                $error("Read Enable Error! Op: %4b | Expected: %1b | Actual: %1b", tx.lsu_ctrl_i, expected_rd, tx.dtcm_rd_en_o);
                
            if (expected_wr !== tx.dtcm_wr_en_o) 
                $error("Write Enable Error! Op: %4b | Expected: %1b | Actual: %1b", tx.lsu_ctrl_i, expected_wr, tx.dtcm_wr_en_o);
                
            if (expected_addr !== tx.dtcm_addr_o) 
                $error("Address Error! Op: %4b | Expected: %h | Actual: %h", tx.lsu_ctrl_i, expected_addr, tx.dtcm_addr_o);

            // Only check load extension control if it's a read
            if (expected_rd && (expected_ld_ctrl !== tx.ld_ext_ctrl_o)) 
                $error("Load Control Error! Op: %4b | Expected: %2b | Actual: %2b", tx.lsu_ctrl_i, expected_ld_ctrl, tx.ld_ext_ctrl_o);

            // Only check data output if it's a write
            if (expected_wr && (expected_dout !== tx.dtcm_data_o)) 
                $error("Data Out Error! Op: %4b | Expected: %h | Actual: %h", tx.lsu_ctrl_i, expected_dout, tx.dtcm_data_o);
                
        end
    endfunction
endclass

module exec_lsu_oop_tb();

lsu_if intf();

loadstoreunit dut_lsu (
    .addr_i            (intf.addr_i),
    .data_rd2_i        (intf.data_rd2_i),
    .lsu_ctrl_i        (intf.lsu_ctrl_i),
    .lsu_en_i          (intf.lsu_en_i),

    .dtcm_data_o       (intf.dtcm_data_o),
    .dtcm_addr_o       (intf.dtcm_addr_o),
    .mask_o            (intf.mask_o),
    .ld_ext_ctrl_o     (intf.ld_ext_ctrl_o),
    .dtcm_rd_en_o      (intf.dtcm_rd_en_o),
    .dtcm_wr_en_o      (intf.dtcm_wr_en_o),
    .ld_addr_mis_ex_o  (intf.ld_addr_mis_ex_o),
    .st_addr_mis_ex_o  (intf.st_addr_mis_ex_o)
);

LsuDriver drv;
LsuScoreboard scb;
LsuTransaction tx;
mailbox #(LsuTransaction) m_gen_to_drv;
mailbox #(LsuTransaction) m_drv_to_scb;

initial begin
    m_gen_to_drv = new();
    m_drv_to_scb = new();
    
    drv = new(intf, m_gen_to_drv, m_drv_to_scb);
    scb = new(m_drv_to_scb);
    
    fork
        drv.run();
        scb.run();
    join_none //Let the checking operation run in background
    
    for (int i = 0; i < 500 ; i++) begin
        tx = new();
        
        if(!tx.randomize()) begin
            $fatal("Transaction Randomization Failed!");
        end
        tx.lsu_en_i = 1'b1;
        m_gen_to_drv.put(tx);
        #10;
     end
     #10 $finish;
end
endmodule

         
            


    
    
    
    
    
    


