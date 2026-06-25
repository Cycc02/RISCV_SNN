`timescale 1ns / 1ps

// ============================================================
//  STDP stub  (learning_unit instantiates this internally)
// ============================================================
module stdp #(
    parameter TIMESTEP_WIDTH = 8,
    parameter WEIGHT_WIDTH   = 8,
    parameter ALPHA_SHIFT    = 3,
    parameter TIME_WINDOW    = 8
)(
    input                              update_en_i,
    input  [TIMESTEP_WIDTH-1:0]        time_pre_i,
    input  [TIMESTEP_WIDTH-1:0]        time_post_i,
    input  signed [WEIGHT_WIDTH-1:0]   weight_i,
    output signed [WEIGHT_WIDTH-1:0]   weight_o
);
    // potentiate +1 when pre fires before post, depress -1 otherwise
    assign weight_o = update_en_i
                    ? (time_pre_i < time_post_i ? weight_i + 1'sb1
                                                : weight_i - 1'sb1)
                    : weight_i;
endmodule


// ============================================================
//  Interface
// ============================================================
interface lu_if #(
    parameter WEIGHT_WIDTH   = 8,
    parameter TIMESTEP_WIDTH = 8,
    parameter ADDR_WIDTH     = 13
)(input logic clk);

    logic                       rstn;
    logic                       lr_en;
    logic                       lr_done;

    logic [ADDR_WIDTH-1:0]      ram_addr;
    logic                       ram_rd_en;
    logic                       ram_wr_en;
    logic [63:0]                ram_weight_i;
    logic [63:0]                ram_weight_o;

    logic [9:0]                 t_pre_addr;
    logic [TIMESTEP_WIDTH-1:0]  t_pre_data;
    logic [2:0]                 t_post_addr;
    logic [63:0]                t_post_data;

    // Driver CB: drives DUT inputs, reads DUT outputs for handshake
    clocking drv_cb @(posedge clk);
        default input #1 output #1;
        output rstn, lr_en, ram_weight_i, t_pre_data, t_post_data;
        input  lr_done, ram_addr, ram_wr_en, ram_rd_en;
    endclocking

    // Monitor CB: observes DUT outputs only
    clocking mon_cb @(posedge clk);
        default input #1;
        input lr_done, ram_addr, ram_wr_en, ram_weight_o,
              t_pre_addr, t_post_addr;
    endclocking

endinterface


// ============================================================
//  Transaction
//    Carries one complete learning-sweep: stimulus + expected + observed
// ============================================================
class lu_transaction;

    // --- stimulus (randomised by generator) ---
    rand logic [63:0] weight_data;
    rand logic [7:0]  t_pre;
    rand logic [63:0] t_post;

    // --- expected (set by generator) ---
    int unsigned exp_wr_count;

    // --- observed (filled by monitor) ---
    int unsigned got_wr_count;
    bit          got_done;
    logic [12:0] done_addr;

    // ensure pre fires before every post lane → potentiation path
    constraint c_pre_before_post {
        foreach (t_post[i]) t_pre < t_post[i];
    }

    function new(int bram_depth);
        exp_wr_count = bram_depth;
        got_wr_count = 0;
        got_done     = 0;
        done_addr    = '0;
    endfunction

    function string to_string();
        return $sformatf(
            "weight=%h  t_pre=%0d  t_post[7:0]=%0d | exp_wr=%0d  got_wr=%0d  done=%0b  done_addr=%0d",
            weight_data, t_pre, t_post[7:0],
            exp_wr_count, got_wr_count, got_done, done_addr);
    endfunction

endclass


// ============================================================
//  Generator
//    Creates randomised transactions and queues them for the driver
// ============================================================
class lu_generator;

    mailbox #(lu_transaction) gen2drv;
    int bram_depth;
    int num_txns;

    function new(mailbox #(lu_transaction) gen2drv,
                 int bram_depth,
                 int num_txns = 3);
        this.gen2drv    = gen2drv;
        this.bram_depth = bram_depth;
        this.num_txns   = num_txns;
    endfunction

    task run();
        lu_transaction txn;
        repeat (num_txns) begin
            txn = new(bram_depth);
            assert (txn.randomize()) else $fatal(1, "[GEN] randomize failed");
            $display("[GEN ] txn created : weight=%h  t_pre=%0d", txn.weight_data, txn.t_pre);
            gen2drv.put(txn);
        end
    endtask

endclass


// ============================================================
//  Driver
//    Resets the DUT, drives one transaction at a time, hands off
//    to the monitor, then waits for the run to finish before
//    starting the next one (avoids lr_en being ignored mid-sweep).
// ============================================================
class lu_driver;

    virtual lu_if    vif;
    mailbox #(lu_transaction) gen2drv;
    mailbox #(lu_transaction) drv2mon;
    int bram_depth;

    function new(virtual lu_if vif,
                 mailbox #(lu_transaction) gen2drv,
                 mailbox #(lu_transaction) drv2mon,
                 int bram_depth);
        this.vif        = vif;
        this.gen2drv    = gen2drv;
        this.drv2mon    = drv2mon;
        this.bram_depth = bram_depth;
    endfunction

    // ---- reset sequence ----
    task reset();
        vif.drv_cb.rstn         <= 1'b0;
        vif.drv_cb.lr_en        <= 1'b0;
        vif.drv_cb.ram_weight_i <= '0;
        vif.drv_cb.t_pre_data   <= '0;
        vif.drv_cb.t_post_data  <= '0;
        repeat (3) @(vif.drv_cb);
        vif.drv_cb.rstn <= 1'b1;
        repeat (2) @(vif.drv_cb);
        $display("[DRV ] reset complete");
    endtask

    // ---- main loop ----
    task run();
        lu_transaction txn;
        forever begin
            gen2drv.get(txn);
            drive(txn);
        end
    endtask

    // ---- drive one transaction ----
    task drive(lu_transaction txn);
        // 1. Load memory stimulus (one cycle setup)
        vif.drv_cb.ram_weight_i <= txn.weight_data;
        vif.drv_cb.t_pre_data   <= txn.t_pre;
        vif.drv_cb.t_post_data  <= txn.t_post;
        @(vif.drv_cb);

        // 2. Pulse lr_en for one cycle
        vif.drv_cb.lr_en <= 1'b1;
        @(vif.drv_cb);
        vif.drv_cb.lr_en <= 1'b0;

        // 3. Hand transaction to monitor so it can observe the run
        drv2mon.put(txn);

        // 4. Wait for completion before returning (prevents overlap)
        wait_done();
    endtask

    // ---- block until lr_done or timeout ----
    task wait_done();
        automatic int limit = bram_depth * 4 + 20;
        repeat (limit) begin
            @(vif.drv_cb);
            if (vif.drv_cb.lr_done) begin
                repeat (2) @(vif.drv_cb); // let DUT settle back to IDLE
                return;
            end
        end
        $display("[DRV ] wait_done TIMEOUT after %0d cycles", limit);
    endtask

endclass


// ============================================================
//  Monitor
//    Receives a transaction from the driver once a run begins,
//    counts ram_wr_en pulses, captures lr_done and done_addr,
//    then forwards the completed transaction to the scoreboard.
// ============================================================
class lu_monitor;

    virtual lu_if    vif;
    mailbox #(lu_transaction) drv2mon;
    mailbox #(lu_transaction) mon2scb;
    int bram_depth;

    function new(virtual lu_if vif,
                 mailbox #(lu_transaction) drv2mon,
                 mailbox #(lu_transaction) mon2scb,
                 int bram_depth);
        this.vif        = vif;
        this.drv2mon    = drv2mon;
        this.mon2scb    = mon2scb;
        this.bram_depth = bram_depth;
    endfunction

    task run();
        lu_transaction txn;
        forever begin
            drv2mon.get(txn);   // one txn = one learning sweep
            observe(txn);
            mon2scb.put(txn);
        end
    endtask

    task observe(lu_transaction txn);
        automatic int limit  = bram_depth * 4 + 20;
        automatic int cycles = 0;
        txn.got_wr_count = 0;
        txn.got_done     = 0;

        forever begin
            @(vif.mon_cb);
            cycles++;

            if (vif.mon_cb.ram_wr_en) begin
                txn.got_wr_count++;
                $display("[MON ] write #%0d  addr=%0d  weight_o=%h",
                         txn.got_wr_count, vif.mon_cb.ram_addr, vif.mon_cb.ram_weight_o);
            end

            if (vif.mon_cb.lr_done) begin
                txn.got_done  = 1'b1;
                txn.done_addr = vif.mon_cb.ram_addr;
                $display("[MON ] lr_done seen at addr=%0d", txn.done_addr);
                break;
            end

            if (cycles >= limit) begin
                $display("[MON ] observe TIMEOUT after %0d cycles", limit);
                break;
            end
        end
    endtask

endclass


// ============================================================
//  Scoreboard
//    Receives fully-observed transactions and checks correctness
// ============================================================
class lu_scoreboard;

    mailbox #(lu_transaction) mon2scb;
    int bram_depth;
    int checks;
    int errors;

    function new(mailbox #(lu_transaction) mon2scb, int bram_depth);
        this.mon2scb    = mon2scb;
        this.bram_depth = bram_depth;
        this.checks     = 0;
        this.errors     = 0;
    endfunction

    task run();
        lu_transaction txn;
        forever begin
            mon2scb.get(txn);
            check(txn);
        end
    endtask

    task check(lu_transaction txn);
        checks++;
        $display("[SCB ] Run %0d | %s", checks, txn.to_string());

        assert_eq("lr_done asserted",
                  int'(txn.got_done), 1,
                  $sformatf("got_done=%0b", txn.got_done));

        assert_eq("write count",
                  int'(txn.got_wr_count), int'(txn.exp_wr_count),
                  $sformatf("exp=%0d  got=%0d", txn.exp_wr_count, txn.got_wr_count));

        assert_eq("done_addr == BRAM_DEPTH-1",
                  int'(txn.done_addr), bram_depth - 1,
                  $sformatf("exp=%0d  got=%0d", bram_depth-1, txn.done_addr));
    endtask

    task assert_eq(string label, int got, int exp, string detail);
        if (got === exp)
            $display("         PASS : %s", label);
        else begin
            $display("         FAIL : %s  (%s)", label, detail);
            errors++;
        end
    endtask

    function void report();
        $display("==============================================");
        $display("Scoreboard  |  %0d run(s)  |  %0d error(s)", checks, errors);
        $display(errors == 0 ? "  >> ALL TESTS PASSED <<"
                             : "  >> SOME TESTS FAILED <<");
        $display("==============================================");
    endfunction

endclass


// ============================================================
//  Environment
//    Wires all components together and orchestrates the run
// ============================================================
class lu_env;

    lu_generator  gen;
    lu_driver     drv;
    lu_monitor    mon;
    lu_scoreboard scb;

    mailbox #(lu_transaction) gen2drv;
    mailbox #(lu_transaction) drv2mon;
    mailbox #(lu_transaction) mon2scb;

    function new(virtual lu_if vif, int bram_depth, int num_txns);
        gen2drv = new(1);
        drv2mon = new(1);
        mon2scb = new(1);

        gen = new(gen2drv, bram_depth, num_txns);
        drv = new(vif, gen2drv, drv2mon, bram_depth);
        mon = new(vif, drv2mon, mon2scb, bram_depth);
        scb = new(mon2scb, bram_depth);
    endfunction

    task run();
        drv.reset();

        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_none

        // Wait until scoreboard has checked every transaction
        wait (scb.checks == gen.num_txns);
        scb.report();
    endtask

endclass


// ============================================================
//  Top testbench module
// ============================================================
module learning_unit_tb;

    // Override BRAM_DEPTH with a small value so simulation is fast.
    // All other parameters stay at their real values.
    localparam WEIGHT_WIDTH   = 8;
    localparam TIMESTEP_WIDTH = 8;
    localparam ALPHA_SHIFT    = 3;
    localparam TIME_WINDOW    = 8;
    localparam BRAM_DEPTH     = 8;   // << small for sim speed
    localparam ADDR_WIDTH     = 13;
    localparam NUM_TXNS       = 3;

    // ---- clock ----
    logic clk;
    initial  clk = 1'b0;
    always #5 clk = ~clk;

    // ---- interface ----
    lu_if #(
        .WEIGHT_WIDTH  (WEIGHT_WIDTH),
        .TIMESTEP_WIDTH(TIMESTEP_WIDTH),
        .ADDR_WIDTH    (ADDR_WIDTH)
    ) intf (.clk(clk));

    // ---- DUT ----
    learning_unit #(
        .WEIGHT_WIDTH  (WEIGHT_WIDTH),
        .TIMESTEP_WIDTH(TIMESTEP_WIDTH),
        .ALPHA_SHIFT   (ALPHA_SHIFT),
        .TIME_WINDOW   (TIME_WINDOW),
        .BRAM_DEPTH    (BRAM_DEPTH),
        .ADDR_WIDTH    (ADDR_WIDTH)
    ) dut (
        .clk_i         (clk),
        .rstn_i        (intf.rstn),
        .lr_en_i       (intf.lr_en),
        .lr_done_o     (intf.lr_done),
        .ram_addr_o    (intf.ram_addr),
        .ram_rd_en_o   (intf.ram_rd_en),
        .ram_wr_en_o   (intf.ram_wr_en),
        .ram_weight_i  (intf.ram_weight_i),
        .ram_weight_o  (intf.ram_weight_o),
        .t_pre_addr_o  (intf.t_pre_addr),
        .t_pre_data_i  (intf.t_pre_data),
        .t_post_addr_o (intf.t_post_addr),
        .t_post_data_i (intf.t_post_data)
    );

    // ---- run ----
    initial begin
        automatic lu_env env = new(intf, BRAM_DEPTH, NUM_TXNS);
        env.run();
        #20;
        $finish;
    end

    // ---- watchdog ----
    initial begin
        #500_000;
        $display("[TB  ] WATCHDOG: simulation timed out");
        $finish;
    end

endmodule
