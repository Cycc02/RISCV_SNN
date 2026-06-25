`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2026 20:39:17
// Design Name: 
// Module Name: aer_scan_tb
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

interface aer_vif (input logic clk_i, input logic rstn_i);
    logic aer_en_i;
    logic [783:0] data_i;
    logic fifo_full_i;
    
    logic [9:0] aer_data_o;
    logic aer_valid_o;
    logic scan_done_o;
endinterface

class aer_transaction;
    //Declare random input image bits
    rand bit [783:0] img_pxl;
    constraint c_not_empty {img_pxl != 784'd0;}
    //A Queue FIFO of integers (Expected Output)
    int expected_spikes[$];
    
    function void calc_expected ();
        expected_spikes.delete();
        for(int i = 0; i < 784; i = i + 1) begin
            if(img_pxl[i] == 1'b1) begin
                expected_spikes.push_back(i);
            end
        end
    endfunction
 endclass
 
class aer_generator; //Simulates the Golden Reference Model
    //Declare the mailbox
    mailbox #(aer_transaction) gen2drv; //Mailbox between gen and drv
    mailbox #(aer_transaction) gen2scb; //Mailbox between gen and scb
    
    //Control Variable
    int num_transactions = 5;
    
    //Constructor (Wire the mailbox)
    function new(mailbox #(aer_transaction) drv_mbx, mailbox #(aer_transaction) scb_mbx);
        this.gen2drv = drv_mbx;
        this.gen2scb = scb_mbx;
    endfunction
    
    //Main Execution Loop
    task run();
        aer_transaction tx;
        for(int i = 0; i < num_transactions ; i = i + 1) begin
            //Instantiate blank packet in memory
            tx = new();
            assert(tx.randomize());
            tx.calc_expected();
            
            //Put the copies of packets into the mailboxes
            gen2drv.put(tx);
            gen2scb.put(tx);
            
            $display("[GENERATOR] Created Random Image %0d: %b", i, tx.img_pxl);
        
        end
    endtask
 endclass
 
class aer_driver; //Simulates the outside world of Hardware Design

    //Pointer to Verilog Wires, connection between simulator and top_level Verilog module
    virtual aer_vif vif;
    //To send testing data to driver
    mailbox #(aer_transaction) gen2drv;
    //Constructor
    function new(virtual aer_vif vif_pointer, mailbox #(aer_transaction) mbx_pointer);
        this.vif = vif_pointer;
        this.gen2drv = mbx_pointer;
    endfunction
    
    task run();
        aer_transaction tx; //Blank variable to hold the packet
        forever begin
            //Wait for packet to be received
            gen2drv.get(tx);
            $display("[DRIVER] Driving Image %b into hardware...", tx.img_pxl);
            
            //Software-to-Hardware Translation
            @(posedge vif.clk_i);
            vif.data_i <= tx.img_pxl;
            vif.aer_en_i <= 1'b1;
            
            @(posedge vif.clk_i);
            vif.aer_en_i <= 1'b0;
            
            wait(vif.scan_done_o == 1'b1);
       end
    endtask
 endclass
 
 class aer_scoreboard;
    virtual aer_vif vif; //Pointer to physical hardware
    mailbox #(aer_transaction) gen2scb; //Get reference answer from generator
    
    //Constructor
    function new(virtual aer_vif vif_pointer, mailbox #(aer_transaction) mbx_pointer);
        this.vif = vif_pointer;
        this.gen2scb = mbx_pointer;
    endfunction
    
    task run();
        aer_transaction tx;
        int actual, expected;
        
        forever begin
            //Wait generator process finish golden reference model and give the answer
            gen2scb.get(tx);
            $display("[SCOREBOARD] Watching Hardware Image: %b", tx.img_pxl);
            
            while(vif.scan_done_o == 1'b0) begin
                @(posedge vif.clk_i);
                
                //Wait for spike 
                if(vif.aer_valid_o == 1'b1) begin
                    actual = vif.aer_data_o;
                    //Ensure execution of golden reference model is complete
                    if(tx.expected_spikes.size() > 0) begin
                        expected = tx.expected_spikes.pop_front();
                        
                        if(actual == expected) begin
                            $display("[PASS] Spike Match %0d", actual);
                        end else begin
                            $error("[ERROR] Spike Mismatch | Actual: %0d | Expected: %0d", actual, expected);
                        end
                    end else begin
                        $error("[ERROR] Hardware output spike at %0d, but no more spike expected", actual);
                    end
                end
            end
           
            //Check for any miss spikes
            if(tx.expected_spikes.size() > 0) begin
                $error("[ERROR] Hardware finished early, missed %0d spikes", tx.expected_spikes.size());
            end else begin
                $display("[SUCCESS] Image scan complete");
            end
        end
    endtask
endclass

module aer_scan_tb();

    //1. Generate Outer Source Input
    logic clk_i = 0;
    logic rstn_i = 0;
    
    always #5 clk_i = ~clk_i; //100MHz Clock
    
    //2. Wire up interface
    aer_vif vif(clk_i,rstn_i);
    
    //3. Instantiate Verilog Hardware DUT
    aer_scan aer_dut(
        .clk_i(vif.clk_i),
        .rstn_i(vif.rstn_i),
        .aer_en_i(vif.aer_en_i),
        .data_i(vif.data_i),
        .fifo_full_i(vif.fifo_full_i),
        .aer_data_o(vif.aer_data_o),
        .aer_valid_o(vif.aer_valid_o),
        .scan_done_o(vif.scan_done_o)
    );
    
    //4. Declare env components
    //Call classes
    aer_generator   gen;
    aer_driver      drv;
    aer_scoreboard  scb;
    
    mailbox #(aer_transaction) gen2drv;
    mailbox #(aer_transaction) gen2scb;
    
    //5. Initialization Block
    initial begin
        $display("START SIMULATION");
        
        //Initialize Mailbox
        gen2drv = new();
        gen2scb = new();
        
        gen = new(gen2drv,gen2scb);
        drv = new(vif, gen2drv);
        scb = new(vif, gen2scb);
        
        //Start background task
        fork
            drv.run();
            scb.run();
        join_none
        
        //Reset Sequence at t = 0;
        vif.aer_en_i = 1'b0;
        vif.fifo_full_i = 1'b0;
        #20 rstn_i = 1'b1;
        #10;
        
        //Trigger Generator
        gen.run();
        
        #100;
        $display("END SIMULATION");
        $finish;
    end
 endmodule    
             
        
        
 
            
        
    
      
    
    