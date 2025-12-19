// ============================================================================
// File: barrel_shifter.v
// Description: 32-bit Barrel Shifter for ARM Cortex-A9
//              Supports LSL, LSR, ASR, ROR, and RRX operations
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module barrel_shifter #(
    parameter DATA_WIDTH = 32
)(
    // ========================================================================
    // 数据输入
    // ========================================================================
    input  wire [DATA_WIDTH-1:0]    data_in,        // 输入数据 (Rm)
    input  wire [4:0]               shift_amount,   // 移位量 (0-31)
    input  wire [1:0]               shift_type,     // 移位类型
    input  wire                     carry_in,       // 输入进位 (用于 RRX 和默认)
    input  wire                     shift_by_reg,   // 1=寄存器移位量, 0=立即数移位量
    
    // ========================================================================
    // 数据输出
    // ========================================================================
    output reg  [DATA_WIDTH-1:0]    data_out,       // 移位结果
    output reg                      carry_out       // 移位产生的进位
);

    // ========================================================================
    // 内部信号
    // ========================================================================
    
    // 各类移位结果
    reg  [DATA_WIDTH-1:0]   lsl_out;
    reg                     lsl_carry;
    reg  [DATA_WIDTH-1:0]   lsr_out;
    reg                     lsr_carry;
    reg  [DATA_WIDTH-1:0]   asr_out;
    reg                     asr_carry;
    reg  [DATA_WIDTH-1:0]   ror_out;
    reg                     ror_carry;
    
    // RRX 结果
    wire [DATA_WIDTH-1:0]   rrx_out;
    wire                    rrx_carry;
    
    // 64位扩展用于循环移位
    wire [2*DATA_WIDTH-1:0] ror_extended;
    
    // ========================================================================
    // LSL (Logical Shift Left)
    // ========================================================================
    always @(*) begin
        if (shift_amount == 5'd0) begin
            // LSL #0: 保持不变
            lsl_out   = data_in;
            lsl_carry = carry_in;
        end else if (shift_amount < 6'd32) begin
            lsl_out   = data_in << shift_amount;
            lsl_carry = data_in[DATA_WIDTH - shift_amount];
        end else if (shift_amount == 6'd32) begin
            lsl_out   = {DATA_WIDTH{1'b0}};
            lsl_carry = data_in[0];
        end else begin
            // shift_amount > 32
            lsl_out   = {DATA_WIDTH{1'b0}};
            lsl_carry = 1'b0;
        end
    end
    
    // ========================================================================
    // LSR (Logical Shift Right)
    // ========================================================================
    always @(*) begin
        if (shift_amount == 5'd0) begin
            if (shift_by_reg) begin
                // Rs = 0: 保持不变
                lsr_out   = data_in;
                lsr_carry = carry_in;
            end else begin
                // LSR #0 编码为 LSR #32
                lsr_out   = {DATA_WIDTH{1'b0}};
                lsr_carry = data_in[DATA_WIDTH-1];
            end
        end else if (shift_amount < 6'd32) begin
            lsr_out   = data_in >> shift_amount;
            lsr_carry = data_in[shift_amount - 1];
        end else if (shift_amount == 6'd32) begin
            lsr_out   = {DATA_WIDTH{1'b0}};
            lsr_carry = data_in[DATA_WIDTH-1];
        end else begin
            // shift_amount > 32
            lsr_out   = {DATA_WIDTH{1'b0}};
            lsr_carry = 1'b0;
        end
    end
    
    // ========================================================================
    // ASR (Arithmetic Shift Right) - 保持符号位
    // ========================================================================
    always @(*) begin
        if (shift_amount == 5'd0) begin
            if (shift_by_reg) begin
                // Rs = 0: 保持不变
                asr_out   = data_in;
                asr_carry = carry_in;
            end else begin
                // ASR #0 编码为 ASR #32
                asr_out   = {DATA_WIDTH{data_in[DATA_WIDTH-1]}};
                asr_carry = data_in[DATA_WIDTH-1];
            end
        end else if (shift_amount < 6'd32) begin
            asr_out   = $signed(data_in) >>> shift_amount;
            asr_carry = data_in[shift_amount - 1];
        end else begin
            // shift_amount >= 32
            asr_out   = {DATA_WIDTH{data_in[DATA_WIDTH-1]}};
            asr_carry = data_in[DATA_WIDTH-1];
        end
    end
    
    // ========================================================================
    // ROR (Rotate Right)
    // ========================================================================
    assign ror_extended = {data_in, data_in};
    
    always @(*) begin
        if (shift_amount == 5'd0) begin
            if (shift_by_reg) begin
                // Rs = 0: 保持不变
                ror_out   = data_in;
                ror_carry = carry_in;
            end else begin
                // ROR #0 编码为 RRX (带扩展循环右移)
                ror_out   = rrx_out;
                ror_carry = rrx_carry;
            end
        end else begin
            // ROR by n 等价于 ROR by (n mod 32)
            ror_out   = ror_extended[shift_amount[4:0] +: DATA_WIDTH];
            ror_carry = data_in[(shift_amount[4:0] - 1) & 5'h1F];
        end
    end
    
    // ========================================================================
    // RRX (Rotate Right with Extend) - 33位循环右移1位
    // ========================================================================
    assign rrx_out   = {carry_in, data_in[DATA_WIDTH-1:1]};
    assign rrx_carry = data_in[0];
    
    // ========================================================================
    // 输出多路选择器
    // ========================================================================
    always @(*) begin
        case (shift_type)
            `SHIFT_LSL: begin
                data_out  = lsl_out;
                carry_out = lsl_carry;
            end
            
            `SHIFT_LSR: begin
                data_out  = lsr_out;
                carry_out = lsr_carry;
            end
            
            `SHIFT_ASR: begin
                data_out  = asr_out;
                carry_out = asr_carry;
            end
            
            `SHIFT_ROR: begin
                data_out  = ror_out;
                carry_out = ror_carry;
            end
            
            default: begin
                data_out  = data_in;
                carry_out = carry_in;
            end
        endcase
    end

endmodule
