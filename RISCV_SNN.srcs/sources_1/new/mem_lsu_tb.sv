`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2026 17:51:01
// Design Name: 
// Module Name: mem_lsu_tb
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

interface memload_if();
//Inputs to DUT
logic [31:0] ld_data_i;
logic [3:0]  ld_mask_i;
logic [1:0]  ld_ext_ctrl_i;
logic        ld_ack_i;
//Outputs from DUT
logic [31:0] ld_data_o;
endinterface

class memloadTransaction;
rand bit [31:0] ld_data_i;
rand bit [3:0]  ld_mask_i;
rand bit [1:0]  ld_ext_ctrl_i;
rand bit        ld_ack_i;
     bit [31:0] ld_data_o;

constraint valid_mask {
    ld_mask_i inside {4'b0000, 4'b0001, 4'b0010, 4'b0100, 4'b1000,
    4'b0011, 4'b1100, 4'b1111};
 }
 
 constraint valid_ctrl {
    ld_ext_ctrl_i inside {`SEXT, `ZEXT};
 }
 
 endclass
 
 class memloadDriver;
    virtual memload_if vif;
    mailbox #(memloadTransaction) gen2drv_mbx;
    mailbox #(memloadTransaction) drv2scb_mbx;
    
    function new(virtual memload_if vif, mailbox #(memloadTransaction) g2d, mailbox #(memloadTransaction) d2s);
        this.vif = vif;
        this.gen2drv_mbx = g2d;
        this.drv2scb_mbx = d2s;
    endfunction
    
    task run();
        forever begin
            memloadTransaction tx;

            gen2drv_mbx.get(tx);

            vif.ld_data_i     = tx.ld_data_i;
            vif.ld_mask_i     = tx.ld_mask_i;
            vif.ld_ext_ctrl_i = tx.ld_ext_ctrl_i;
            vif.ld_ack_i      = tx.ld_ack_i;

            #5;
            tx.ld_data_o     = vif.ld_data_o;

            drv2scb_mbx.put(tx);
        end
    endtask
endclass

class memloadGenerator; 
    mailbox #(memloadTransaction) gen2drv_mbx;
      
    function new(mailbox #(memloadTransaction) g2d);
        this.gen2drv_mbx = g2d;
    endfunction
    
    task run();
       memloadTransaction tx;
       
       for(int i = 0; i < 500; i++) begin
        tx = new();
        if(!tx.randomize()) begin
            $fatal("Transaction Randomization Failed!");
        end
        tx.ld_ack_i = 1'b1;
        gen2drv_mbx.put(tx);
        #10;
       end
     endtask
endclass     
        
class memloadScoreboard;
    mailbox #(memloadTransaction) drv2scb_mbx;
    
    function new(mailbox #(memloadTransaction) d2s);
        this.drv2scb_mbx = d2s;
    endfunction
    
    task run();
        forever begin
            memloadTransaction tx;
            drv2scb_mbx.get(tx);
            check_memload(tx);
        end
     endtask
     
     function void check_memload(input memloadTransaction tx);
        //Golden Rule Expected Result
        bit [31:0] expected_data_o = 32'h0;
        
        if(tx.ld_ack_i) begin
            case(tx.ld_mask_i)
            4'b0001: expected_data_o = {
                (tx.ld_ext_ctrl_i == `SEXT) ? {24{tx.ld_data_i[7]}} :
                (tx.ld_ext_ctrl_i == `ZEXT) ? 24'h0 : 
                                              tx.ld_data_i[31:8], 
                tx.ld_data_i[7:0]
            };

            4'b0010: expected_data_o = 
                (tx.ld_ext_ctrl_i == `SEXT) ? {{24{tx.ld_data_i[15]}}, tx.ld_data_i[15:8]} :
                (tx.ld_ext_ctrl_i == `ZEXT) ? {24'h0, tx.ld_data_i[15:8]}                  :
                                              tx.ld_data_i;

            4'b0100: expected_data_o = 
                (tx.ld_ext_ctrl_i == `SEXT) ? {{24{tx.ld_data_i[23]}}, tx.ld_data_i[23:16]} :
                (tx.ld_ext_ctrl_i == `ZEXT) ? {24'h0, tx.ld_data_i[23:16]}                  :
                                              tx.ld_data_i;

            4'b1000: expected_data_o = 
                (tx.ld_ext_ctrl_i == `SEXT) ? {{24{tx.ld_data_i[31]}}, tx.ld_data_i[31:24]} :
                (tx.ld_ext_ctrl_i == `ZEXT) ? {24'h0, tx.ld_data_i[31:24]}                  :
                                              tx.ld_data_i;

            // --- HALF-WORD LOADS ---
            4'b0011: expected_data_o = 
                (tx.ld_ext_ctrl_i == `SEXT) ? {{16{tx.ld_data_i[15]}}, tx.ld_data_i[15:0]} :
                (tx.ld_ext_ctrl_i == `ZEXT) ? {16'h0, tx.ld_data_i[15:0]}                  :
                                              tx.ld_data_i;

            4'b1100: expected_data_o = 
                (tx.ld_ext_ctrl_i == `SEXT) ? {{16{tx.ld_data_i[31]}}, tx.ld_data_i[31:16]} :
                (tx.ld_ext_ctrl_i == `ZEXT) ? {16'h0, tx.ld_data_i[31:16]}                  :
                                              tx.ld_data_i;

            // --- WORD LOAD ---
            4'b1111: expected_data_o = tx.ld_data_i;
            
            default: expected_data_o = 32'h0;
          endcase
       end
    
    //Inspection
    if(expected_data_o !== tx.ld_data_o) begin
        $error("Memory Load Error! Mask: %4b | Ext_Ctrl: %2b | Expected: %8h | DUT: %8h",
            tx.ld_mask_i, tx.ld_ext_ctrl_i, expected_data_o, tx.ld_data_o);
    end else begin
        case(tx.ld_mask_i)
            4'b0001, 4'b0010, 4'b0100, 4'b1000:
                $display("[PASS] LB/LBU | mask=%4b | ext_ctrl=%2b | raw=%8h | out=%8h",
                    tx.ld_mask_i, tx.ld_ext_ctrl_i, tx.ld_data_i, tx.ld_data_o);
            4'b0011, 4'b1100:
                $display("[PASS] LH/LHU | mask=%4b | ext_ctrl=%2b | raw=%8h | out=%8h",
                    tx.ld_mask_i, tx.ld_ext_ctrl_i, tx.ld_data_i, tx.ld_data_o);
            4'b1111:
                $display("[PASS] LW     | mask=%4b | ext_ctrl=%2b | raw=%8h | out=%8h",
                    tx.ld_mask_i, tx.ld_ext_ctrl_i, tx.ld_data_i, tx.ld_data_o);
            default:
                $display("[PASS] N/A    | mask=%4b | out=%8h", tx.ld_mask_i, tx.ld_data_o);
        endcase
    end

   endfunction
endclass

module mem_lsu_tb ();

memload_if intf();

memloadunit dut_memload(
    .ld_data_i      (intf.ld_data_i),
    .ld_mask_i      (intf.ld_mask_i),
    .ld_ext_ctrl_i  (intf.ld_ext_ctrl_i),
    .ld_ack_i       (intf.ld_ack_i),
    .ld_data_o      (intf.ld_data_o)
);

memloadTransaction tx;
memloadGenerator gen;
memloadDriver drv;
memloadScoreboard scb;
mailbox #(memloadTransaction) m_gen_to_drv;
mailbox #(memloadTransaction) m_drv_to_scb;

initial begin
    $display("=== STARTING MEM LOAD UNIT SIMULATION ===");
    $display("Testing byte/halfword/word load with sign and zero extension");
    $display("500 randomized transactions");

    m_gen_to_drv = new();
    m_drv_to_scb = new();

    gen = new(m_gen_to_drv);
    drv = new(intf, m_gen_to_drv, m_drv_to_scb);
    scb = new(m_drv_to_scb);

    fork
        drv.run();
        scb.run();
    join_none

    gen.run();
    #10;
    $display("=== MEM LOAD UNIT SIMULATION COMPLETE ===");
    $finish;
 end
endmodule   
        
                
        
         