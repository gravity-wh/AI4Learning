// ============================================================================
// File: execute_unit.v
// Description: Execute Unit integrating ALU, Barrel Shifter, and Branch Logic
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module execute_unit #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     clk,
    input  wire                     rst_n,
    
    // ========================================================================
    // 数据输入
    // ========================================================================
    input  wire [DATA_WIDTH-1:0]    rn_data,        // Rn 寄存器数据
    input  wire [DATA_WIDTH-1:0]    rm_data,        // Rm 寄存器数据
    input  wire [DATA_WIDTH-1:0]    rs_data,        // Rs 寄存器数据 (移位量)
    input  wire [DATA_WIDTH-1:0]    imm_data,       // 立即数
    input  wire [ADDR_WIDTH-1:0]    pc,             // 当前 PC
    
    // ========================================================================
    // 控制输入
    // ========================================================================
    input  wire [3:0]               alu_op,         // ALU 操作
    input  wire                     alu_src,        // 0=Rm, 1=Imm
    input  wire [1:0]               shift_type,     // 移位类型
    input  wire [4:0]               shift_amount,   // 移位量
    input  wire                     carry_in,       // CPSR.C
    input  wire [3:0]               cond,           // 条件码
    input  wire [3:0]               cpsr_flags,     // NZCV
    input  wire                     branch,         // 分支指令
    input  wire                     branch_link,    // BL 指令
    
    // ========================================================================
    // 前递输入
    // ========================================================================
    input  wire [1:0]               forward_a,      // Rn 前递选择
    input  wire [1:0]               forward_b,      // Rm 前递选择
    input  wire [DATA_WIDTH-1:0]    mem_fwd_data,   // MEM 阶段前递数据
    input  wire [DATA_WIDTH-1:0]    wb_fwd_data,    // WB 阶段前递数据
    
    // ========================================================================
    // 输出
    // ========================================================================
    output wire [DATA_WIDTH-1:0]    alu_result,     // ALU 结果
    output wire [DATA_WIDTH-1:0]    shifted_op,     // 移位后的操作数
    output wire                     alu_n,          // Negative 标志
    output wire                     alu_z,          // Zero 标志
    output wire                     alu_c,          // Carry 标志
    output wire                     alu_v,          // Overflow 标志
    output wire                     cond_pass,      // 条件通过
    output wire                     branch_taken,   // 分支执行
    output wire [ADDR_WIDTH-1:0]    branch_target   // 分支目标地址
);

    // ========================================================================
    // 内部信号
    // ========================================================================
    
    // 前递后的操作数
    wire [DATA_WIDTH-1:0]   fwd_rn_data;
    wire [DATA_WIDTH-1:0]   fwd_rm_data;
    
    // 移位器输出
    wire [DATA_WIDTH-1:0]   shifter_out;
    wire                    shifter_carry;
    
    // ALU 操作数
    wire [DATA_WIDTH-1:0]   alu_operand_a;
    wire [DATA_WIDTH-1:0]   alu_operand_b;
    
    // ALU 进位 (移位器或 CPSR)
    wire                    alu_carry_in;
    
    // 条件判断
    wire                    cpsr_n, cpsr_z, cpsr_c, cpsr_v;
    
    // ========================================================================
    // 前递多路选择器
    // ========================================================================
    
    // Rn 前递
    assign fwd_rn_data = (forward_a == `FWD_MEM) ? mem_fwd_data :
                         (forward_a == `FWD_WB)  ? wb_fwd_data  :
                                                   rn_data;
    
    // Rm 前递
    assign fwd_rm_data = (forward_b == `FWD_MEM) ? mem_fwd_data :
                         (forward_b == `FWD_WB)  ? wb_fwd_data  :
                                                   rm_data;
    
    // ========================================================================
    // Barrel Shifter
    // ========================================================================
    
    // 移位量选择：立即数或寄存器
    wire [4:0] actual_shift_amount;
    assign actual_shift_amount = (shift_amount == 5'd0 && shift_type != `SHIFT_LSL) ?
                                  rs_data[4:0] : shift_amount;
    
    barrel_shifter #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_shifter (
        .data_in        (fwd_rm_data),
        .shift_amount   (actual_shift_amount),
        .shift_type     (shift_type),
        .carry_in       (carry_in),
        .shift_by_reg   (shift_amount == 5'd0),
        .data_out       (shifter_out),
        .carry_out      (shifter_carry)
    );
    
    assign shifted_op = shifter_out;
    
    // ========================================================================
    // ALU 操作数选择
    // ========================================================================
    
    assign alu_operand_a = fwd_rn_data;
    assign alu_operand_b = alu_src ? imm_data : shifter_out;
    
    // 逻辑运算使用移位器进位，算术运算使用 CPSR 进位
    wire is_arithmetic;
    assign is_arithmetic = (alu_op == `ALU_ADD) || (alu_op == `ALU_ADC) ||
                           (alu_op == `ALU_SUB) || (alu_op == `ALU_SBC) ||
                           (alu_op == `ALU_RSB) || (alu_op == `ALU_RSC) ||
                           (alu_op == `ALU_CMP) || (alu_op == `ALU_CMN);
    
    assign alu_carry_in = is_arithmetic ? carry_in : shifter_carry;
    
    // ========================================================================
    // ALU 实例
    // ========================================================================
    
    wire [DATA_WIDTH-1:0]   alu_result_internal;
    wire                    alu_n_internal, alu_z_internal;
    wire                    alu_c_internal, alu_v_internal;
    
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_alu (
        .operand_a  (alu_operand_a),
        .operand_b  (alu_operand_b),
        .carry_in   (alu_carry_in),
        .alu_op     (alu_op),
        .result     (alu_result_internal),
        .flag_n     (alu_n_internal),
        .flag_z     (alu_z_internal),
        .flag_c     (alu_c_internal),
        .flag_v     (alu_v_internal)
    );
    
    // 逻辑运算的 C 标志来自移位器
    assign alu_result = alu_result_internal;
    assign alu_n = alu_n_internal;
    assign alu_z = alu_z_internal;
    assign alu_c = is_arithmetic ? alu_c_internal : shifter_carry;
    assign alu_v = is_arithmetic ? alu_v_internal : cpsr_v;  // 逻辑运算不影响 V
    
    // ========================================================================
    // 条件判断
    // ========================================================================
    
    assign cpsr_n = cpsr_flags[3];
    assign cpsr_z = cpsr_flags[2];
    assign cpsr_c = cpsr_flags[1];
    assign cpsr_v = cpsr_flags[0];
    
    reg cond_result;
    
    always @(*) begin
        case (cond)
            `COND_EQ: cond_result = cpsr_z;                          // Equal
            `COND_NE: cond_result = ~cpsr_z;                         // Not Equal
            `COND_CS: cond_result = cpsr_c;                          // Carry Set
            `COND_CC: cond_result = ~cpsr_c;                         // Carry Clear
            `COND_MI: cond_result = cpsr_n;                          // Minus
            `COND_PL: cond_result = ~cpsr_n;                         // Plus
            `COND_VS: cond_result = cpsr_v;                          // Overflow Set
            `COND_VC: cond_result = ~cpsr_v;                         // Overflow Clear
            `COND_HI: cond_result = cpsr_c & ~cpsr_z;                // Higher
            `COND_LS: cond_result = ~cpsr_c | cpsr_z;                // Lower or Same
            `COND_GE: cond_result = (cpsr_n == cpsr_v);              // Greater or Equal
            `COND_LT: cond_result = (cpsr_n != cpsr_v);              // Less Than
            `COND_GT: cond_result = ~cpsr_z & (cpsr_n == cpsr_v);    // Greater Than
            `COND_LE: cond_result = cpsr_z | (cpsr_n != cpsr_v);     // Less or Equal
            `COND_AL: cond_result = 1'b1;                            // Always
            `COND_NV: cond_result = 1'b0;                            // Never
            default:  cond_result = 1'b1;
        endcase
    end
    
    assign cond_pass = cond_result;
    
    // ========================================================================
    // 分支逻辑
    // ========================================================================
    
    // 分支偏移量符号扩展并左移2位
    // offset = SignExtend(imm24) << 2
    // target = PC + 8 + offset  (流水线中 PC 已经 +8)
    wire [31:0] branch_offset;
    assign branch_offset = {{6{imm_data[23]}}, imm_data[23:0], 2'b00};
    
    assign branch_target = pc + 32'd8 + branch_offset;
    assign branch_taken  = branch & cond_pass;

endmodule
