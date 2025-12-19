// ============================================================================
// File: fetch_unit.v
// Description: Instruction Fetch Unit for ARM Cortex-A9
//              Manages PC and instruction fetching from I-Cache/Memory
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// Reference: ARM Cortex-A9 Technical Reference Manual
// ============================================================================

`include "defines.vh"

module fetch_unit #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     clk,
    input  wire                     rst_n,
    
    // ========================================================================
    // 流水线控制信号
    // ========================================================================
    input  wire                     stall,          // 暂停取指
    input  wire                     flush,          // 冲刷流水线
    input  wire                     branch_taken,   // 分支执行
    input  wire [ADDR_WIDTH-1:0]    branch_target,  // 分支目标地址
    
    // ========================================================================
    // PC 输出
    // ========================================================================
    output reg  [ADDR_WIDTH-1:0]    pc,             // 当前 PC
    output wire [ADDR_WIDTH-1:0]    pc_next,        // 下一条 PC
    
    // ========================================================================
    // 指令存储器接口
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]    imem_addr,      // 指令地址
    output wire                     imem_rd_en,     // 读使能
    input  wire [DATA_WIDTH-1:0]    imem_rd_data,   // 读取的指令
    input  wire                     imem_rd_valid,  // 指令有效
    
    // ========================================================================
    // 指令输出
    // ========================================================================
    output wire [DATA_WIDTH-1:0]    instruction,    // 取到的指令
    output wire                     valid           // 指令有效标志
);

    // ========================================================================
    // 复位向量定义
    // ========================================================================
    localparam RESET_VECTOR = 32'h0000_0000;
    
    // ========================================================================
    // PC 计算
    // ========================================================================
    
    // 下一条 PC 计算
    // 优先级: branch_taken > sequential
    assign pc_next = branch_taken ? branch_target : (pc + 32'd4);
    
    // ========================================================================
    // PC 寄存器更新
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= RESET_VECTOR;
        end else if (flush) begin
            // 冲刷时，如果有分支则跳转，否则继续
            pc <= branch_taken ? branch_target : pc;
        end else if (!stall) begin
            pc <= pc_next;
        end
        // stall 时 PC 保持不变
    end
    
    // ========================================================================
    // 指令存储器接口
    // ========================================================================
    
    // 地址输出 - 当前 PC
    assign imem_addr = pc;
    
    // 读使能 - 不暂停时始终读取
    assign imem_rd_en = !stall;
    
    // ========================================================================
    // 指令输出
    // ========================================================================
    
    // 指令输出
    // 如果 flush 或无效，输出 NOP
    assign instruction = (flush || !imem_rd_valid) ? `NOP_INSTRUCTION : imem_rd_data;
    
    // 有效标志
    assign valid = imem_rd_valid && !flush && !stall;

endmodule
