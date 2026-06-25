`timescale 1ns / 1ps

// --- Register File Transaction ---
class RegFileTransaction;
    rand bit        wr_en;
    rand bit [4:0]  rs1;
    rand bit [4:0]  rs2;
    rand bit [4:0]  rd;
    rand bit [31:0] wb_data;
    
    // Outputs
    bit [31:0]      dout1;
    bit [31:0]      dout2;

    // Constraints to hit edge cases like x0
    constraint c_rd { rd dist {0 := 10, [1:31] := 90}; }
    
    function void display(string name);
        $display("[%s] WE=%b | RD=x%0d WData=%0h | RS1=x%0d RData1=%0h | RS2=x%0d RData2=%0h", 
            name, wr_en, rd, wb_data, rs1, dout1, rs2, dout2);
    endfunction
endclass

// --- Register File Generator ---
class RegFileGenerator;
    mailbox #(RegFileTransaction) gen2drv;
    int num_tx;

    function new(mailbox #(RegFileTransaction) gen2drv, int num_tx = 50);
        this.gen2drv = gen2drv;
        this.num_tx  = num_tx;
    endfunction

    task run();
        RegFileTransaction tx;
        for (int i = 0; i < num_tx; i++) begin
            tx = new();
            if(!tx.randomize()) $fatal("Randomization failed!");
            gen2drv.put(tx);
        end
    endtask
endclass

// --- Register File Driver & Monitor (simplified OOP environment) ---
module regfile_tb();

    // Clock and Reset
    reg clk;
    reg rstn;

    // Interface Signals
    reg        wr_en_i;
    reg  [4:0] rs1_i;
    reg  [4:0] rs2_i;
    reg  [4:0] rd_i;
    reg [31:0] wb_data_i;
    wire [31:0] dout1_o;
    wire [31:0] dout2_o;

    // UUT Instantiation
    regfile uut (
        .clk_i(clk),
        .rstn_i(rstn),
        .wr_en_i(wr_en_i),
        .rs1_i(rs1_i),
        .rs2_i(rs2_i),
        .rd_i(rd_i),
        .wb_data_i(wb_data_i),
        .dout1_o(dout1_o),
        .dout2_o(dout2_o)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // OOP Mailbox
    mailbox #(RegFileTransaction) mbx = new();
    RegFileGenerator gen = new(mbx, 100);

    // Driver/Monitor Task
    task automatic drive_and_monitor(int num_tx);
        RegFileTransaction tx;
        int pass_count = 0;
        int fail_count = 0;

        // Internal shadow memory for self-checking
        reg [31:0] expected_reg [31:0];
        for(int i=0; i<32; i++) expected_reg[i] = 0;

        for (int t = 0; t < num_tx; t++) begin
            mbx.get(tx);

            // Drive inputs
            @(negedge clk);
            wr_en_i   = tx.wr_en;
            rs1_i     = tx.rs1;
            rs2_i     = tx.rs2;
            rd_i      = tx.rd;
            wb_data_i = tx.wb_data;

            // Sample outputs after propagation
            @(posedge clk);
            #1; // hold delay
            tx.dout1 = dout1_o;
            tx.dout2 = dout2_o;

            // Write-first bypass: if same reg is written and read this cycle, DUT shows new value
            begin
                bit [31:0] exp1, exp2;
                exp1 = (tx.wr_en && tx.rd != 0 && tx.rd == tx.rs1) ? tx.wb_data : expected_reg[tx.rs1];
                exp2 = (tx.wr_en && tx.rd != 0 && tx.rd == tx.rs2) ? tx.wb_data : expected_reg[tx.rs2];

                if (dout1_o !== exp1) begin
                    $error("[FAIL] RS1 Data Mismatch! Expected: %0h, Got: %0h", exp1, dout1_o);
                    fail_count++;
                end else if (dout2_o !== exp2) begin
                    $error("[FAIL] RS2 Data Mismatch! Expected: %0h, Got: %0h", exp2, dout2_o);
                    fail_count++;
                end else begin
                    pass_count++;
                    tx.display("PASS");
                end
            end

            // Shadow memory update on synchronous write
            if (tx.wr_en && tx.rd != 0) begin
                expected_reg[tx.rd] = tx.wb_data;
            end
        end
        $display("=== REGFILE RESULT: Pass=%0d / Fail=%0d / Total=%0d ===", pass_count, fail_count, num_tx);
    endtask

    // Test sequence
    initial begin
        $display("=== STARTING REGFILE OOP SIMULATION ===");
        
        // Initialization
        rstn = 0;
        wr_en_i = 0; rs1_i = 0; rs2_i = 0; rd_i = 0; wb_data_i = 0;
        
        #15 rstn = 1;

        // Run OOP Generator and Driver concurrently
        fork
            gen.run();
            drive_and_monitor(100);
        join
        
        #20;
        $display("=== REGFILE OOP SIMULATION COMPLETE ===");
        $finish;
    end

endmodule