// ============================================================================
// File: alu.v
// Description: 32-bit Arithmetic Logic Unit for ARM Cortex-A9
//              Supports all 16 ARM data processing operations
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module alu #(
    parameter DATA_WIDTH = 32
)(
    // ========================================================================
    // 操作数输入
    // ========================================================================
    input  wire [DATA_WIDTH-1:0]    operand_a,      // 第一操作数 (Rn)
    input  wire [DATA_WIDTH-1:0]    operand_b,      // 第二操作数 (移位后的 Rm 或立即数)
    input  wire                     carry_in,       // 输入进位 (来自 CPSR.C)
    
    // ========================================================================
    // 控制输入
    // ========================================================================
    input  wire [3:0]               alu_op,         // ALU 操作码
    
    // ========================================================================
    // 结果输出
    // ========================================================================
    output reg  [DATA_WIDTH-1:0]    result,         // 运算结果
    
    // ========================================================================
    // 标志位输出
    // ========================================================================
    output wire                     flag_n,         // Negative (结果为负)
    output wire                     flag_z,         // Zero (结果为零)
    output reg                      flag_c,         // Carry (进位/借位)
    output reg                      flag_v          // Overflow (溢出)
);

    // ========================================================================
    // 内部信号声明
    // ========================================================================
    
    // 取反操作数
    wire [DATA_WIDTH-1:0]   not_a;
    wire [DATA_WIDTH-1:0]   not_b;
    
    // 扩展加法结果 (33位以捕获进位)
    wire [DATA_WIDTH:0]     sum_ab;         // A + B
    wire [DATA_WIDTH:0]     sum_abc;        // A + B + Cin
    wire [DATA_WIDTH:0]     diff_ab;        // A - B = A + ~B + 1
    wire [DATA_WIDTH:0]     diff_abc;       // A - B - !C = A + ~B + C
    wire [DATA_WIDTH:0]     diff_ba;        // B - A = B + ~A + 1
    wire [DATA_WIDTH:0]     diff_bac;       // B - A - !C = B + ~A + C
    
    // 溢出检测信号
    wire                    ov_add;         // 加法溢出
    wire                    ov_adc;         // 带进位加法溢出
    wire                    ov_sub;         // 减法溢出
    wire                    ov_sbc;         // 带借位减法溢出
    wire                    ov_rsb;         // 反向减法溢出
    wire                    ov_rsc;         // 带借位反向减法溢出
    
    // ========================================================================
    // 基础运算
    // ========================================================================
    
    assign not_a = ~operand_a;
    assign not_b = ~operand_b;
    
    // 加法运算
    assign sum_ab  = {1'b0, operand_a} + {1'b0, operand_b};
    assign sum_abc = {1'b0, operand_a} + {1'b0, operand_b} + {{DATA_WIDTH{1'b0}}, carry_in};
    
    // 减法运算: A - B = A + (~B) + 1
    assign diff_ab  = {1'b0, operand_a} + {1'b0, not_b} + {{DATA_WIDTH{1'b0}}, 1'b1};
    assign diff_abc = {1'b0, operand_a} + {1'b0, not_b} + {{DATA_WIDTH{1'b0}}, carry_in};
    
    // 反向减法: B - A = B + (~A) + 1
    assign diff_ba  = {1'b0, operand_b} + {1'b0, not_a} + {{DATA_WIDTH{1'b0}}, 1'b1};
    assign diff_bac = {1'b0, operand_b} + {1'b0, not_a} + {{DATA_WIDTH{1'b0}}, carry_in};
    
    // ========================================================================
    // 溢出检测
    // 有符号溢出: 两个同号数运算结果变号
    // ========================================================================
    
    // ADD: A + B 溢出
    assign ov_add = (operand_a[DATA_WIDTH-1] == operand_b[DATA_WIDTH-1]) &&
                    (sum_ab[DATA_WIDTH-1] != operand_a[DATA_WIDTH-1]);
    
    // ADC: A + B + C 溢出
    assign ov_adc = (operand_a[DATA_WIDTH-1] == operand_b[DATA_WIDTH-1]) &&
                    (sum_abc[DATA_WIDTH-1] != operand_a[DATA_WIDTH-1]);
    
    // SUB: A - B 溢出 (等价于 A + (-B))
    assign ov_sub = (operand_a[DATA_WIDTH-1] != operand_b[DATA_WIDTH-1]) &&
                    (diff_ab[DATA_WIDTH-1] != operand_a[DATA_WIDTH-1]);
    
    // SBC: A - B - !C 溢出
    assign ov_sbc = (operand_a[DATA_WIDTH-1] != operand_b[DATA_WIDTH-1]) &&
                    (diff_abc[DATA_WIDTH-1] != operand_a[DATA_WIDTH-1]);
    
    // RSB: B - A 溢出
    assign ov_rsb = (operand_b[DATA_WIDTH-1] != operand_a[DATA_WIDTH-1]) &&
                    (diff_ba[DATA_WIDTH-1] != operand_b[DATA_WIDTH-1]);
    
    // RSC: B - A - !C 溢出
    assign ov_rsc = (operand_b[DATA_WIDTH-1] != operand_a[DATA_WIDTH-1]) &&
                    (diff_bac[DATA_WIDTH-1] != operand_b[DATA_WIDTH-1]);
    
    // ========================================================================
    // ALU 操作选择
    // ========================================================================
    
    always @(*) begin
        // 默认值
        result = {DATA_WIDTH{1'b0}};
        flag_c = carry_in;  // 逻辑运算保持进位不变
        flag_v = 1'b0;
        
        case (alu_op)
            // ----------------------------------------------------------------
            // 逻辑运算 (不影响 V 标志，C 由移位器产生)
            // ----------------------------------------------------------------
            `ALU_AND: begin
                result = operand_a & operand_b;
            end
            
            `ALU_EOR: begin
                result = operand_a ^ operand_b;
            end
            
            `ALU_ORR: begin
                result = operand_a | operand_b;
            end
            
            `ALU_BIC: begin
                result = operand_a & not_b;  // Bit Clear
            end
            
            // ----------------------------------------------------------------
            // 数据传送
            // ----------------------------------------------------------------
            `ALU_MOV: begin
                result = operand_b;
            end
            
            `ALU_MVN: begin
                result = not_b;
            end
            
            // ----------------------------------------------------------------
            // 算术运算
            // ----------------------------------------------------------------
            `ALU_ADD: begin
                result = sum_ab[DATA_WIDTH-1:0];
                flag_c = sum_ab[DATA_WIDTH];
                flag_v = ov_add;
            end
            
            `ALU_ADC: begin
                result = sum_abc[DATA_WIDTH-1:0];
                flag_c = sum_abc[DATA_WIDTH];
                flag_v = ov_adc;
            end
            
            `ALU_SUB: begin
                result = diff_ab[DATA_WIDTH-1:0];
                flag_c = diff_ab[DATA_WIDTH];   // C=1 表示无借位
                flag_v = ov_sub;
            end
            
            `ALU_SBC: begin
                result = diff_abc[DATA_WIDTH-1:0];
                flag_c = diff_abc[DATA_WIDTH];
                flag_v = ov_sbc;
            end
            
            `ALU_RSB: begin
                result = diff_ba[DATA_WIDTH-1:0];
                flag_c = diff_ba[DATA_WIDTH];
                flag_v = ov_rsb;
            end
            
            `ALU_RSC: begin
                result = diff_bac[DATA_WIDTH-1:0];
                flag_c = diff_bac[DATA_WIDTH];
                flag_v = ov_rsc;
            end
            
            // ----------------------------------------------------------------
            // 比较运算 (仅设置标志，结果不写回)
            // ----------------------------------------------------------------
            `ALU_TST: begin
                result = operand_a & operand_b;
                // C 由移位器设置
            end
            
            `ALU_TEQ: begin
                result = operand_a ^ operand_b;
                // C 由移位器设置
            end
            
            `ALU_CMP: begin
                result = diff_ab[DATA_WIDTH-1:0];
                flag_c = diff_ab[DATA_WIDTH];
                flag_v = ov_sub;
            end
            
            `ALU_CMN: begin
                result = sum_ab[DATA_WIDTH-1:0];
                flag_c = sum_ab[DATA_WIDTH];
                flag_v = ov_add;
            end
            
            default: begin
                result = {DATA_WIDTH{1'b0}};
                flag_c = carry_in;
                flag_v = 1'b0;
            end
        endcase
    end
    
    // ========================================================================
    // N 和 Z 标志 (所有操作都更新)
    // ========================================================================
    
    assign flag_n = result[DATA_WIDTH-1];
    assign flag_z = (result == {DATA_WIDTH{1'b0}});

endmodule
