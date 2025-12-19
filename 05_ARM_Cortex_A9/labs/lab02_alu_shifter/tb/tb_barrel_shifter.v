// ============================================================================
// File: tb_barrel_shifter.v
// Description: Testbench for Barrel Shifter module
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`timescale 1ns / 1ps

`include "defines.vh"

module tb_barrel_shifter;

    // ========================================================================
    // 参数
    // ========================================================================
    parameter DATA_WIDTH = 32;
    
    // ========================================================================
    // 测试信号
    // ========================================================================
    reg  [DATA_WIDTH-1:0]   data_in;
    reg  [4:0]              shift_amount;
    reg  [1:0]              shift_type;
    reg                     carry_in;
    reg                     shift_by_reg;
    
    wire [DATA_WIDTH-1:0]   data_out;
    wire                    carry_out;
    
    // 测试统计
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // ========================================================================
    // DUT 实例化
    // ========================================================================
    barrel_shifter #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .data_in        (data_in),
        .shift_amount   (shift_amount),
        .shift_type     (shift_type),
        .carry_in       (carry_in),
        .shift_by_reg   (shift_by_reg),
        .data_out       (data_out),
        .carry_out      (carry_out)
    );
    
    // ========================================================================
    // 测试任务
    // ========================================================================
    task run_test;
        input [DATA_WIDTH-1:0]  in_data;
        input [4:0]             amount;
        input [1:0]             stype;
        input                   cin;
        input                   by_reg;
        input [DATA_WIDTH-1:0]  expected_out;
        input                   expected_cout;
        input [127:0]           test_name;
        
        begin
            data_in      = in_data;
            shift_amount = amount;
            shift_type   = stype;
            carry_in     = cin;
            shift_by_reg = by_reg;
            
            #10;
            
            test_count = test_count + 1;
            
            if (data_out === expected_out && carry_out === expected_cout) begin
                pass_count = pass_count + 1;
                $display("[PASS] %s: In=0x%08h Amt=%0d Type=%0d => Out=0x%08h C=%b",
                         test_name, in_data, amount, stype, data_out, carry_out);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] %s: In=0x%08h Amt=%0d Type=%0d", 
                         test_name, in_data, amount, stype);
                $display("       Expected: Out=0x%08h C=%b", expected_out, expected_cout);
                $display("       Got:      Out=0x%08h C=%b", data_out, carry_out);
            end
        end
    endtask
    
    // ========================================================================
    // 主测试流程
    // ========================================================================
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("================================================================");
        $display("        Barrel Shifter Testbench - ARM Cortex-A9");
        $display("================================================================");
        
        // --------------------------------------------------------------------
        // LSL 测试
        // --------------------------------------------------------------------
        $display("\n--- LSL (Logical Shift Left) Tests ---");
        
        // LSL #0
        run_test(32'h12345678, 5'd0, `SHIFT_LSL, 1'b0, 1'b0,
                 32'h12345678, 1'b0, "LSL #0");
        
        // LSL #1
        run_test(32'h12345678, 5'd1, `SHIFT_LSL, 1'b0, 1'b0,
                 32'h2468ACF0, 1'b0, "LSL #1");
        
        // LSL #4
        run_test(32'h12345678, 5'd4, `SHIFT_LSL, 1'b0, 1'b0,
                 32'h23456780, 1'b1, "LSL #4");
        
        // LSL #16
        run_test(32'h12345678, 5'd16, `SHIFT_LSL, 1'b0, 1'b0,
                 32'h56780000, 1'b1, "LSL #16");
        
        // LSL #31
        run_test(32'h00000001, 5'd31, `SHIFT_LSL, 1'b0, 1'b0,
                 32'h80000000, 1'b0, "LSL #31");
        
        // LSL with carry propagation
        run_test(32'h80000000, 5'd1, `SHIFT_LSL, 1'b0, 1'b0,
                 32'h00000000, 1'b1, "LSL carry out");
        
        // --------------------------------------------------------------------
        // LSR 测试
        // --------------------------------------------------------------------
        $display("\n--- LSR (Logical Shift Right) Tests ---");
        
        // LSR #0 (by register = 0, should keep value)
        run_test(32'h12345678, 5'd0, `SHIFT_LSR, 1'b1, 1'b1,
                 32'h12345678, 1'b1, "LSR Rs=0");
        
        // LSR #0 in immediate encoding = LSR #32
        run_test(32'h80000000, 5'd0, `SHIFT_LSR, 1'b0, 1'b0,
                 32'h00000000, 1'b1, "LSR #32");
        
        // LSR #1
        run_test(32'h12345678, 5'd1, `SHIFT_LSR, 1'b0, 1'b0,
                 32'h091A2B3C, 1'b0, "LSR #1");
        
        // LSR #4
        run_test(32'h12345678, 5'd4, `SHIFT_LSR, 1'b0, 1'b0,
                 32'h01234567, 1'b1, "LSR #4");
        
        // LSR #16
        run_test(32'h12345678, 5'd16, `SHIFT_LSR, 1'b0, 1'b0,
                 32'h00001234, 1'b0, "LSR #16");
        
        // LSR #31
        run_test(32'h80000000, 5'd31, `SHIFT_LSR, 1'b0, 1'b0,
                 32'h00000001, 1'b0, "LSR #31");
        
        // --------------------------------------------------------------------
        // ASR 测试
        // --------------------------------------------------------------------
        $display("\n--- ASR (Arithmetic Shift Right) Tests ---");
        
        // ASR positive number
        run_test(32'h12345678, 5'd4, `SHIFT_ASR, 1'b0, 1'b0,
                 32'h01234567, 1'b1, "ASR pos #4");
        
        // ASR negative number (sign extension)
        run_test(32'h80000000, 5'd1, `SHIFT_ASR, 1'b0, 1'b0,
                 32'hC0000000, 1'b0, "ASR neg #1");
        
        run_test(32'h80000000, 5'd4, `SHIFT_ASR, 1'b0, 1'b0,
                 32'hF8000000, 1'b0, "ASR neg #4");
        
        run_test(32'hFFFFFFFF, 5'd16, `SHIFT_ASR, 1'b0, 1'b0,
                 32'hFFFFFFFF, 1'b1, "ASR all 1s #16");
        
        // ASR #0 in immediate encoding = ASR #32
        run_test(32'h80000000, 5'd0, `SHIFT_ASR, 1'b0, 1'b0,
                 32'hFFFFFFFF, 1'b1, "ASR neg #32");
        
        run_test(32'h7FFFFFFF, 5'd0, `SHIFT_ASR, 1'b0, 1'b0,
                 32'h00000000, 1'b0, "ASR pos #32");
        
        // --------------------------------------------------------------------
        // ROR 测试
        // --------------------------------------------------------------------
        $display("\n--- ROR (Rotate Right) Tests ---");
        
        // ROR #0 (by register) = no change
        run_test(32'h12345678, 5'd0, `SHIFT_ROR, 1'b0, 1'b1,
                 32'h12345678, 1'b0, "ROR Rs=0");
        
        // ROR #4
        run_test(32'h12345678, 5'd4, `SHIFT_ROR, 1'b0, 1'b0,
                 32'h81234567, 1'b1, "ROR #4");
        
        // ROR #8
        run_test(32'h12345678, 5'd8, `SHIFT_ROR, 1'b0, 1'b0,
                 32'h78123456, 1'b0, "ROR #8");
        
        // ROR #16
        run_test(32'h12345678, 5'd16, `SHIFT_ROR, 1'b0, 1'b0,
                 32'h56781234, 1'b0, "ROR #16");
        
        // ROR #1 with LSB = 1
        run_test(32'h00000001, 5'd1, `SHIFT_ROR, 1'b0, 1'b0,
                 32'h80000000, 1'b1, "ROR #1 LSB=1");
        
        // --------------------------------------------------------------------
        // RRX 测试 (ROR #0 in immediate encoding)
        // --------------------------------------------------------------------
        $display("\n--- RRX (Rotate Right Extended) Tests ---");
        
        // RRX with carry_in = 0
        run_test(32'h12345678, 5'd0, `SHIFT_ROR, 1'b0, 1'b0,
                 32'h091A2B3C, 1'b0, "RRX C=0");
        
        // RRX with carry_in = 1
        run_test(32'h12345678, 5'd0, `SHIFT_ROR, 1'b1, 1'b0,
                 32'h891A2B3C, 1'b0, "RRX C=1");
        
        // RRX with LSB = 1
        run_test(32'h00000001, 5'd0, `SHIFT_ROR, 1'b0, 1'b0,
                 32'h00000000, 1'b1, "RRX LSB=1 C=0");
        
        run_test(32'h00000001, 5'd0, `SHIFT_ROR, 1'b1, 1'b0,
                 32'h80000000, 1'b1, "RRX LSB=1 C=1");
        
        // --------------------------------------------------------------------
        // 边界测试
        // --------------------------------------------------------------------
        $display("\n--- Boundary Tests ---");
        
        run_test(32'hFFFFFFFF, 5'd1, `SHIFT_LSL, 1'b0, 1'b0,
                 32'hFFFFFFFE, 1'b1, "LSL all 1s #1");
        
        run_test(32'hFFFFFFFF, 5'd31, `SHIFT_LSR, 1'b0, 1'b0,
                 32'h00000001, 1'b1, "LSR all 1s #31");
        
        run_test(32'h00000000, 5'd16, `SHIFT_LSL, 1'b0, 1'b0,
                 32'h00000000, 1'b0, "LSL zero");
        
        // --------------------------------------------------------------------
        // 测试报告
        // --------------------------------------------------------------------
        $display("\n================================================================");
        $display("                    TEST SUMMARY");
        $display("================================================================");
        $display("Total Tests:  %0d", test_count);
        $display("Passed:       %0d", pass_count);
        $display("Failed:       %0d", fail_count);
        $display("Pass Rate:    %0d%%", (pass_count * 100) / test_count);
        $display("================================================================");
        
        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
        end else begin
            $display("*** SOME TESTS FAILED ***");
        end
        
        $finish;
    end
    
    // ========================================================================
    // 波形记录
    // ========================================================================
    initial begin
        $dumpfile("tb_barrel_shifter.vcd");
        $dumpvars(0, tb_barrel_shifter);
    end

endmodule
