# ARM Cortex-A9 HDL 原理仿真实验课程大纲

## 📋 课程概述

本课程旨在通过 **自顶向下（Top-Down）** 的设计方法，使用 Verilog HDL 实现一个简化版的 ARM Cortex-A9 处理器核心的功能仿真模型。本课程参考 Berkeley EECS 151/251A、MIT 6.004、Stanford EE282 等顶级大学处理器设计课程的教学方法。

### 🎯 学习目标

完成本课程后，学生将能够：

1. 理解 ARM Cortex-A9 的整体架构和流水线设计
2. 掌握 Verilog HDL 模块化设计和层次化封装技术
3. 实现并验证处理器核心的关键功能模块
4. 使用 Vivado 进行完整的仿真和综合流程
5. 理解现代高性能处理器的设计理念

### 📚 先修知识

- 数字电路设计基础
- Verilog HDL 基本语法
- 计算机组成原理（流水线、Cache 等概念）
- ARM 指令集架构基础

---

## 📐 ARM Cortex-A9 架构概览

### 处理器特性

| 特性 | 规格 |
|------|------|
| 架构 | ARMv7-A |
| 流水线级数 | 8-11 级（取决于配置） |
| 发射宽度 | 双发射、乱序执行 |
| 分支预测 | 全局历史 + 局部历史混合预测 |
| L1 Cache | 16KB-64KB I-Cache + D-Cache |
| L2 接口 | AXI 接口，支持外部 L2 Cache |

### 简化设计目标

本实验实现一个 **教学简化版本**：

- **单发射、顺序执行** 的 5 级流水线
- 支持 ARM 指令集的核心子集
- 简化的 Cache 系统
- 简化的存储接口

---

## 🏗️ 模块层次结构

```
cortex_a9_top
├── fetch_unit (取指单元)
│   ├── program_counter
│   ├── instruction_memory_interface
│   └── branch_predictor (简化版)
├── decode_unit (译码单元)
│   ├── instruction_decoder
│   ├── register_file
│   └── immediate_generator
├── execute_unit (执行单元)
│   ├── alu
│   ├── barrel_shifter
│   ├── multiplier
│   └── branch_unit
├── memory_unit (访存单元)
│   ├── data_cache
│   ├── load_store_unit
│   └── memory_interface
├── writeback_unit (写回单元)
├── hazard_unit (冒险处理单元)
│   ├── forwarding_unit
│   └── stall_controller
├── control_unit (控制单元)
│   └── pipeline_controller
└── cache_system (缓存系统)
    ├── l1_icache
    ├── l1_dcache
    └── cache_controller
```

---

## 📅 实验安排

### Lab 1: 项目初始化与顶层框架设计
- **目标**: 建立项目结构，定义顶层模块接口
- **时长**: 1 周
- **交付物**: 顶层模块框架 `cortex_a9_top.v`

### Lab 2: ALU 与 Barrel Shifter 设计
- **目标**: 实现算术逻辑单元和桶形移位器
- **时长**: 1 周
- **交付物**: `alu.v`, `barrel_shifter.v`, 测试平台

### Lab 3: 寄存器文件与译码单元
- **目标**: 实现 32 位寄存器文件和指令译码器
- **时长**: 1.5 周
- **交付物**: `register_file.v`, `decoder.v`

### Lab 4: 执行单元 (EXU) 集成
- **目标**: 整合 ALU、Shifter、乘法器
- **时长**: 1 周
- **交付物**: `execute_unit.v`

### Lab 5: 控制单元 (CU) 设计
- **目标**: 实现流水线控制逻辑
- **时长**: 1.5 周
- **交付物**: `control_unit.v`, `hazard_unit.v`

### Lab 6: 缓存系统设计
- **目标**: 实现简化的 L1 Cache
- **时长**: 2 周
- **交付物**: `l1_cache.v`, `cache_controller.v`

### Lab 7: 存储接口设计
- **目标**: 实现 AXI-Lite 兼容的存储接口
- **时长**: 1.5 周
- **交付物**: `memory_interface.v`

### Lab 8: 流水线集成与同步
- **目标**: 整合所有模块，处理流水线冒险
- **时长**: 2 周
- **交付物**: 完整流水线处理器

### Lab 9: 系统验证与测试
- **目标**: 运行测试程序，验证功能正确性
- **时长**: 1.5 周
- **交付物**: 测试报告，仿真波形

### Lab 10: 综合与时序分析
- **目标**: 在 Vivado 中进行综合，分析 PPA
- **时长**: 1 周
- **交付物**: 综合报告，时序分析

---

## 🛠️ 开发环境

### 必需工具

| 工具 | 版本 | 用途 |
|------|------|------|
| Xilinx Vivado | 2022.2+ | 仿真、综合、实现 |
| VS Code | Latest | 代码编辑 |
| Git | Latest | 版本控制 |

### 目标平台

- **仿真验证**: Vivado Simulator
- **可选 FPGA 验证**: Zynq-7000 系列（如 ZedBoard）

---

## 📖 参考资料

### 官方文档
1. ARM Cortex-A9 Technical Reference Manual (DDI0388)
2. ARM Architecture Reference Manual ARMv7-A and ARMv7-R edition

### 教科书
1. Patterson & Hennessy - *Computer Organization and Design: ARM Edition*
2. Harris & Harris - *Digital Design and Computer Architecture: ARM Edition*

### 在线课程
1. Berkeley EECS 151/251A - Introduction to Digital Design
2. MIT 6.004 - Computation Structures
3. Stanford EE282 - Computer Systems Architecture

---

## 📊 评估标准

| 组成部分 | 权重 |
|----------|------|
| 模块实现正确性 | 40% |
| 代码规范与可读性 | 15% |
| 测试平台完整性 | 20% |
| 综合结果 (PPA) | 15% |
| 文档与报告 | 10% |

---

*本课程设计参考 Berkeley、MIT、Stanford 等顶级大学的处理器设计课程，结合 ARM Cortex-A9 技术手册编制。*
