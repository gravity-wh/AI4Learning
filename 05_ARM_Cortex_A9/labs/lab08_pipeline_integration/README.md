# Lab 8: 完整流水线集成

## 快速参考

### 文件结构
```
lab08_pipeline_integration/
├── Guide.md              # 详细实验指导
├── README.md             # 本文件
└── src/
    └── arm_core.v        # 完整处理器核心
```

### 流水线阶段

| 阶段 | 模块 | 功能 |
|------|------|------|
| IF | PC, I-Cache | 取指令 |
| ID | Decoder, RegFile | 译码、读寄存器 |
| EX | ALU, Shifter | 执行运算 |
| MEM | D-Cache | 存储器访问 |
| WB | - | 写回寄存器 |

### 流水线寄存器

| 寄存器 | 主要内容 |
|------|------|
| IF/ID | PC, Instruction |
| ID/EX | 操作数, 控制信号, Rd |
| EX/MEM | ALU结果, 写数据, Rd |
| MEM/WB | 结果, Rd |

### 集成的模块

```
arm_core
├── register_file      (Lab 3)
├── decoder           (Lab 3)
├── execute_unit      (Lab 4)
│   ├── alu           (Lab 2)
│   └── barrel_shifter (Lab 2)
├── hazard_unit       (Lab 5)
└── forwarding_unit   (Lab 5)
```

### 运行仿真

```tcl
# 编译所有源文件
xvlog -i ../lab01_top_framework/src \
    ../lab02_alu_shifter/src/alu.v \
    ../lab02_alu_shifter/src/barrel_shifter.v \
    ../lab03_regfile_decoder/src/register_file.v \
    ../lab03_regfile_decoder/src/decoder.v \
    ../lab04_execute_unit/src/execute_unit.v \
    ../lab05_control_hazard/src/hazard_unit.v \
    ../lab05_control_hazard/src/forwarding_unit.v \
    src/arm_core.v
```

### 设计要点

1. **数据路径**
   - 前递从 EX/MEM 和 MEM/WB
   - Load-Use 暂停一周期

2. **控制路径**
   - 分支在 EX 确定
   - 分支延迟 2 周期

3. **CPSR 更新**
   - S 位指令更新标志
   - 条件执行判断
