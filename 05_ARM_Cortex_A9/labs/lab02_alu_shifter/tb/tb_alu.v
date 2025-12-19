// ============================================================================
// File: tb_alu.v
// Description: Comprehensive testbench for ALU module
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`timescale 1ns / 1ps

`include "defines.vh"

module tb_alu;

    // ========================================================================
    // 参数
    // ========================================================================
    parameter DATA_WIDTH = 32;
    parameter NUM_RANDOM_TESTS = 100;
    
    // ========================================================================
    // 测试信号
    // ========================================================================
    reg  [DATA_WIDTH-1:0]   operand_a;
    reg  [DATA_WIDTH-1:0]   operand_b;
    reg                     carry_in;
    reg  [3:0]              alu_op;
    
    wire [DATA_WIDTH-1:0]   result;
    wire                    flag_n;
    wire                    flag_z;
    wire                    flag_c;
    wire                    flag_v;
    
    // 测试统计
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // 期望值
    reg  [DATA_WIDTH-1:0]   expected_result;
    reg                     expected_n;
    reg                     expected_z;
    reg                     expected_c;
    reg                     expected_v;
    
    // ========================================================================
    // DUT 实例化
    // ========================================================================
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .operand_a  (operand_a),
        .operand_b  (operand_b),
        .carry_in   (carry_in),
        .alu_op     (alu_op),
        .result     (result),
        .flag_n     (flag_n),
        .flag_z     (flag_z),
        .flag_c     (flag_c),
        .flag_v     (flag_v)
    );
    
    // ========================================================================
    // 辅助函数：计算期望结果
    // ========================================================================
    task compute_expected;
        input [DATA_WIDTH-1:0] a;
        input [DATA_WIDTH-1:0] b;
        input                  cin;
        input [3:0]            op;
        
        reg [DATA_WIDTH:0]     temp_sum;
        reg [DATA_WIDTH:0]     temp_diff;
        begin
            expected_v = 1'b0;
            expected_c = cin;
            
            case (op)
                `ALU_AND: expected_result = a & b;
                `ALU_EOR: expected_result = a ^ b;
                `ALU_ORR: expected_result = a | b;
                `ALU_BIC: expected_result = a & ~b;
                `ALU_MOV: expected_result = b;
                `ALU_MVN: expected_result = ~b;
                
                `ALU_ADD: begin
                    temp_sum = {1'b0, a} + {1'b0, b};
                    expected_result = temp_sum[DATA_WIDTH-1:0];
                    expected_c = temp_sum[DATA_WIDTH];
                    expected_v = (a[31] == b[31]) && (expected_result[31] != a[31]);
                end
                
                `ALU_ADC: begin
                    temp_sum = {1'b0, a} + {1'b0, b} + cin;
                    expected_result = temp_sum[DATA_WIDTH-1:0];
                    expected_c = temp_sum[DATA_WIDTH];
                    expected_v = (a[31] == b[31]) && (expected_result[31] != a[31]);
                end
                
                `ALU_SUB, `ALU_CMP: begin
                    temp_diff = {1'b0, a} + {1'b0, ~b} + 1'b1;
                    expected_result = temp_diff[DATA_WIDTH-1:0];
                    expected_c = temp_diff[DATA_WIDTH];
                    expected_v = (a[31] != b[31]) && (expected_result[31] != a[31]);
                end
                
                `ALU_SBC: begin
                    temp_diff = {1'b0, a} + {1'b0, ~b} + cin;
                    expected_result = temp_diff[DATA_WIDTH-1:0];
                    expected_c = temp_diff[DATA_WIDTH];
                    expected_v = (a[31] != b[31]) && (expected_result[31] != a[31]);
                end
                
                `ALU_RSB: begin
                    temp_diff = {1'b0, b} + {1'b0, ~a} + 1'b1;
                    expected_result = temp_diff[DATA_WIDTH-1:0];
                    expected_c = temp_diff[DATA_WIDTH];
                    expected_v = (b[31] != a[31]) && (expected_result[31] != b[31]);
                end
                
                `ALU_RSC: begin
                    temp_diff = {1'b0, b} + {1'b0, ~a} + cin;
                    expected_result = temp_diff[DATA_WIDTH-1:0];
                    expected_c = temp_diff[DATA_WIDTH];
                    expected_v = (b[31] != a[31]) && (expected_result[31] != b[31]);
                end
                
                `ALU_TST: expected_result = a & b;
                `ALU_TEQ: expected_result = a ^ b;
                
                `ALU_CMN: begin
                    temp_sum = {1'b0, a} + {1'b0, b};
                    expected_result = temp_sum[DATA_WIDTH-1:0];
                    expected_c = temp_sum[DATA_WIDTH];
                    expected_v = (a[31] == b[31]) && (expected_result[31] != a[31]);
                end
                
                default: expected_result = 32'h0;
            endcase
            
            expected_n = expected_result[DATA_WIDTH-1];
            expected_z = (expected_result == 32'h0);
        end
    endtask
    
    // ========================================================================
    // 测试任务
    // ========================================================================
    task run_test;
        input [DATA_WIDTH-1:0] a;
        input [DATA_WIDTH-1:0] b;
        input                  cin;
        input [3:0]            op;
        input [127:0]          test_name;
        
        begin
            operand_a = a;
            operand_b = b;
            carry_in  = cin;
            alu_op    = op;
            
            #10;  // 等待组合逻辑稳定
            
            compute_expected(a, b, cin, op);
            
            test_count = test_count + 1;
            
            if (result === expected_result &&
                flag_n === expected_n &&
                flag_z === expected_z &&
                flag_c === expected_c &&
                flag_v === expected_v) begin
                pass_count = pass_count + 1;
                $display("[PASS] %s: A=0x%08h B=0x%08h C=%b => R=0x%08h NZCV=%b%b%b%b",
                         test_name, a, b, cin, result, flag_n, flag_z, flag_c, flag_v);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] %s: A=0x%08h B=0x%08h C=%b", test_name, a, b, cin);
                $display("       Expected: R=0x%08h NZCV=%b%b%b%b", 
                         expected_result, expected_n, expected_z, expected_c, expected_v);
                $display("       Got:      R=0x%08h NZCV=%b%b%b%b", 
                         result, flag_n, flag_z, flag_c, flag_v);
            end
        end
    endtask
    
    // ========================================================================
    // 主测试流程
    // ========================================================================
    integer i;
    reg [31:0] rand_a, rand_b;
    
    initial begin
        // 初始化
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("================================================================");
        $display("           ALU Testbench - ARM Cortex-A9");
        $display("================================================================");
        
        // --------------------------------------------------------------------
        // ADD 测试
        // --------------------------------------------------------------------
        $display("\n--- ADD Operation Tests ---");
        run_test(32'h00000001, 32'h00000001, 1'b0, `ALU_ADD, "ADD basic");
        run_test(32'h00000000, 32'h00000000, 1'b0, `ALU_ADD, "ADD zero");
        run_test(32'hFFFFFFFF, 32'h00000001, 1'b0, `ALU_ADD, "ADD overflow to zero");
        run_test(32'h7FFFFFFF, 32'h00000001, 1'b0, `ALU_ADD, "ADD signed overflow");
        run_test(32'h80000000, 32'h80000000, 1'b0, `ALU_ADD, "ADD negative overflow");
        
        // --------------------------------------------------------------------
        // SUB 测试
        // --------------------------------------------------------------------
        $display("\n--- SUB Operation Tests ---");
        run_test(32'h00000005, 32'h00000003, 1'b0, `ALU_SUB, "SUB basic");
        run_test(32'h00000003, 32'h00000005, 1'b0, `ALU_SUB, "SUB negative result");
        run_test(32'h00000000, 32'h00000001, 1'b0, `ALU_SUB, "SUB underflow");
        run_test(32'h80000000, 32'h00000001, 1'b0, `ALU_SUB, "SUB signed overflow");
        run_test(32'h7FFFFFFF, 32'hFFFFFFFF, 1'b0, `ALU_SUB, "SUB large positive");
        
        // --------------------------------------------------------------------
        // ADC 测试
        // --------------------------------------------------------------------
        $display("\n--- ADC Operation Tests ---");
        run_test(32'h00000001, 32'h00000001, 1'b0, `ALU_ADC, "ADC no carry");
        run_test(32'h00000001, 32'h00000001, 1'b1, `ALU_ADC, "ADC with carry");
        run_test(32'hFFFFFFFF, 32'h00000000, 1'b1, `ALU_ADC, "ADC max+1");
        
        // --------------------------------------------------------------------
        // SBC 测试
        // --------------------------------------------------------------------
        $display("\n--- SBC Operation Tests ---");
        run_test(32'h00000005, 32'h00000003, 1'b1, `ALU_SBC, "SBC no borrow");
        run_test(32'h00000005, 32'h00000003, 1'b0, `ALU_SBC, "SBC with borrow");
        
        // --------------------------------------------------------------------
        // RSB 测试
        // --------------------------------------------------------------------
        $display("\n--- RSB Operation Tests ---");
        run_test(32'h00000003, 32'h00000005, 1'b0, `ALU_RSB, "RSB basic");
        run_test(32'h00000005, 32'h00000003, 1'b0, `ALU_RSB, "RSB negative");
        
        // --------------------------------------------------------------------
        // AND 测试
        // --------------------------------------------------------------------
        $display("\n--- AND Operation Tests ---");
        run_test(32'hFF00FF00, 32'h0F0F0F0F, 1'b0, `ALU_AND, "AND pattern");
        run_test(32'hFFFFFFFF, 32'h00000000, 1'b0, `ALU_AND, "AND to zero");
        run_test(32'hAAAAAAAA, 32'h55555555, 1'b0, `ALU_AND, "AND alternating");
        
        // --------------------------------------------------------------------
        // ORR 测试
        // --------------------------------------------------------------------
        $display("\n--- ORR Operation Tests ---");
        run_test(32'hFF00FF00, 32'h00FF00FF, 1'b0, `ALU_ORR, "ORR combine");
        run_test(32'hAAAAAAAA, 32'h55555555, 1'b0, `ALU_ORR, "ORR to all ones");
        
        // --------------------------------------------------------------------
        // EOR 测试
        // --------------------------------------------------------------------
        $display("\n--- EOR Operation Tests ---");
        run_test(32'hAAAAAAAA, 32'h55555555, 1'b0, `ALU_EOR, "EOR alternating");
        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0, `ALU_EOR, "EOR same = 0");
        
        // --------------------------------------------------------------------
        // MOV/MVN 测试
        // --------------------------------------------------------------------
        $display("\n--- MOV/MVN Operation Tests ---");
        run_test(32'h00000000, 32'h12345678, 1'b0, `ALU_MOV, "MOV value");
        run_test(32'h00000000, 32'h00000000, 1'b0, `ALU_MVN, "MVN to all ones");
        run_test(32'h00000000, 32'hFFFFFFFF, 1'b0, `ALU_MVN, "MVN to zero");
        
        // --------------------------------------------------------------------
        // BIC 测试
        // --------------------------------------------------------------------
        $display("\n--- BIC Operation Tests ---");
        run_test(32'hFFFFFFFF, 32'h0000FFFF, 1'b0, `ALU_BIC, "BIC clear low");
        run_test(32'hFFFFFFFF, 32'hFFFF0000, 1'b0, `ALU_BIC, "BIC clear high");
        
        // --------------------------------------------------------------------
        // CMP/CMN/TST/TEQ 测试
        // --------------------------------------------------------------------
        $display("\n--- Compare Operation Tests ---");
        run_test(32'h00000005, 32'h00000005, 1'b0, `ALU_CMP, "CMP equal");
        run_test(32'h00000005, 32'h00000003, 1'b0, `ALU_CMP, "CMP greater");
        run_test(32'h00000003, 32'h00000005, 1'b0, `ALU_CMP, "CMP less");
        run_test(32'hFFFFFFFF, 32'h00000001, 1'b0, `ALU_CMN, "CMN overflow check");
        run_test(32'h0000000F, 32'h000000F0, 1'b0, `ALU_TST, "TST no common bits");
        run_test(32'h12345678, 32'h12345678, 1'b0, `ALU_TEQ, "TEQ equal = 0");
        
        // --------------------------------------------------------------------
        // 随机测试
        // --------------------------------------------------------------------
        $display("\n--- Random Tests ---");
        for (i = 0; i < NUM_RANDOM_TESTS; i = i + 1) begin
            rand_a = $random;
            rand_b = $random;
            run_test(rand_a, rand_b, $random & 1, $random & 4'hF, "Random");
        end
        
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
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);
    end

endmodule
