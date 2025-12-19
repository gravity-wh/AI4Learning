# Lab 1: 项目初始化与顶层框架设计

## 📋 实验概述

| 项目 | 内容 |
|------|------|
| **实验名称** | ARM Cortex-A9 顶层框架设计 |
| **预计时长** | 4-6 小时 |
| **难度等级** | ⭐⭐☆☆☆ |
| **前置实验** | 无 |

## 🎯 实验目标

1. 建立规范的 Vivado 项目结构
2. 理解 ARM Cortex-A9 处理器的顶层架构
3. 定义所有模块的接口信号
4. 创建顶层框架模块 `cortex_a9_top.v`
5. 编写基础测试平台验证框架

---

## 📚 理论背景

### ARM Cortex-A9 整体架构

```
                            ┌──────────────────────────────────────────────┐
                            │            ARM Cortex-A9 Core                │
                            │                                              │
    ┌──────────┐           │  ┌────────┐    ┌────────┐    ┌────────┐     │
    │ External │◀──────────┼─▶│  L1    │◀──▶│  CPU   │◀──▶│  L1    │     │
    │ Memory   │           │  │I-Cache │    │ Core   │    │D-Cache │     │
    └──────────┘           │  └────────┘    └────────┘    └────────┘     │
         ▲                 │       │             │             │          │
         │                 │       └─────────────┼─────────────┘          │
         │                 │                     │                        │
         │                 │              ┌──────▼──────┐                 │
         │                 │              │   L2 Cache  │                 │
         │                 │              │  Interface  │                 │
         │                 │              └──────┬──────┘                 │
         │                 │                     │                        │
         │                 └─────────────────────┼────────────────────────┘
         │                                       │
         └───────────────────────────────────────┘
                        AXI Bus Interface
```

### 5 级流水线概述

| 阶段 | 缩写 | 主要功能 | 关键模块 |
|------|------|----------|----------|
| 取指 | IF | 从内存获取指令 | PC, I-Cache, Branch Predictor |
| 译码 | ID | 解析指令，读寄存器 | Decoder, Register File |
| 执行 | EX | 算术/逻辑运算 | ALU, Barrel Shifter, Multiplier |
| 访存 | MEM | 数据存取 | D-Cache, Load/Store Unit |
| 写回 | WB | 结果写回寄存器 | Writeback Mux |

---

## 🔧 实验步骤

### 步骤 1: 创建 Vivado 项目

1. 启动 Vivado，选择 **Create Project**
2. 项目设置：
   - Project Name: `cortex_a9_hdl`
   - Project Location: 选择工作目录
   - Project Type: RTL Project
   - 取消勾选 "Do not specify sources at this time"
3. 选择目标器件（推荐）：
   - Part: `xc7z020clg400-1` (Zynq-7000)

### 步骤 2: 建立目录结构

在项目中创建以下目录结构：

```
cortex_a9_hdl/
├── src/
│   ├── core/           # 核心模块
│   │   ├── alu.v
│   │   ├── barrel_shifter.v
│   │   ├── register_file.v
│   │   └── ...
│   ├── cache/          # 缓存模块
│   │   ├── l1_icache.v
│   │   ├── l1_dcache.v
│   │   └── cache_controller.v
│   ├── memory/         # 存储接口
│   │   └── memory_interface.v
│   ├── pipeline/       # 流水线控制
│   │   ├── hazard_unit.v
│   │   └── forwarding_unit.v
│   └── top/           # 顶层模块
│       └── cortex_a9_top.v
├── tb/                 # 测试平台
│   └── tb_cortex_a9.v
├── include/            # 头文件
│   └── defines.vh
└── sim/                # 仿真脚本
    └── wave.do
```

### 步骤 3: 创建全局定义文件

创建 `include/defines.vh`，定义全局参数和常量。

### 步骤 4: 实现顶层模块框架

参考下方代码模板，创建 `cortex_a9_top.v`。

### 步骤 5: 创建基础测试平台

创建测试平台 `tb_cortex_a9.v`，验证模块实例化正确。

### 步骤 6: 运行综合检查

在 Vivado 中运行综合，确保无语法错误。

---

## 📝 代码模板

### defines.vh - 全局定义

```verilog
// ============================================================================
// File: defines.vh
// Description: Global definitions for ARM Cortex-A9 HDL implementation
// ============================================================================

`ifndef _DEFINES_VH_
`define _DEFINES_VH_

// ============================================================================
// 基本参数
// ============================================================================
`define DATA_WIDTH      32
`define ADDR_WIDTH      32
`define REG_ADDR_WIDTH  4   // 16 个通用寄存器 (R0-R15)
`define REG_NUM         16

// ============================================================================
// ALU 操作码
// ============================================================================
`define ALU_AND     4'b0000
`define ALU_EOR     4'b0001
`define ALU_SUB     4'b0010
`define ALU_RSB     4'b0011
`define ALU_ADD     4'b0100
`define ALU_ADC     4'b0101
`define ALU_SBC     4'b0110
`define ALU_RSC     4'b0111
`define ALU_TST     4'b1000
`define ALU_TEQ     4'b1001
`define ALU_CMP     4'b1010
`define ALU_CMN     4'b1011
`define ALU_ORR     4'b1100
`define ALU_MOV     4'b1101
`define ALU_BIC     4'b1110
`define ALU_MVN     4'b1111

// ============================================================================
// 移位类型
// ============================================================================
`define SHIFT_LSL   2'b00   // Logical Shift Left
`define SHIFT_LSR   2'b01   // Logical Shift Right
`define SHIFT_ASR   2'b10   // Arithmetic Shift Right
`define SHIFT_ROR   2'b11   // Rotate Right

// ============================================================================
// 条件码
// ============================================================================
`define COND_EQ     4'b0000 // Equal
`define COND_NE     4'b0001 // Not Equal
`define COND_CS     4'b0010 // Carry Set
`define COND_CC     4'b0011 // Carry Clear
`define COND_MI     4'b0100 // Minus (Negative)
`define COND_PL     4'b0101 // Plus (Positive or Zero)
`define COND_VS     4'b0110 // Overflow Set
`define COND_VC     4'b0111 // Overflow Clear
`define COND_HI     4'b1000 // Higher (unsigned)
`define COND_LS     4'b1001 // Lower or Same (unsigned)
`define COND_GE     4'b1010 // Greater or Equal (signed)
`define COND_LT     4'b1011 // Less Than (signed)
`define COND_GT     4'b1100 // Greater Than (signed)
`define COND_LE     4'b1101 // Less or Equal (signed)
`define COND_AL     4'b1110 // Always

// ============================================================================
// Cache 参数
// ============================================================================
`define CACHE_SIZE      4096    // 4KB
`define CACHE_LINE_SIZE 16      // 16 bytes per line
`define CACHE_WAYS      1       // Direct-mapped

// ============================================================================
// 指令类型
// ============================================================================
`define INST_TYPE_DP    3'b000  // Data Processing
`define INST_TYPE_MUL   3'b001  // Multiply
`define INST_TYPE_SDT   3'b010  // Single Data Transfer
`define INST_TYPE_BDT   3'b011  // Block Data Transfer
`define INST_TYPE_BR    3'b100  // Branch
`define INST_TYPE_SWI   3'b101  // Software Interrupt

`endif // _DEFINES_VH_
```

### cortex_a9_top.v - 顶层模块框架

```verilog
// ============================================================================
// File: cortex_a9_top.v
// Description: Top-level module for simplified ARM Cortex-A9 core
// Author: AI4ICLearning
// ============================================================================

`include "defines.vh"

module cortex_a9_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     clk,
    input  wire                     rst_n,
    
    // ========================================================================
    // 指令存储器接口 (I-Cache/Memory)
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]    imem_addr,
    output wire                     imem_rd_en,
    input  wire [DATA_WIDTH-1:0]    imem_rd_data,
    input  wire                     imem_rd_valid,
    
    // ========================================================================
    // 数据存储器接口 (D-Cache/Memory)
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]    dmem_addr,
    output wire [DATA_WIDTH-1:0]    dmem_wr_data,
    output wire                     dmem_wr_en,
    output wire                     dmem_rd_en,
    output wire [3:0]               dmem_byte_en,
    input  wire [DATA_WIDTH-1:0]    dmem_rd_data,
    input  wire                     dmem_rd_valid,
    
    // ========================================================================
    // 中断接口
    // ========================================================================
    input  wire                     irq,
    input  wire                     fiq,
    
    // ========================================================================
    // 调试接口
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]    debug_pc,
    output wire [DATA_WIDTH-1:0]    debug_instruction,
    output wire                     debug_halted
);

    // ========================================================================
    // 内部信号声明
    // ========================================================================
    
    // IF Stage Signals
    wire [ADDR_WIDTH-1:0]   if_pc;
    wire [ADDR_WIDTH-1:0]   if_pc_plus_4;
    wire [DATA_WIDTH-1:0]   if_instruction;
    wire                    if_valid;
    
    // IF/ID Pipeline Register Outputs
    wire [ADDR_WIDTH-1:0]   id_pc;
    wire [DATA_WIDTH-1:0]   id_instruction;
    wire                    id_valid;
    
    // ID Stage Signals
    wire [3:0]              id_cond;
    wire [3:0]              id_opcode;
    wire                    id_s_flag;
    wire [3:0]              id_rn;
    wire [3:0]              id_rd;
    wire [3:0]              id_rs;
    wire [3:0]              id_rm;
    wire [11:0]             id_imm12;
    wire [DATA_WIDTH-1:0]   id_rn_data;
    wire [DATA_WIDTH-1:0]   id_rm_data;
    wire [DATA_WIDTH-1:0]   id_rs_data;
    
    // ID Stage Control Signals
    wire                    id_reg_write;
    wire                    id_mem_read;
    wire                    id_mem_write;
    wire                    id_branch;
    wire                    id_alu_src;
    wire [3:0]              id_alu_op;
    wire [1:0]              id_shift_type;
    
    // ID/EX Pipeline Register Outputs
    wire [ADDR_WIDTH-1:0]   ex_pc;
    wire [DATA_WIDTH-1:0]   ex_rn_data;
    wire [DATA_WIDTH-1:0]   ex_rm_data;
    wire [DATA_WIDTH-1:0]   ex_rs_data;
    wire [3:0]              ex_rd;
    wire [DATA_WIDTH-1:0]   ex_imm_ext;
    wire                    ex_reg_write;
    wire                    ex_mem_read;
    wire                    ex_mem_write;
    wire [3:0]              ex_alu_op;
    wire [1:0]              ex_shift_type;
    wire [4:0]              ex_shift_amount;
    
    // EX Stage Signals
    wire [DATA_WIDTH-1:0]   ex_alu_result;
    wire [DATA_WIDTH-1:0]   ex_shifted_operand;
    wire [3:0]              ex_alu_flags;  // NZCV
    wire                    ex_branch_taken;
    wire [ADDR_WIDTH-1:0]   ex_branch_target;
    
    // EX/MEM Pipeline Register Outputs
    wire [DATA_WIDTH-1:0]   mem_alu_result;
    wire [DATA_WIDTH-1:0]   mem_write_data;
    wire [3:0]              mem_rd;
    wire                    mem_reg_write;
    wire                    mem_mem_read;
    wire                    mem_mem_write;
    
    // MEM Stage Signals
    wire [DATA_WIDTH-1:0]   mem_read_data;
    
    // MEM/WB Pipeline Register Outputs
    wire [DATA_WIDTH-1:0]   wb_alu_result;
    wire [DATA_WIDTH-1:0]   wb_mem_data;
    wire [3:0]              wb_rd;
    wire                    wb_reg_write;
    wire                    wb_mem_to_reg;
    
    // WB Stage Signals
    wire [DATA_WIDTH-1:0]   wb_write_data;
    
    // Hazard/Forwarding Signals
    wire                    stall_if;
    wire                    stall_id;
    wire                    flush_id;
    wire                    flush_ex;
    wire [1:0]              forward_a;
    wire [1:0]              forward_b;
    
    // CPSR (Current Program Status Register)
    reg  [31:0]             cpsr;
    wire                    cpsr_n, cpsr_z, cpsr_c, cpsr_v;
    
    // ========================================================================
    // 模块实例化
    // ========================================================================
    
    // ------------------------------------------------------------------------
    // Fetch Unit (IF Stage)
    // ------------------------------------------------------------------------
    fetch_unit #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_fetch_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        .stall          (stall_if),
        .branch_taken   (ex_branch_taken),
        .branch_target  (ex_branch_target),
        .pc             (if_pc),
        .pc_plus_4      (if_pc_plus_4),
        .imem_addr      (imem_addr),
        .imem_rd_en     (imem_rd_en),
        .imem_rd_data   (imem_rd_data),
        .imem_rd_valid  (imem_rd_valid),
        .instruction    (if_instruction),
        .valid          (if_valid)
    );
    
    // ------------------------------------------------------------------------
    // IF/ID Pipeline Register
    // ------------------------------------------------------------------------
    if_id_reg #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_if_id_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        .stall          (stall_id),
        .flush          (flush_id),
        .if_pc          (if_pc),
        .if_instruction (if_instruction),
        .if_valid       (if_valid),
        .id_pc          (id_pc),
        .id_instruction (id_instruction),
        .id_valid       (id_valid)
    );
    
    // ------------------------------------------------------------------------
    // Decode Unit (ID Stage)
    // ------------------------------------------------------------------------
    decode_unit #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_decode_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        .instruction    (id_instruction),
        .pc             (id_pc),
        // Control outputs
        .cond           (id_cond),
        .opcode         (id_opcode),
        .s_flag         (id_s_flag),
        .rn             (id_rn),
        .rd             (id_rd),
        .rs             (id_rs),
        .rm             (id_rm),
        .imm12          (id_imm12),
        .reg_write      (id_reg_write),
        .mem_read       (id_mem_read),
        .mem_write      (id_mem_write),
        .branch         (id_branch),
        .alu_src        (id_alu_src),
        .alu_op         (id_alu_op),
        .shift_type     (id_shift_type)
    );
    
    // ------------------------------------------------------------------------
    // Register File
    // ------------------------------------------------------------------------
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(4),
        .NUM_REGS(16)
    ) u_register_file (
        .clk            (clk),
        .rst_n          (rst_n),
        // Read ports
        .rd_addr_1      (id_rn),
        .rd_addr_2      (id_rm),
        .rd_addr_3      (id_rs),
        .rd_data_1      (id_rn_data),
        .rd_data_2      (id_rm_data),
        .rd_data_3      (id_rs_data),
        // Write port
        .wr_en          (wb_reg_write),
        .wr_addr        (wb_rd),
        .wr_data        (wb_write_data),
        // PC access
        .pc_in          (if_pc),
        .pc_out         ()
    );
    
    // ------------------------------------------------------------------------
    // ID/EX Pipeline Register
    // ------------------------------------------------------------------------
    id_ex_reg #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_id_ex_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        .flush          (flush_ex),
        // Inputs
        .id_pc          (id_pc),
        .id_rn_data     (id_rn_data),
        .id_rm_data     (id_rm_data),
        .id_rs_data     (id_rs_data),
        .id_rd          (id_rd),
        .id_imm12       (id_imm12),
        .id_reg_write   (id_reg_write),
        .id_mem_read    (id_mem_read),
        .id_mem_write   (id_mem_write),
        .id_alu_op      (id_alu_op),
        .id_shift_type  (id_shift_type),
        // Outputs
        .ex_pc          (ex_pc),
        .ex_rn_data     (ex_rn_data),
        .ex_rm_data     (ex_rm_data),
        .ex_rs_data     (ex_rs_data),
        .ex_rd          (ex_rd),
        .ex_imm_ext     (ex_imm_ext),
        .ex_reg_write   (ex_reg_write),
        .ex_mem_read    (ex_mem_read),
        .ex_mem_write   (ex_mem_write),
        .ex_alu_op      (ex_alu_op),
        .ex_shift_type  (ex_shift_type)
    );
    
    // ------------------------------------------------------------------------
    // Execute Unit (EX Stage)
    // ------------------------------------------------------------------------
    execute_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_execute_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        // Data inputs
        .rn_data        (ex_rn_data),
        .rm_data        (ex_rm_data),
        .imm_data       (ex_imm_ext),
        .pc             (ex_pc),
        // Control inputs
        .alu_op         (ex_alu_op),
        .shift_type     (ex_shift_type),
        .shift_amount   (ex_shift_amount),
        .alu_src        (1'b0),  // TODO: Connect properly
        .carry_in       (cpsr_c),
        // Forwarding inputs
        .forward_a      (forward_a),
        .forward_b      (forward_b),
        .mem_fwd_data   (mem_alu_result),
        .wb_fwd_data    (wb_write_data),
        // Outputs
        .alu_result     (ex_alu_result),
        .shifted_op     (ex_shifted_operand),
        .alu_flags      (ex_alu_flags),
        .branch_taken   (ex_branch_taken),
        .branch_target  (ex_branch_target)
    );
    
    // ------------------------------------------------------------------------
    // EX/MEM Pipeline Register
    // ------------------------------------------------------------------------
    ex_mem_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_ex_mem_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        // Inputs
        .ex_alu_result  (ex_alu_result),
        .ex_write_data  (ex_rm_data),
        .ex_rd          (ex_rd),
        .ex_reg_write   (ex_reg_write),
        .ex_mem_read    (ex_mem_read),
        .ex_mem_write   (ex_mem_write),
        // Outputs
        .mem_alu_result (mem_alu_result),
        .mem_write_data (mem_write_data),
        .mem_rd         (mem_rd),
        .mem_reg_write  (mem_reg_write),
        .mem_mem_read   (mem_mem_read),
        .mem_mem_write  (mem_mem_write)
    );
    
    // ------------------------------------------------------------------------
    // Memory Unit (MEM Stage)
    // ------------------------------------------------------------------------
    memory_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_memory_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        // Control
        .mem_read       (mem_mem_read),
        .mem_write      (mem_mem_write),
        // Data
        .addr           (mem_alu_result),
        .write_data     (mem_write_data),
        .read_data      (mem_read_data),
        // Memory interface
        .dmem_addr      (dmem_addr),
        .dmem_wr_data   (dmem_wr_data),
        .dmem_wr_en     (dmem_wr_en),
        .dmem_rd_en     (dmem_rd_en),
        .dmem_byte_en   (dmem_byte_en),
        .dmem_rd_data   (dmem_rd_data),
        .dmem_rd_valid  (dmem_rd_valid)
    );
    
    // ------------------------------------------------------------------------
    // MEM/WB Pipeline Register
    // ------------------------------------------------------------------------
    mem_wb_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_mem_wb_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        // Inputs
        .mem_alu_result (mem_alu_result),
        .mem_read_data  (mem_read_data),
        .mem_rd         (mem_rd),
        .mem_reg_write  (mem_reg_write),
        .mem_mem_read   (mem_mem_read),
        // Outputs
        .wb_alu_result  (wb_alu_result),
        .wb_mem_data    (wb_mem_data),
        .wb_rd          (wb_rd),
        .wb_reg_write   (wb_reg_write),
        .wb_mem_to_reg  (wb_mem_to_reg)
    );
    
    // ------------------------------------------------------------------------
    // Writeback Mux (WB Stage)
    // ------------------------------------------------------------------------
    assign wb_write_data = wb_mem_to_reg ? wb_mem_data : wb_alu_result;
    
    // ------------------------------------------------------------------------
    // Hazard Detection Unit
    // ------------------------------------------------------------------------
    hazard_unit u_hazard_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        // ID stage info
        .id_rn          (id_rn),
        .id_rm          (id_rm),
        .id_branch      (id_branch),
        // EX stage info
        .ex_rd          (ex_rd),
        .ex_mem_read    (ex_mem_read),
        // MEM stage info
        .mem_rd         (mem_rd),
        .mem_reg_write  (mem_reg_write),
        // Branch
        .branch_taken   (ex_branch_taken),
        // Control outputs
        .stall_if       (stall_if),
        .stall_id       (stall_id),
        .flush_id       (flush_id),
        .flush_ex       (flush_ex)
    );
    
    // ------------------------------------------------------------------------
    // Forwarding Unit
    // ------------------------------------------------------------------------
    forwarding_unit u_forwarding_unit (
        // EX stage source registers
        .ex_rn          (id_rn),  // TODO: Need EX stage source reg
        .ex_rm          (id_rm),  // TODO: Need EX stage source reg
        // MEM stage destination
        .mem_rd         (mem_rd),
        .mem_reg_write  (mem_reg_write),
        // WB stage destination
        .wb_rd          (wb_rd),
        .wb_reg_write   (wb_reg_write),
        // Forwarding control
        .forward_a      (forward_a),
        .forward_b      (forward_b)
    );
    
    // ========================================================================
    // CPSR 管理
    // ========================================================================
    assign cpsr_n = cpsr[31];
    assign cpsr_z = cpsr[30];
    assign cpsr_c = cpsr[29];
    assign cpsr_v = cpsr[28];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cpsr <= 32'h0000_001F;  // User mode
        end else begin
            // TODO: Update CPSR based on ALU flags when S bit is set
        end
    end
    
    // ========================================================================
    // 调试输出
    // ========================================================================
    assign debug_pc          = if_pc;
    assign debug_instruction = id_instruction;
    assign debug_halted      = 1'b0;  // TODO: Implement halt logic

endmodule
```

---

## 💡 设计要点解析

### 1. 模块化设计原则

每个流水线阶段都应封装为独立模块：
- **高内聚**: 模块内部功能紧密相关
- **低耦合**: 模块间通过定义良好的接口通信
- **可测试性**: 每个模块可独立验证

### 2. 流水线寄存器设计

流水线寄存器是流水线处理器的关键：

```verilog
// 流水线寄存器模板
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 异步复位
        stage_out_reg <= 'd0;
    end else if (flush) begin
        // 流水线冲刷 (插入气泡)
        stage_out_reg <= 'd0;
    end else if (!stall) begin
        // 正常流动
        stage_out_reg <= stage_in;
    end
    // stall 时保持不变
end
```

### 3. 命名规范

| 前缀 | 含义 | 示例 |
|------|------|------|
| `if_` | IF 阶段信号 | `if_pc`, `if_instruction` |
| `id_` | ID 阶段信号 | `id_opcode`, `id_rn` |
| `ex_` | EX 阶段信号 | `ex_alu_result` |
| `mem_` | MEM 阶段信号 | `mem_read_data` |
| `wb_` | WB 阶段信号 | `wb_write_data` |

---

## ✅ 检查点

完成本实验后，请确认：

- [ ] Vivado 项目创建成功
- [ ] 目录结构符合规范
- [ ] `defines.vh` 包含所有必要的宏定义
- [ ] `cortex_a9_top.v` 语法检查通过
- [ ] 所有模块接口已定义（模块体可为空）
- [ ] 综合运行无错误（允许警告）

---

## 📊 预期结果

运行综合后应看到：

1. **无语法错误**
2. **模块层次结构** 在 Hierarchy 窗口显示正确
3. **端口连接警告** 是正常的（子模块尚未实现）

---

---

## 📦 关键模块：Fetch Unit

### 模块概述

`fetch_unit.v` 是取指阶段 (IF Stage) 的核心模块，负责管理程序计数器 (PC) 和从指令存储器获取指令。

### 功能特性

1. **PC 管理**
   - 复位时初始化为 `0x00000000`
   - 正常执行时 PC 递增 (+4)
   - 支持分支跳转更新 PC

2. **流水线控制**
   - Stall: 暂停取指操作
   - Flush: 清除当前指令（插入气泡）
   - Branch: 处理分支跳转

3. **指令存储器接口**
   - 生成读地址和读使能
   - 接收指令数据

### 接口定义

```verilog
module fetch_unit #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // 时钟复位
    input  wire                     clk,
    input  wire                     rst_n,
    
    // 流水线控制
    input  wire                     stall,          // 暂停取指
    input  wire                     flush,          // 清除流水线
    input  wire                     branch_taken,   // 分支发生
    input  wire [ADDR_WIDTH-1:0]    branch_target,  // 分支目标地址
    
    // PC 输出
    output reg  [ADDR_WIDTH-1:0]    pc,             // 当前 PC
    output wire [ADDR_WIDTH-1:0]    pc_next,        // PC + 4
    
    // 指令存储器接口
    output wire [ADDR_WIDTH-1:0]    imem_addr,      // 指令地址
    output wire                     imem_rd_en,     // 读使能
    input  wire [DATA_WIDTH-1:0]    imem_rd_data,   // 指令数据
    input  wire                     imem_rd_valid,  // 数据有效
    
    // 输出
    output reg  [DATA_WIDTH-1:0]    instruction,    // 取得的指令
    output reg                      valid           // 指令有效标志
);
```

### PC 更新逻辑

```
                    ┌─────────────────────────────────────┐
                    │           PC 更新优先级             │
                    │                                     │
                    │  1. 复位 (rst_n = 0) → PC = 0       │
                    │  2. 分支 (branch_taken) → branch_target │
                    │  3. 暂停 (stall) → 保持不变        │
                    │  4. 正常 → PC + 4                  │
                    │                                     │
                    └─────────────────────────────────────┘
```

### 与 cortex_a9_top.v 的连接

在顶层模块中，fetch_unit 的实例化如下：

```verilog
fetch_unit #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) u_fetch_unit (
    .clk            (clk),
    .rst_n          (rst_n),
    .stall          (stall_if),         // 来自 hazard_unit
    .branch_taken   (ex_branch_taken),  // 来自 execute_unit
    .branch_target  (ex_branch_target), // 来自 execute_unit
    .pc             (if_pc),            // 连接到 IF/ID 寄存器
    .pc_plus_4      (if_pc_plus_4),
    .imem_addr      (imem_addr),        // 连接到外部指令存储器
    .imem_rd_en     (imem_rd_en),
    .imem_rd_data   (imem_rd_data),
    .imem_rd_valid  (imem_rd_valid),
    .instruction    (if_instruction),   // 连接到 IF/ID 寄存器
    .valid          (if_valid)
);
```

---

## 🔗 下一步

完成本实验后，继续 **Lab 2: ALU 与 Barrel Shifter 设计**，开始实现执行单元的核心组件。
