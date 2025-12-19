# Lab 2: ALU 与 Barrel Shifter 设计

本实验实现 ARM 处理器核心的算术逻辑单元和桶形移位器。

## 实验文件

- `Guide.md` - 详细实验指导
- `src/alu.v` - 算术逻辑单元
- `src/barrel_shifter.v` - 桶形移位器
- `tb/tb_alu.v` - ALU 测试平台
- `tb/tb_barrel_shifter.v` - 移位器测试平台

## 关键特性

- 支持全部 16 种 ARM ALU 操作
- NZCV 条件标志位生成
- 5 种移位模式 (LSL/LSR/ASR/ROR/RRX)
- 组合逻辑实现，单周期完成
