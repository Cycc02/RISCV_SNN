`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2026 16:31:40
// Design Name: 
// Module Name: simd_tb
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

interface simd_vif (input logic clk_i, input logic rstn_i);
    logic pe_en_i;
    logic spike_i;
    logic [2:0] stp_idx_i;
    logic [63:0] weight_i;
    
    logic [7:0] spike_o;
 endinterface
 
 class simd_transaction;
    //Declare rand weight input
    rand bit [63:0] weight_data[8];
    rand bit spike_trig;
    
    //Expected output
    bit [7:0] expected_spike_out[8];
    
    function void display(input string name = "SIMD_TX");
        $display("[%s] Spike Event: %b", name, spike_trig);
        for(int i = 0; i < 8; i++) begin
            $display("   Step %0d | Weights: %16h", i, weight_data[i]);
        end
    endfunction

    function simd_transaction clone();
        simd_transaction copy = new();
        copy.spike_trig = this.spike_trig;
        for(int i = 0; i < 8; i++) begin
            copy.weight_data[i] = this.weight_data[i];
            copy.expected_spike_out[i] = this.expected_spike_out[i];
        end
        return copy;
    endfunction

endclass

class simd_generator;
    mailbox #(simd_transaction) gen2drv;
    mailbox #(simd_transaction) gen2scb;
    
    int num_transactions =  50;
    
    function new(mailbox #(simd_transaction) drv_mbx, mailbox #(simd_transaction) scb_mbx);
        this.gen2drv = drv_mbx;
        this.gen2scb = scb_mbx;
    endfunction
    
    task run();
        simd_transaction tx;
        
        for(int i = 0; i < num_transactions ; i++) begin
            tx = new();
            
            if (!tx.randomize()) $fatal("[GEN] Randomization failed!");
            $display("[GENERATOR] Created Spike Event %0d", i);
            
            gen2drv.put(tx.clone());
            gen2scb.put(tx.clone());
        end
    endtask
endclass

class simd_driver;
    virtual simd_vif vif;
    mailbox #(simd_transaction) gen2drv;
    
    function new(virtual simd_vif vif, mailbox #(simd_transaction) drv_mbx);
        this.gen2drv = drv_mbx;
        this.vif = vif;
    endfunction
    
    task run();
        simd_transaction tx;
        
        //Initialize pins
        vif.pe_en_i <= 1'b0;
        vif.spike_i <= 1'b0;
        vif.stp_idx_i <= 3'b0;
        vif.weight_i <= 64'b0;
        
        forever begin
            gen2drv.get(tx);
            
            for(int step = 0; step < 8; step++) begin
                @(posedge vif.clk_i);
                
                vif.pe_en_i <= 1'b1;
                vif.spike_i <= tx.spike_trig;
                vif.weight_i <= tx.weight_data[step];
                vif.stp_idx_i <= step[2:0];
            end
            
            @(posedge vif.clk_i);
            vif.pe_en_i <= 1'b0;
        end
    endtask
endclass

class simd_monitor;
    virtual simd_vif vif;
    mailbox #(simd_transaction) mon2scb;
    
    function new(virtual simd_vif vif, mailbox #(simd_transaction) mon2scb);
        this.mon2scb = mon2scb;
        this.vif = vif;
    endfunction
    
    task run();
        simd_transaction observed_tx;
        
        forever begin
            // 1. Wait for the Driver to start the transaction
            wait (vif.pe_en_i === 1'b1);
            
            observed_tx = new();
            
            // 2. THE PIPELINE DELAY: 
            // Wait for Clock 2 so the hardware has time to output Step 0's answer!
            @(posedge vif.clk_i); 
            
            for (int step = 0; step < 8; step++) begin
                // 3. Read safely on the falling edge
                @(negedge vif.clk_i); 
                observed_tx.expected_spike_out[step] = vif.spike_o; 
                
                // 4. Wait for the next clock cycle (unless it's the last step)
                if (step < 7) @(posedge vif.clk_i); 
            end
            
            $display("[MONITOR] Captured 8-cycle execution block.");
            mon2scb.put(observed_tx);
            
            // 5. Wait for transaction to end before hunting for the next one
            wait (vif.pe_en_i === 1'b0);
        end
    endtask
endclass

class simd_scoreboard;
    mailbox #(simd_transaction) gen2scb; 
    mailbox #(simd_transaction) mon2scb; 
    
    int signed expected_potentials [64]; 
    int THRESHOLD = 85;
    
    function new(mailbox #(simd_transaction) gen_mbx, mailbox #(simd_transaction) mon_mbx);
        this.gen2scb = gen_mbx;
        this.mon2scb = mon_mbx;
        
        // Initialize all 64 neurons to 0 potential
        foreach(expected_potentials[i]) expected_potentials[i] = 0;
    endfunction
    
function void calc_expected(simd_transaction tx);
        
        for (int step = 0; step < 8; step++) begin
            bit [7:0] step_spike_out = 8'b0;
            
            for (int lane = 0; lane < 8; lane++) begin
                int neuron_idx = (step * 8) + lane;
                
                // Extract as signed byte!
                byte signed weight = tx.weight_data[step][(lane * 8) +: 8];
                
                int signed current_pot = expected_potentials[neuron_idx];
                int signed v_leaked    = current_pot >>> 1; 
                int signed add_w       = v_leaked;
                
                if (tx.spike_trig == 1'b1) begin
                    add_w = v_leaked + weight; 
                end
                
                // Matches PyTorch's >=
                if (add_w >= THRESHOLD) begin
                    step_spike_out[lane] = 1'b1;
                    expected_potentials[neuron_idx] = 0;
                end else begin
                    step_spike_out[lane] = 1'b0;
                    expected_potentials[neuron_idx] = add_w;
                end
            end
            tx.expected_spike_out[step] = step_spike_out;
        end
endfunction
    
    task run();
        simd_transaction expected_tx;
        simd_transaction actual_tx;
        
        forever begin
            gen2scb.get(expected_tx);
            calc_expected(expected_tx);
            //Hardware Side
            mon2scb.get(actual_tx);
            //Comparison
            for(int step = 0; step < 8; step++) begin
                if (expected_tx.expected_spike_out[step] === actual_tx.expected_spike_out[step]) begin
                    $display("[PASS] Step %0d | Actual: %b == Expected: %b", 
                             step, actual_tx.expected_spike_out[step], expected_tx.expected_spike_out[step]);
                end else begin
                    $error("[FAIL] Step %0d | Actual: %b != Expected: %b", 
                             step, actual_tx.expected_spike_out[step], expected_tx.expected_spike_out[step]);
                end
            end
        end
    endtask
endclass

module simd_tb();
    logic clk_i = 0;
    logic rstn_i = 0;
    
    always #5 clk_i = ~clk_i;
    
    simd_vif vif(clk_i, rstn_i);
    
    simd_8 #(
        .WEIGHT_WIDTH(8),
        .LANE_COUNT(8),
        .POT_WIDTH(32),
        .THRESHOLD(32'sd85)
    ) simd_dut (
        .clk_i(vif.clk_i),
        .rstn_i(vif.rstn_i),
        .pe_en_i(vif.pe_en_i),
        .spike_i(vif.spike_i),
        .stp_idx_i(vif.stp_idx_i),
        .weight_i(vif.weight_i),
        .spike_o(vif.spike_o)
    );
    
    simd_generator gen;
    simd_scoreboard scb;
    simd_driver drv;
    simd_monitor mon;
    
    mailbox #(simd_transaction) gen2drv;
    mailbox #(simd_transaction) gen2scb;
    mailbox #(simd_transaction) mon2scb;
    
    initial begin
        $display("START SIMULATION");
        
        gen2drv = new();
        gen2scb = new();
        mon2scb = new();
        
        gen = new(gen2drv,gen2scb);
        drv = new(vif,gen2drv);
        mon = new(vif,mon2scb);
        scb = new(gen2scb, mon2scb);
        
        fork
            drv.run();
            scb.run();
            mon.run();
        join_none
                
        #20 rstn_i = 1;
        #10;
        
        gen.run();
        wait(gen2drv.num() == 0);
        
        #200;
        $display("SIMULATION FINISHED");
        $finish;
   end
endmodule
   
         
    
            
            
            
        
         
                
                
    
          
    
       
    
    
    