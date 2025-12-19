// ============================================================================
// File: tb_arm_core.v
// Description: Comprehensive Testbench for ARM Cortex-A9 Core
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`timescale 1ns / 1ps

`include "defines.vh"

module tb_arm_core;

    // ========================================================================
    // 参数
    // ========================================================================
    parameter CLK_PERIOD = 10;  // 100 MHz
    parameter MEM_SIZE = 4096;  // 4KB
    parameter TEST_TIMEOUT = 100000;  // 超时周期数
    
    // ========================================================================
    // 信号声明
    // ========================================================================
    reg                     clk;
    reg                     rst_n;
    
    // 指令存储器接口
    wire                    imem_req;
    wire [31:0]             imem_addr;
    reg  [31:0]             imem_rdata;
    reg                     imem_valid;
    
    // 数据存储器接口
    wire                    dmem_req;
    wire                    dmem_we;
    wire [31:0]             dmem_addr;
    wire [31:0]             dmem_wdata;
    wire [3:0]              dmem_byte_en;
    reg  [31:0]             dmem_rdata;
    reg                     dmem_valid;
    
    // ========================================================================
    // 存储器模型
    // ========================================================================
    reg [31:0] imem [0:MEM_SIZE/4-1];
    reg [31:0] dmem [0:MEM_SIZE/4-1];
    
    // ========================================================================
    // DUT 实例化
    // ========================================================================
    arm_core u_dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .imem_req       (imem_req),
        .imem_addr      (imem_addr),
        .imem_rdata     (imem_rdata),
        .imem_valid     (imem_valid),
        .dmem_req       (dmem_req),
        .dmem_we        (dmem_we),
        .dmem_addr      (dmem_addr),
        .dmem_wdata     (dmem_wdata),
        .dmem_byte_en   (dmem_byte_en),
        .dmem_rdata     (dmem_rdata),
        .dmem_valid     (dmem_valid)
    );
    
    // ========================================================================
    // 时钟生成
    // ========================================================================
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // ========================================================================
    // 存储器访问
    // ========================================================================
    always @(posedge clk) begin
        // 指令存储器 (1周期延迟)
        imem_valid <= imem_req;
        imem_rdata <= imem[imem_addr[31:2]];
        
        // 数据存储器 (1周期延迟)
        dmem_valid <= dmem_req;
        if (dmem_req && !dmem_we) begin
            dmem_rdata <= dmem[dmem_addr[31:2]];
        end
        
        if (dmem_req && dmem_we) begin
            if (dmem_byte_en[0]) dmem[dmem_addr[31:2]][7:0]   <= dmem_wdata[7:0];
            if (dmem_byte_en[1]) dmem[dmem_addr[31:2]][15:8]  <= dmem_wdata[15:8];
            if (dmem_byte_en[2]) dmem[dmem_addr[31:2]][23:16] <= dmem_wdata[23:16];
            if (dmem_byte_en[3]) dmem[dmem_addr[31:2]][31:24] <= dmem_wdata[31:24];
        end
    end
    
    // ========================================================================
    // 测试程序
    // ========================================================================
    integer i;
    integer test_pass;
    integer cycle_count;
    
    initial begin
        // 初始化
        rst_n = 0;
        test_pass = 0;
        cycle_count = 0;
        
        // 清空存储器
        for (i = 0; i < MEM_SIZE/4; i = i + 1) begin
            imem[i] = 32'hE1A00000;  // NOP
            dmem[i] = 32'h0;
        end
        
        // 加载测试程序
        load_test_program();
        
        // 复位
        #(CLK_PERIOD * 5);
        rst_n = 1;
        
        // 等待测试完成
        wait_for_completion();
        
        // 检查结果
        check_results();
        
        // 结束仿真
        #(CLK_PERIOD * 10);
        $display("====================================");
        if (test_pass)
            $display("All Tests PASSED!");
        else
            $display("Some Tests FAILED!");
        $display("====================================");
        $finish;
    end
    
    // ========================================================================
    // 加载测试程序
    // ========================================================================
    task load_test_program;
    begin
        $display("Loading test program...");
        
        // 地址: 0x00 - 测试 1: 基本 ADD
        imem[0] = 32'hE3A00064;  // MOV R0, #100
        imem[1] = 32'hE3A01032;  // MOV R1, #50
        imem[2] = 32'hE0802001;  // ADD R2, R0, R1
        imem[3] = 32'hE3520096;  // CMP R2, #150
        imem[4] = 32'h1A00001C;  // BNE fail
        
        // 地址: 0x14 - 测试 2: 基本 SUB
        imem[5] = 32'hE3A00064;  // MOV R0, #100
        imem[6] = 32'hE3A01032;  // MOV R1, #50
        imem[7] = 32'hE0402001;  // SUB R2, R0, R1
        imem[8] = 32'hE3520032;  // CMP R2, #50
        imem[9] = 32'h1A000017;  // BNE fail
        
        // 地址: 0x28 - 测试 3: 前递测试
        imem[10] = 32'hE3A0000A;  // MOV R0, #10
        imem[11] = 32'hE2801005;  // ADD R1, R0, #5     @ R1 需要前递
        imem[12] = 32'hE0412000;  // SUB R2, R1, R0     @ R1, R0 需要前递
        imem[13] = 32'hE3520005;  // CMP R2, #5
        imem[14] = 32'h1A000012;  // BNE fail
        
        // 地址: 0x3C - 测试 4: 条件执行
        imem[15] = 32'hE3A00005;  // MOV R0, #5
        imem[16] = 32'hE3500005;  // CMP R0, #5
        imem[17] = 32'h03A01001;  // MOVEQ R1, #1      @ 条件为真，应执行
        imem[18] = 32'h13A01000;  // MOVNE R1, #0      @ 条件为假，不执行
        imem[19] = 32'hE3510001;  // CMP R1, #1
        imem[20] = 32'h1A00000C;  // BNE fail
        
        // 地址: 0x54 - 测试 5: 逻辑运算
        imem[21] = 32'hE3A000FF;  // MOV R0, #0xFF
        imem[22] = 32'hE3A010F0;  // MOV R1, #0xF0
        imem[23] = 32'hE0002001;  // AND R2, R0, R1
        imem[24] = 32'hE35200F0;  // CMP R2, #0xF0
        imem[25] = 32'h1A000007;  // BNE fail
        
        // 地址: 0x68 - 测试 6: 移位运算
        imem[26] = 32'hE3A00001;  // MOV R0, #1
        imem[27] = 32'hE1A01100;  // MOV R1, R0, LSL #2  @ R1 = 1 << 2 = 4
        imem[28] = 32'hE3510004;  // CMP R1, #4
        imem[29] = 32'h1A000003;  // BNE fail
        
        // 地址: 0x78 - 测试通过
        imem[30] = 32'hE3A00001;  // MOV R0, #1         @ 通过标志
        imem[31] = 32'hE3A0B800;  // MOV R11, #0x800    @ 结果地址
        imem[32] = 32'hE58B0000;  // STR R0, [R11]      @ 存储结果
        imem[33] = 32'hEAFFFFFE;  // B .                @ 停机
        
        // 地址: 0x88 - 测试失败
        imem[34] = 32'hE3A00000;  // MOV R0, #0         @ 失败标志
        imem[35] = 32'hE3A0B800;  // MOV R11, #0x800
        imem[36] = 32'hE58B0000;  // STR R0, [R11]
        imem[37] = 32'hEAFFFFFE;  // B .
        
        $display("Test program loaded.");
    end
    endtask
    
    // ========================================================================
    // 等待测试完成
    // ========================================================================
    task wait_for_completion;
    begin
        $display("Running tests...");
        
        while (cycle_count < TEST_TIMEOUT) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            
            // 检查是否写入结果地址
            if (dmem_req && dmem_we && dmem_addr == 32'h800) begin
                #(CLK_PERIOD * 5);
                return;
            end
        end
        
        $display("ERROR: Test timeout!");
    end
    endtask
    
    // ========================================================================
    // 检查结果
    // ========================================================================
    task check_results;
    begin
        $display("Checking results...");
        
        // 读取结果地址
        #(CLK_PERIOD);
        
        if (dmem[32'h800 >> 2] == 32'h1) begin
            $display("Result: PASS");
            test_pass = 1;
        end else begin
            $display("Result: FAIL (value = 0x%08X)", dmem[32'h800 >> 2]);
            test_pass = 0;
        end
        
        $display("Cycle count: %d", cycle_count);
    end
    endtask
    
    // ========================================================================
    // 波形记录
    // ========================================================================
    initial begin
        $dumpfile("tb_arm_core.vcd");
        $dumpvars(0, tb_arm_core);
    end
    
    // ========================================================================
    // 监控输出
    // ========================================================================
    always @(posedge clk) begin
        if (rst_n && imem_valid) begin
            $display("[%0t] PC=%08X Instr=%08X", $time, imem_addr, imem_rdata);
        end
    end

endmodule
