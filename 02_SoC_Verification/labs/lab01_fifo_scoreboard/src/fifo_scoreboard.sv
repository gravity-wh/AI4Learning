/*
 * File: fifo_scoreboard.sv
 * Description: FIFO Scoreboard class for Lab 1
 * Author: AI4ICLearning
 */

class fifo_scoreboard;
    // -------------------------------------------------------
    // 1. Data Members (数据成员)
    // -------------------------------------------------------
    // TODO: Define a queue to store expected data (int type)
    // int scb_queue[$];
    int scb_queue[$];

    // TODO: Define counters for matches and errors
    // int match_count;
    // int error_count;

    int match_count;
    int error_count;

    // -------------------------------------------------------
    // 2. Constructor (构造函数)
    // -------------------------------------------------------
    function new();
        // TODO: Initialize counters to 0
        match_count = 0;
        error_count = 0;
    endfunction

    // -------------------------------------------------------
    // 3. Write Method (写入方法)
    // Description: Called by Monitor when data is written to DUT
    // -------------------------------------------------------
    function void write_data(int data);
        // TODO: Push data into the queue (push_back)
        scb_queue.push_back(data);

        // TODO: Print debug info (e.g., "Write data: ...")
        $display("Scoreboard: Written data: 0x%0h", data);
    
    endfunction

    // -------------------------------------------------------
    // 4. Check Method (检查方法)
    // Description: Called by Monitor when data is read from DUT
    // -------------------------------------------------------
    function void check_data(int actual_data);
        // TODO: Check if queue is empty (Underflow handling)
        if (scb_queue.size() == 0) begin
            $display("Scoreboard ERROR: Underflow! No expected data available.");
            error_count++;
            return;
        end

        // TODO: Pop expected data from queue (pop_front)
        int expected_data;
        expected_data = scb_queue.pop_front();



        // TODO: Compare expected_data vs actual_data
        //       If match -> increment match_count
        //       If mismatch -> increment error_count and print error
        if (expected_data === actual_data) begin
            match_count++;
            $display("Scoreboard:data Match:Expected=0x%0h, Actual=0x%0h", expected_data, actual_data);
        end else begin
            error_count++;
            $display("Scoreboard ERROR: Data Mismatch! Expected=0x%0h, Actual=0x%0h", expected_data, actual_data);
        end

    endfunction

    // -------------------------------------------------------
    // 5. Report Method (Optional)
    // -------------------------------------------------------
    function void report();
        // TODO: Print final statistics (Matches vs Errors)
        $display("Scoreboard Report: Total Matches = %0d, Total Errors = %0d", match_count, error_count);

    endfunction

endclass
