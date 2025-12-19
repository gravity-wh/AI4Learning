// ============================================================================
// File: tb_cortex_a9.v
// Description: Testbench for ARM Cortex-A9 top-level module
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`timescale 1ns / 1ps

`include "defines.vh"

module tb_cortex_a9;

    // ========================================================================
    // 参数定义
    // ========================================================================
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter CLK_PERIOD = 10;  // 100 MHz
    parameter MEM_SIZE   = 1024; // 1K words
    
    // ========================================================================
    // 信号声明
    // ========================================================================
    reg                         clk;
    reg                         rst_n;
    
    // Instruction Memory Interface
    wire [ADDR_WIDTH-1:0]       imem_addr;
    wire                        imem_rd_en;
    reg  [DATA_WIDTH-1:0]       imem_rd_data;
    reg                         imem_rd_valid;
    
    // Data Memory Interface
    wire [ADDR_WIDTH-1:0]       dmem_addr;
    wire [DATA_WIDTH-1:0]       dmem_wr_data;
    wire                        dmem_wr_en;
    wire                        dmem_rd_en;
    wire [3:0]                  dmem_byte_en;
    reg  [DATA_WIDTH-1:0]       dmem_rd_data;
    reg                         dmem_rd_valid;
    
    // Interrupts
    reg                         irq_n;
    reg                         fiq_n;
    
    // Debug
    wire [ADDR_WIDTH-1:0]       debug_pc;
    wire [DATA_WIDTH-1:0]       debug_instr;
    wire [3:0]                  debug_cpsr_flags;
    wire                        debug_halted;
    
    // ========================================================================
    // 存储器模型
    // ========================================================================
    reg [DATA_WIDTH-1:0] instruction_memory [0:MEM_SIZE-1];
    reg [DATA_WIDTH-1:0] data_memory [0:MEM_SIZE-1];
    
    // ========================================================================
    // DUT 实例化
    // ========================================================================
    cortex_a9_top #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH)
    ) dut (
        .clk            (clk),
        .rst_n          (rst_n),
        // Instruction memory
        .imem_addr      (imem_addr),
        .imem_rd_en     (imem_rd_en),
        .imem_rd_data   (imem_rd_data),
        .imem_rd_valid  (imem_rd_valid),
        // Data memory
        .dmem_addr      (dmem_addr),
        .dmem_wr_data   (dmem_wr_data),
        .dmem_wr_en     (dmem_wr_en),
        .dmem_rd_en     (dmem_rd_en),
        .dmem_byte_en   (dmem_byte_en),
        .dmem_rd_data   (dmem_rd_data),
        .dmem_rd_valid  (dmem_rd_valid),
        // Interrupts
        .irq_n          (irq_n),
        .fiq_n          (fiq_n),
        // Debug
        .debug_pc       (debug_pc),
        .debug_instr    (debug_instr),
        .debug_cpsr_flags(debug_cpsr_flags),
        .debug_halted   (debug_halted)
    );
    
    // ========================================================================
    // 时钟生成
    // ========================================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // ========================================================================
    // 指令存储器模型
    // ========================================================================
    always @(posedge clk) begin
        if (imem_rd_en) begin
            imem_rd_data  <= instruction_memory[imem_addr[11:2]];
            imem_rd_valid <= 1'b1;
        end else begin
            imem_rd_valid <= 1'b0;
        end
    end
    
    // ========================================================================
    // 数据存储器模型
    // ========================================================================
    always @(posedge clk) begin
        if (dmem_wr_en) begin
            // 字节写入
            if (dmem_byte_en[0]) data_memory[dmem_addr[11:2]][7:0]   <= dmem_wr_data[7:0];
            if (dmem_byte_en[1]) data_memory[dmem_addr[11:2]][15:8]  <= dmem_wr_data[15:8];
            if (dmem_byte_en[2]) data_memory[dmem_addr[11:2]][23:16] <= dmem_wr_data[23:16];
            if (dmem_byte_en[3]) data_memory[dmem_addr[11:2]][31:24] <= dmem_wr_data[31:24];
        end
        
        if (dmem_rd_en) begin
            dmem_rd_data  <= data_memory[dmem_addr[11:2]];
            dmem_rd_valid <= 1'b1;
        end else begin
            dmem_rd_valid <= 1'b0;
        end
    end
    
    // ========================================================================
    // 测试程序加载
    // ========================================================================
    task load_test_program;
        integer i;
        begin
            // 初始化存储器
            for (i = 0; i < MEM_SIZE; i = i + 1) begin
                instruction_memory[i] = `NOP_INSTRUCTION;
                data_memory[i] = 32'h0;
            end
            
            // 加载测试程序
            // 示例程序：简单的寄存器操作
            // 地址 0x00: MOV R0, #0x10      ; R0 = 16
            // 地址 0x04: MOV R1, #0x20      ; R1 = 32
            // 地址 0x08: ADD R2, R0, R1     ; R2 = R0 + R1 = 48
            // 地址 0x0C: SUB R3, R1, R0     ; R3 = R1 - R0 = 16
            // 地址 0x10: AND R4, R0, R1     ; R4 = R0 & R1
            // 地址 0x14: ORR R5, R0, R1     ; R5 = R0 | R1
            // 地址 0x18: MOV R6, R2, LSL #2 ; R6 = R2 << 2
            // 地址 0x1C: B loop             ; Branch to self (infinite loop)
            
            instruction_memory[0]  = 32'hE3A00010;  // MOV R0, #0x10
            instruction_memory[1]  = 32'hE3A01020;  // MOV R1, #0x20
            instruction_memory[2]  = 32'hE0802001;  // ADD R2, R0, R1
            instruction_memory[3]  = 32'hE0413000;  // SUB R3, R1, R0
            instruction_memory[4]  = 32'hE0004001;  // AND R4, R0, R1
            instruction_memory[5]  = 32'hE1805001;  // ORR R5, R0, R1
            instruction_memory[6]  = 32'hE1A06102;  // MOV R6, R2, LSL #2
            instruction_memory[7]  = 32'hEAFFFFFE;  // B . (infinite loop)
            
            $display("[TB] Test program loaded successfully");
        end
    endtask
    
    // ========================================================================
    // 主测试流程
    // ========================================================================
    initial begin
        // 初始化信号
        rst_n = 1'b0;
        irq_n = 1'b1;
        fiq_n = 1'b1;
        imem_rd_data = 32'h0;
        imem_rd_valid = 1'b0;
        dmem_rd_data = 32'h0;
        dmem_rd_valid = 1'b0;
        
        // 加载测试程序
        load_test_program();
        
        // 等待几个时钟周期
        repeat(5) @(posedge clk);
        
        // 释放复位
        $display("[TB] Releasing reset at time %0t", $time);
        rst_n = 1'b1;
        
        // 运行仿真
        $display("[TB] Starting simulation...");
        repeat(100) begin
            @(posedge clk);
            // 打印调试信息
            $display("[TB] Time=%0t PC=0x%08h Instr=0x%08h Flags=%04b", 
                     $time, debug_pc, debug_instr, debug_cpsr_flags);
        end
        
        // 结束仿真
        $display("[TB] Simulation completed at time %0t", $time);
        $finish;
    end
    
    // ========================================================================
    // 波形记录
    // ========================================================================
    initial begin
        $dumpfile("cortex_a9_tb.vcd");
        $dumpvars(0, tb_cortex_a9);
    end
    
    // ========================================================================
    // 超时保护
    // ========================================================================
    initial begin
        #100000;
        $display("[TB] ERROR: Simulation timeout!");
        $finish;
    end

endmodule
