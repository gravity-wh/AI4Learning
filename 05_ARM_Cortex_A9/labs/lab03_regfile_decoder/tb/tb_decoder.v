// ============================================================================
// File: tb_decoder.v
// Description: Testbench for ARM Instruction Decoder
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`timescale 1ns / 1ps

`include "defines.vh"

module tb_decoder;

    // ========================================================================
    // 信号声明
    // ========================================================================
    reg  [31:0]     instruction;
    wire [3:0]      cond;
    wire [3:0]      alu_op;
    wire            alu_src;
    wire            reg_write;
    wire            mem_read;
    wire            mem_write;
    wire            branch;
    wire            branch_link;
    wire            s_bit;
    wire [1:0]      shift_type;
    wire [4:0]      shift_amount;
    wire [3:0]      rn;
    wire [3:0]      rd;
    wire [3:0]      rm;
    wire [3:0]      rs;
    wire [23:0]     imm24;
    wire [11:0]     imm12;
    wire [2:0]      inst_type;
    wire            valid;
    
    // ========================================================================
    // DUT 实例化
    // ========================================================================
    decoder u_dut (
        .instruction    (instruction),
        .cond           (cond),
        .alu_op         (alu_op),
        .alu_src        (alu_src),
        .reg_write      (reg_write),
        .mem_read       (mem_read),
        .mem_write      (mem_write),
        .branch         (branch),
        .branch_link    (branch_link),
        .s_bit          (s_bit),
        .shift_type     (shift_type),
        .shift_amount   (shift_amount),
        .rn             (rn),
        .rd             (rd),
        .rm             (rm),
        .rs             (rs),
        .imm24          (imm24),
        .imm12          (imm12),
        .inst_type      (inst_type),
        .valid          (valid)
    );
    
    // ========================================================================
    // 测试序列
    // ========================================================================
    integer error_count;
    
    initial begin
        $display("====================================");
        $display("ARM Decoder Testbench");
        $display("====================================");
        
        error_count = 0;
        instruction = 0;
        
        #10;
        
        // ====================================================================
        // 测试 1: ADD R2, R0, R1
        // ====================================================================
        $display("\n[Test 1] ADD R2, R0, R1");
        instruction = 32'hE0802001;  // ADD R2, R0, R1
        #10;
        
        check_field("cond", cond, 4'hE);
        check_field("alu_op", alu_op, `ALU_ADD);
        check_field("alu_src", alu_src, 1'b0);
        check_field("reg_write", reg_write, 1'b1);
        check_field("rn", rn, 4'd0);
        check_field("rd", rd, 4'd2);
        check_field("rm", rm, 4'd1);
        
        // ====================================================================
        // 测试 2: SUB R3, R4, #100
        // ====================================================================
        $display("\n[Test 2] SUB R3, R4, #100");
        instruction = 32'hE2443064;  // SUB R3, R4, #100
        #10;
        
        check_field("cond", cond, 4'hE);
        check_field("alu_op", alu_op, `ALU_SUB);
        check_field("alu_src", alu_src, 1'b1);
        check_field("reg_write", reg_write, 1'b1);
        check_field("rn", rn, 4'd4);
        check_field("rd", rd, 4'd3);
        
        // ====================================================================
        // 测试 3: MOV R5, #255
        // ====================================================================
        $display("\n[Test 3] MOV R5, #255");
        instruction = 32'hE3A050FF;  // MOV R5, #255
        #10;
        
        check_field("alu_op", alu_op, `ALU_MOV);
        check_field("alu_src", alu_src, 1'b1);
        check_field("reg_write", reg_write, 1'b1);
        check_field("rd", rd, 4'd5);
        
        // ====================================================================
        // 测试 4: CMP R6, R7 (不写入寄存器)
        // ====================================================================
        $display("\n[Test 4] CMP R6, R7");
        instruction = 32'hE1560007;  // CMP R6, R7
        #10;
        
        check_field("alu_op", alu_op, `ALU_CMP);
        check_field("reg_write", reg_write, 1'b0);  // CMP 不写寄存器
        check_field("s_bit", s_bit, 1'b1);
        
        // ====================================================================
        // 测试 5: LDR R8, [R9]
        // ====================================================================
        $display("\n[Test 5] LDR R8, [R9]");
        instruction = 32'hE5998000;  // LDR R8, [R9]
        #10;
        
        check_field("reg_write", reg_write, 1'b1);
        check_field("mem_read", mem_read, 1'b1);
        check_field("mem_write", mem_write, 1'b0);
        check_field("rn", rn, 4'd9);
        check_field("rd", rd, 4'd8);
        
        // ====================================================================
        // 测试 6: STR R10, [R11]
        // ====================================================================
        $display("\n[Test 6] STR R10, [R11]");
        instruction = 32'hE58BA000;  // STR R10, [R11]
        #10;
        
        check_field("reg_write", reg_write, 1'b0);
        check_field("mem_read", mem_read, 1'b0);
        check_field("mem_write", mem_write, 1'b1);
        check_field("rn", rn, 4'd11);
        check_field("rd", rd, 4'd10);
        
        // ====================================================================
        // 测试 7: B label (无条件分支)
        // ====================================================================
        $display("\n[Test 7] B (Branch)");
        instruction = 32'hEA000010;  // B +68 (offset = 16 * 4 + 8)
        #10;
        
        check_field("branch", branch, 1'b1);
        check_field("branch_link", branch_link, 1'b0);
        check_field("imm24", imm24, 24'h000010);
        
        // ====================================================================
        // 测试 8: BL subroutine (带链接分支)
        // ====================================================================
        $display("\n[Test 8] BL (Branch with Link)");
        instruction = 32'hEB000020;  // BL +136
        #10;
        
        check_field("branch", branch, 1'b1);
        check_field("branch_link", branch_link, 1'b1);
        
        // ====================================================================
        // 测试 9: MOVS R1, R2, LSL #4 (带移位)
        // ====================================================================
        $display("\n[Test 9] MOVS R1, R2, LSL #4");
        instruction = 32'hE1B01202;  // MOVS R1, R2, LSL #4
        #10;
        
        check_field("alu_op", alu_op, `ALU_MOV);
        check_field("s_bit", s_bit, 1'b1);
        check_field("shift_type", shift_type, `SHIFT_LSL);
        check_field("shift_amount", shift_amount, 5'd4);
        check_field("rm", rm, 4'd2);
        
        // ====================================================================
        // 测试 10: 条件执行 - ADDEQ
        // ====================================================================
        $display("\n[Test 10] ADDEQ R0, R1, R2");
        instruction = 32'h00801002;  // ADDEQ R0, R1, R2
        #10;
        
        check_field("cond", cond, `COND_EQ);
        check_field("alu_op", alu_op, `ALU_ADD);
        
        // ====================================================================
        // 结果汇总
        // ====================================================================
        #10;
        $display("\n====================================");
        if (error_count == 0) begin
            $display("All Tests PASSED!");
        end else begin
            $display("Tests FAILED with %0d errors", error_count);
        end
        $display("====================================");
        
        $finish;
    end
    
    // ========================================================================
    // 辅助任务
    // ========================================================================
    task check_field;
        input [127:0] name;
        input [31:0] actual;
        input [31:0] expected;
    begin
        if (actual !== expected) begin
            $display("  ERROR: %s = 0x%0X, expected 0x%0X", name, actual, expected);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: %s = 0x%0X", name, actual);
        end
    end
    endtask

endmodule
