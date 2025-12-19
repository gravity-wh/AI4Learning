# Lab 2: ALU 与 Barrel Shifter 设计

## 实验概述

| 项目               | 内容                       |
| ------------------ | -------------------------- |
| **实验名称** | ALU 与 Barrel Shifter 设计 |
| **预计时长** | 6-8 小时                   |
| **难度等级** | ⭐⭐⭐☆☆                 |
| **前置实验** | Lab 1                      |

## 实验目标

1. 理解 ARM 指令集中 ALU 操作的完整定义
2. 实现支持全部 16 种 ALU 操作的算术逻辑单元
3. 实现高效的 Barrel Shifter（桶形移位器）
4. 正确生成和更新 NZCV 条件标志位
5. 掌握组合逻辑优化技术

---

## 理论背景

### ARM 数据处理指令格式

```
31  28 27 26 25 24       21 20 19    16 15    12 11           0
┌──────┬─────┬──┬──────────┬──┬────────┬────────┬──────────────┐
│ Cond │ 00  │I │  Opcode  │S │   Rn   │   Rd   │   Operand2   │
└──────┴─────┴──┴──────────┴──┴────────┴────────┴──────────────┘
  4位    2位  1位   4位     1位  4位      4位        12位
```

#### Operand2 格式

**当 I=0（寄存器操作数）时：**

```
11        7 6  5 4 3      0
┌──────────┬────┬─┬────────┐
│  Shift   │Type│0│   Rm   │
└──────────┴────┴─┴────────┘
     5位    2位  1位  4位

或者（寄存器移位）：
11      8 7 6  5 4 3      0
┌────────┬─┬────┬─┬────────┐
│   Rs   │0│Type│1│   Rm   │
└────────┴─┴────┴─┴────────┘
    4位   1位 2位 1位  4位
```

**当 I=1（立即数操作数）时：**

```
11       8 7             0
┌─────────┬───────────────┐
│  Rotate │   Immediate   │
└─────────┴───────────────┘
    4位         8位

立即数 = Immediate ROR (Rotate * 2)
```

### ALU 操作真值表

| Opcode | 助记符 | 操作                 | 结果写入 | 更新标志    |
| ------ | ------ | -------------------- | -------- | ----------- |
| 0000   | AND    | Rd := Rn AND Op2     | ✓       | ✓ (如 S=1) |
| 0001   | EOR    | Rd := Rn XOR Op2     | ✓       | ✓ (如 S=1) |
| 0010   | SUB    | Rd := Rn - Op2       | ✓       | ✓ (如 S=1) |
| 0011   | RSB    | Rd := Op2 - Rn       | ✓       | ✓ (如 S=1) |
| 0100   | ADD    | Rd := Rn + Op2       | ✓       | ✓ (如 S=1) |
| 0101   | ADC    | Rd := Rn + Op2 + C   | ✓       | ✓ (如 S=1) |
| 0110   | SBC    | Rd := Rn - Op2 - !C  | ✓       | ✓ (如 S=1) |
| 0111   | RSC    | Rd := Op2 - Rn - !C  | ✓       | ✓ (如 S=1) |
| 1000   | TST    | Rn AND Op2           | ✗       | ✓          |
| 1001   | TEQ    | Rn XOR Op2           | ✗       | ✓          |
| 1010   | CMP    | Rn - Op2             | ✗       | ✓          |
| 1011   | CMN    | Rn + Op2             | ✗       | ✓          |
| 1100   | ORR    | Rd := Rn OR Op2      | ✓       | ✓ (如 S=1) |
| 1101   | MOV    | Rd := Op2            | ✓       | ✓ (如 S=1) |
| 1110   | BIC    | Rd := Rn AND NOT Op2 | ✓       | ✓ (如 S=1) |
| 1111   | MVN    | Rd := NOT Op2        | ✓       | ✓ (如 S=1) |

### 条件标志位计算

#### N (Negative) 标志

```verilog
N = Result[31];  // 结果的最高位
```

#### Z (Zero) 标志

```verilog
Z = (Result == 32'h0);  // 结果为零
```

#### C (Carry) 标志

- **加法操作**: 产生进位时 C=1
- **减法操作**: 无借位时 C=1（即 A >= B）
- **移位操作**: 最后移出的位

```verilog
// 加法进位检测
{C, Result} = A + B + Cin;

// 减法进位（借位取反）
{C, Result} = A + (~B) + 1;  // C=1 表示无借位
```

#### V (Overflow) 标志

仅对有符号运算有意义：

```verilog
// 加法溢出：两个同号数相加，结果变号
V_add = (A[31] == B[31]) && (Result[31] != A[31]);

// 减法溢出：两个异号数相减，结果与被减数异号
V_sub = (A[31] != B[31]) && (Result[31] != A[31]);
```

### Barrel Shifter 原理

Barrel Shifter 是一种能在单周期内完成任意位数移位的组合电路。

#### 移位类型

```
LSL (Logical Shift Left):
    ┌───────────────────────────┐
    │  Input[30:0]    │    0    │
    └───────────────────────────┘
    C ← MSB

LSR (Logical Shift Right):
    ┌───────────────────────────┐
    │    0    │  Input[31:1]    │
    └───────────────────────────┘
              LSB → C

ASR (Arithmetic Shift Right):
    ┌───────────────────────────┐
    │Input[31]│  Input[31:1]    │
    └───────────────────────────┘
    符号位扩展，LSB → C

ROR (Rotate Right):
    ┌───────────────────────────┐
    │Input[n-1:0]│Input[31:n]   │
    └───────────────────────────┘
    位循环移动，Input[0] → C

RRX (Rotate Right Extended):
    ┌───────────────────────────┐
    │    C    │  Input[31:1]    │
    └───────────────────────────┘
    带进位循环右移1位
```

#### 多级 Mux 实现

32位 Barrel Shifter 使用 5 级 Mux：

```
Level 0: 移位 0 或 16 位
Level 1: 移位 0 或 8 位
Level 2: 移位 0 或 4 位
Level 3: 移位 0 或 2 位
Level 4: 移位 0 或 1 位

移位量 = shift_amount[4:0]
每一级由 shift_amount 的对应位控制
```

---

## 🔧 实验步骤

### 步骤 1: 实现 ALU 模块

创建 `src/alu.v`：

```verilog
// ============================================================================
// File: alu.v
// Description: 32-bit ALU for ARM Cortex-A9
// ============================================================================

`include "defines.vh"

module alu #(
    parameter DATA_WIDTH = 32
)(
    // 操作数
    input  wire [DATA_WIDTH-1:0]    operand_a,      // Rn
    input  wire [DATA_WIDTH-1:0]    operand_b,      // Shifted Rm 或立即数
    input  wire                     carry_in,       // 输入进位 (来自 CPSR.C)
  
    // 控制
    input  wire [3:0]               alu_op,         // ALU 操作码
  
    // 结果
    output reg  [DATA_WIDTH-1:0]    result,         // 运算结果
  
    // 标志输出
    output wire                     flag_n,         // Negative
    output wire                     flag_z,         // Zero
    output reg                      flag_c,         // Carry
    output reg                      flag_v          // Overflow
);

    // ========================================================================
    // 内部信号
    // ========================================================================
    wire [DATA_WIDTH-1:0]   not_b;
    wire [DATA_WIDTH:0]     add_result;     // 33位，包含进位
    wire [DATA_WIDTH:0]     sub_result;     // 33位，包含借位
    wire [DATA_WIDTH:0]     rsb_result;     // 反向减法
    wire [DATA_WIDTH:0]     adc_result;     // 带进位加法
    wire [DATA_WIDTH:0]     sbc_result;     // 带借位减法
    wire [DATA_WIDTH:0]     rsc_result;     // 带借位反向减法
  
    wire                    overflow_add;
    wire                    overflow_sub;
    wire                    overflow_rsb;
  
    // ========================================================================
    // 预计算
    // ========================================================================
    assign not_b = ~operand_b;
  
    // 加法类运算
    assign add_result = {1'b0, operand_a} + {1'b0, operand_b};
    assign adc_result = {1'b0, operand_a} + {1'b0, operand_b} + carry_in;
  
    // 减法类运算 (A - B = A + (~B) + 1)
    assign sub_result = {1'b0, operand_a} + {1'b0, not_b} + 1'b1;
    assign sbc_result = {1'b0, operand_a} + {1'b0, not_b} + carry_in;
  
    // 反向减法 (B - A)
    assign rsb_result = {1'b0, operand_b} + {1'b0, ~operand_a} + 1'b1;
    assign rsc_result = {1'b0, operand_b} + {1'b0, ~operand_a} + carry_in;
  
    // 溢出检测
    assign overflow_add = (operand_a[31] == operand_b[31]) && 
                          (add_result[31] != operand_a[31]);
    assign overflow_sub = (operand_a[31] != operand_b[31]) && 
                          (sub_result[31] != operand_a[31]);
    assign overflow_rsb = (operand_b[31] != operand_a[31]) && 
                          (rsb_result[31] != operand_b[31]);
  
    // ========================================================================
    // ALU 操作选择
    // ========================================================================
    always @(*) begin
        // 默认值
        result = {DATA_WIDTH{1'b0}};
        flag_c = carry_in;
        flag_v = 1'b0;
      
        case (alu_op)
            `ALU_AND: begin
                result = operand_a & operand_b;
                // C 由移位器产生
            end
          
            `ALU_EOR: begin
                result = operand_a ^ operand_b;
            end
          
            `ALU_SUB: begin
                result = sub_result[DATA_WIDTH-1:0];
                flag_c = sub_result[DATA_WIDTH];  // 无借位时 C=1
                flag_v = overflow_sub;
            end
          
            `ALU_RSB: begin
                result = rsb_result[DATA_WIDTH-1:0];
                flag_c = rsb_result[DATA_WIDTH];
                flag_v = overflow_rsb;
            end
          
            `ALU_ADD: begin
                result = add_result[DATA_WIDTH-1:0];
                flag_c = add_result[DATA_WIDTH];
                flag_v = overflow_add;
            end
          
            `ALU_ADC: begin
                result = adc_result[DATA_WIDTH-1:0];
                flag_c = adc_result[DATA_WIDTH];
                flag_v = (operand_a[31] == operand_b[31]) && 
                         (adc_result[31] != operand_a[31]);
            end
          
            `ALU_SBC: begin
                result = sbc_result[DATA_WIDTH-1:0];
                flag_c = sbc_result[DATA_WIDTH];
                flag_v = (operand_a[31] != operand_b[31]) && 
                         (sbc_result[31] != operand_a[31]);
            end
          
            `ALU_RSC: begin
                result = rsc_result[DATA_WIDTH-1:0];
                flag_c = rsc_result[DATA_WIDTH];
                flag_v = (operand_b[31] != operand_a[31]) && 
                         (rsc_result[31] != operand_b[31]);
            end
          
            `ALU_TST: begin
                result = operand_a & operand_b;
                // 仅设置标志，不写回
            end
          
            `ALU_TEQ: begin
                result = operand_a ^ operand_b;
            end
          
            `ALU_CMP: begin
                result = sub_result[DATA_WIDTH-1:0];
                flag_c = sub_result[DATA_WIDTH];
                flag_v = overflow_sub;
            end
          
            `ALU_CMN: begin
                result = add_result[DATA_WIDTH-1:0];
                flag_c = add_result[DATA_WIDTH];
                flag_v = overflow_add;
            end
          
            `ALU_ORR: begin
                result = operand_a | operand_b;
            end
          
            `ALU_MOV: begin
                result = operand_b;
            end
          
            `ALU_BIC: begin
                result = operand_a & not_b;
            end
          
            `ALU_MVN: begin
                result = not_b;
            end
          
            default: begin
                result = {DATA_WIDTH{1'b0}};
            end
        endcase
    end
  
    // ========================================================================
    // N 和 Z 标志
    // ========================================================================
    assign flag_n = result[DATA_WIDTH-1];
    assign flag_z = (result == {DATA_WIDTH{1'b0}});

endmodule
```

### 步骤 2: 实现 Barrel Shifter

创建 `src/barrel_shifter.v`：

```verilog
// ============================================================================
// File: barrel_shifter.v
// Description: 32-bit Barrel Shifter for ARM Cortex-A9
// ============================================================================

`include "defines.vh"

module barrel_shifter #(
    parameter DATA_WIDTH = 32
)(
    // 输入
    input  wire [DATA_WIDTH-1:0]    data_in,        // 输入数据 (Rm)
    input  wire [4:0]               shift_amount,   // 移位量 (0-31)
    input  wire [1:0]               shift_type,     // 移位类型
    input  wire                     carry_in,       // 输入进位 (用于 RRX)
  
    // 输出
    output reg  [DATA_WIDTH-1:0]    data_out,       // 移位结果
    output reg                      carry_out       // 移位产生的进位
);

    // ========================================================================
    // 内部信号
    // ========================================================================
    wire [DATA_WIDTH-1:0]   lsl_result;
    wire [DATA_WIDTH-1:0]   lsr_result;
    wire [DATA_WIDTH-1:0]   asr_result;
    wire [DATA_WIDTH-1:0]   ror_result;
    wire [DATA_WIDTH-1:0]   rrx_result;
  
    wire                    lsl_carry;
    wire                    lsr_carry;
    wire                    asr_carry;
    wire                    ror_carry;
    wire                    rrx_carry;
  
    // 符号扩展填充
    wire [DATA_WIDTH-1:0]   sign_fill;
  
    // ========================================================================
    // 符号扩展
    // ========================================================================
    assign sign_fill = {DATA_WIDTH{data_in[DATA_WIDTH-1]}};
  
    // ========================================================================
    // LSL (Logical Shift Left)
    // ========================================================================
    assign lsl_result = (shift_amount == 5'd0) ? data_in : 
                        (data_in << shift_amount);
    assign lsl_carry  = (shift_amount == 5'd0) ? carry_in :
                        (shift_amount > 5'd32) ? 1'b0 :
                        data_in[DATA_WIDTH - shift_amount];
  
    // ========================================================================
    // LSR (Logical Shift Right)
    // ========================================================================
    assign lsr_result = (shift_amount == 5'd0) ? data_in :
                        (data_in >> shift_amount);
    assign lsr_carry  = (shift_amount == 5'd0) ? carry_in :
                        (shift_amount > 5'd32) ? 1'b0 :
                        data_in[shift_amount - 1];
  
    // ========================================================================
    // ASR (Arithmetic Shift Right)
    // ========================================================================
    assign asr_result = (shift_amount == 5'd0) ? data_in :
                        ($signed(data_in) >>> shift_amount);
    assign asr_carry  = (shift_amount == 5'd0) ? carry_in :
                        (shift_amount >= 5'd32) ? data_in[DATA_WIDTH-1] :
                        data_in[shift_amount - 1];
  
    // ========================================================================
    // ROR (Rotate Right)
    // ========================================================================
    wire [63:0] ror_extended;
    assign ror_extended = {data_in, data_in};
    assign ror_result = (shift_amount == 5'd0) ? data_in :
                        ror_extended[shift_amount +: DATA_WIDTH];
    assign ror_carry  = (shift_amount == 5'd0) ? carry_in :
                        data_in[(shift_amount - 1) & 5'h1F];
  
    // ========================================================================
    // RRX (Rotate Right Extended) - 仅移位1位
    // ========================================================================
    assign rrx_result = {carry_in, data_in[DATA_WIDTH-1:1]};
    assign rrx_carry  = data_in[0];
  
    // ========================================================================
    // 输出选择
    // ========================================================================
    always @(*) begin
        case (shift_type)
            `SHIFT_LSL: begin
                data_out  = lsl_result;
                carry_out = lsl_carry;
            end
          
            `SHIFT_LSR: begin
                // LSR #0 编码为 LSR #32
                if (shift_amount == 5'd0) begin
                    data_out  = {DATA_WIDTH{1'b0}};
                    carry_out = data_in[DATA_WIDTH-1];
                end else begin
                    data_out  = lsr_result;
                    carry_out = lsr_carry;
                end
            end
          
            `SHIFT_ASR: begin
                // ASR #0 编码为 ASR #32
                if (shift_amount == 5'd0) begin
                    data_out  = sign_fill;
                    carry_out = data_in[DATA_WIDTH-1];
                end else begin
                    data_out  = asr_result;
                    carry_out = asr_carry;
                end
            end
          
            `SHIFT_ROR: begin
                // ROR #0 编码为 RRX
                if (shift_amount == 5'd0) begin
                    data_out  = rrx_result;
                    carry_out = rrx_carry;
                end else begin
                    data_out  = ror_result;
                    carry_out = ror_carry;
                end
            end
          
            default: begin
                data_out  = data_in;
                carry_out = carry_in;
            end
        endcase
    end

endmodule
```

### 步骤 3: 创建测试平台

创建 `tb/tb_alu.v`：

```verilog
// ============================================================================
// File: tb_alu.v
// Description: Testbench for ALU module
// ============================================================================

`timescale 1ns / 1ps

`include "defines.vh"

module tb_alu;

    // 参数
    parameter DATA_WIDTH = 32;
  
    // 测试信号
    reg  [DATA_WIDTH-1:0]   operand_a;
    reg  [DATA_WIDTH-1:0]   operand_b;
    reg                     carry_in;
    reg  [3:0]              alu_op;
    wire [DATA_WIDTH-1:0]   result;
    wire                    flag_n, flag_z, flag_c, flag_v;
  
    // 测试计数
    integer test_count;
    integer pass_count;
  
    // DUT 实例化
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
  
    // 测试任务
    task test_operation;
        input [DATA_WIDTH-1:0] a;
        input [DATA_WIDTH-1:0] b;
        input                  cin;
        input [3:0]            op;
        input [DATA_WIDTH-1:0] expected;
        input [3:0]            expected_flags;  // NZCV
        begin
            operand_a = a;
            operand_b = b;
            carry_in  = cin;
            alu_op    = op;
            #10;
          
            test_count = test_count + 1;
          
            if (result === expected && 
                {flag_n, flag_z, flag_c, flag_v} === expected_flags) begin
                pass_count = pass_count + 1;
                $display("[PASS] Test %0d: Op=%b A=0x%08h B=0x%08h => R=0x%08h NZCV=%b%b%b%b",
                         test_count, op, a, b, result, flag_n, flag_z, flag_c, flag_v);
            end else begin
                $display("[FAIL] Test %0d: Op=%b A=0x%08h B=0x%08h", test_count, op, a, b);
                $display("       Expected: R=0x%08h NZCV=%b", expected, expected_flags);
                $display("       Got:      R=0x%08h NZCV=%b%b%b%b", result, flag_n, flag_z, flag_c, flag_v);
            end
        end
    endtask
  
    // 主测试
    initial begin
        test_count = 0;
        pass_count = 0;
      
        $display("========================================");
        $display("ALU Testbench Starting");
        $display("========================================");
      
        // ADD 测试
        $display("\n--- ADD Tests ---");
        test_operation(32'h00000001, 32'h00000001, 1'b0, `ALU_ADD, 32'h00000002, 4'b0000);
        test_operation(32'hFFFFFFFF, 32'h00000001, 1'b0, `ALU_ADD, 32'h00000000, 4'b0110);  // Zero, Carry
        test_operation(32'h7FFFFFFF, 32'h00000001, 1'b0, `ALU_ADD, 32'h80000000, 4'b1001);  // Negative, Overflow
      
        // SUB 测试
        $display("\n--- SUB Tests ---");
        test_operation(32'h00000005, 32'h00000003, 1'b0, `ALU_SUB, 32'h00000002, 4'b0010);  // Carry set (no borrow)
        test_operation(32'h00000003, 32'h00000005, 1'b0, `ALU_SUB, 32'hFFFFFFFE, 4'b1000);  // Negative
        test_operation(32'h80000000, 32'h00000001, 1'b0, `ALU_SUB, 32'h7FFFFFFF, 4'b0011);  // Overflow
      
        // AND 测试
        $display("\n--- AND Tests ---");
        test_operation(32'hFF00FF00, 32'h0F0F0F0F, 1'b0, `ALU_AND, 32'h0F000F00, 4'b0000);
        test_operation(32'hFFFFFFFF, 32'h00000000, 1'b0, `ALU_AND, 32'h00000000, 4'b0100);  // Zero
      
        // ORR 测试
        $display("\n--- ORR Tests ---");
        test_operation(32'hFF00FF00, 32'h00FF00FF, 1'b0, `ALU_ORR, 32'hFFFFFFFF, 4'b1000);  // Negative
      
        // EOR 测试
        $display("\n--- EOR Tests ---");
        test_operation(32'hAAAAAAAA, 32'h55555555, 1'b0, `ALU_EOR, 32'hFFFFFFFF, 4'b1000);
        test_operation(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0, `ALU_EOR, 32'h00000000, 4'b0100);
      
        // MOV 测试
        $display("\n--- MOV Tests ---");
        test_operation(32'h00000000, 32'h12345678, 1'b0, `ALU_MOV, 32'h12345678, 4'b0000);
      
        // MVN 测试
        $display("\n--- MVN Tests ---");
        test_operation(32'h00000000, 32'h00000000, 1'b0, `ALU_MVN, 32'hFFFFFFFF, 4'b1000);
      
        // ADC 测试
        $display("\n--- ADC Tests ---");
        test_operation(32'h00000001, 32'h00000001, 1'b1, `ALU_ADC, 32'h00000003, 4'b0000);
      
        // SBC 测试
        $display("\n--- SBC Tests ---");
        test_operation(32'h00000005, 32'h00000003, 1'b1, `ALU_SBC, 32'h00000002, 4'b0010);
        test_operation(32'h00000005, 32'h00000003, 1'b0, `ALU_SBC, 32'h00000001, 4'b0010);
      
        // 报告
        $display("\n========================================");
        $display("Tests Complete: %0d/%0d Passed", pass_count, test_count);
        $display("========================================");
      
        $finish;
    end

endmodule
```

---

## 设计要点

### 1. 进位链优化

对于高性能设计，可考虑使用超前进位加法器：

```verilog
// 生成和传播信号
wire [31:0] G = operand_a & operand_b;  // Generate
wire [31:0] P = operand_a ^ operand_b;  // Propagate

// 4位组进位计算
// C4 = G3 + P3G2 + P3P2G1 + P3P2P1G0 + P3P2P1P0C0
```

### 2. 关键路径分析

```
最长路径：减法运算
operand_a → 加法器 → 溢出检测 → flag_v

建议：
1. 分离标志计算和结果计算
2. 考虑在综合后检查时序报告
```

### 3. 移位器优化

使用对数移位器减少延迟：

```verilog
// 5级对数移位器
wire [31:0] shift_16 = shift_amount[4] ? {data[15:0], 16'b0} : data;
wire [31:0] shift_8  = shift_amount[3] ? {shift_16[23:0], 8'b0} : shift_16;
wire [31:0] shift_4  = shift_amount[2] ? {shift_8[27:0], 4'b0} : shift_8;
wire [31:0] shift_2  = shift_amount[1] ? {shift_4[29:0], 2'b0} : shift_4;
wire [31:0] shift_1  = shift_amount[0] ? {shift_2[30:0], 1'b0} : shift_2;
```

---

## 检查点

- [ ] ALU 支持全部 16 种操作
- [ ] NZCV 标志正确生成
- [ ] Barrel Shifter 支持 LSL/LSR/ASR/ROR/RRX
- [ ] 移位进位正确计算
- [ ] 所有测试用例通过

---

## 综合结果参考

在 Zynq-7020 上的参考结果：

| 模块           | LUT  | FF | 最大频率 |
| -------------- | ---- | -- | -------: |
| ALU            | ~150 | 0  | >200 MHz |
| Barrel Shifter | ~100 | 0  | >250 MHz |

---

## 下一步

完成本实验后，继续 **Lab 3: 寄存器文件与译码单元**。
