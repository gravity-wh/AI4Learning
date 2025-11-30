/*
 * File: tb_fifo.sv
 * Description: Testbench for testing fifo_scoreboard
 */

// Include the scoreboard file
`include "../src/fifo_scoreboard.sv"

module tb_fifo;

    // -------------------------------------------------------
    // 1. Instances (实例化)
    // -------------------------------------------------------
    // TODO: Declare a handle for fifo_scoreboard
    // fifo_scoreboard scb;
    fifo_scoreboard scb; // <-- 请将中文分号 '；' 改为英文分号 ';'

    // -------------------------------------------------------
    // 2. Main Test Process (测试主流程)
    // -------------------------------------------------------
    initial begin
        // TODO: Instantiate the scoreboard object (new)
        // scb = new();
        scb = new();

        $display("-----------------------------------------");
        $display("--- Lab 1: FIFO Scoreboard Simulation ---");
        $display("-----------------------------------------");

        // ---------------------------------------------------
        // Scenario 1: Normal Operation (正常读写)
        // ---------------------------------------------------
        $display("\n[Test] Scenario 1: Normal Write/Read");
        // TODO: Call scb.write_data() with some values (e.g., 0x11, 0x22)
        scb.write_data(8'h11);
        scb.write_data(8'h22);
        
        // TODO: Call scb.check_data() with matching values
        scb.check_data(8'h11);
        scb.check_data(8'h22);

        // ---------------------------------------------------
        // Scenario 2: Data Mismatch (数据不匹配)
        // ---------------------------------------------------
        $display("\n[Test] Scenario 2: Data Mismatch");
        // TODO: Write a value (e.g., 0x33)
        scb.write_data(8'h33);
        // TODO: Check with a WRONG value (e.g., 0x99) to trigger error
        scb.check_data(8'h99);

        // ---------------------------------------------------
        // Scenario 3: Underflow (空读)
        // ---------------------------------------------------
        $display("\n[Test] Scenario 3: FIFO Underflow");
        // TODO: Ensure queue is empty, then call check_data()

        scb.check_data(8'h44);

        // ---------------------------------------------------
        // End of Simulation
        // ---------------------------------------------------
        // TODO: Call scb.report() if implemented
        scb.report();
        $display("\n--- Simulation Finished ---");
    end

endmodule
