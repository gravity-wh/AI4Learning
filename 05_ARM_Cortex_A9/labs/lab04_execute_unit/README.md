# Lab 4: 执行单元 (EXU) 集成

## 快速参考

### 文件结构
```
lab04_execute_unit/
├── Guide.md              # 详细实验指导
├── README.md             # 本文件
└── src/
    └── execute_unit.v    # 执行单元集成模块
```

### 模块功能

Execute Unit 集成了以下组件：
- ALU (来自 Lab 2)
- Barrel Shifter (来自 Lab 2)
- 前递 MUX
- 条件判断逻辑
- 分支目标计算

### 接口说明

| 端口 | 方向 | 描述 |
|------|------|------|
| rn_data | input | 源操作数 1 |
| rm_data | input | 源操作数 2 |
| imm_data | input | 立即数 |
| forward_a/b | input | 前递选择 |
| alu_result | output | ALU 运算结果 |
| cond_pass | output | 条件通过标志 |
| branch_taken | output | 分支执行标志 |
| branch_target | output | 分支目标地址 |

### 运行仿真

```tcl
# 需要先编译依赖模块
xvlog -i ../lab01_top_framework/src ../lab02_alu_shifter/src/alu.v
xvlog -i ../lab01_top_framework/src ../lab02_alu_shifter/src/barrel_shifter.v
xvlog -i ../lab01_top_framework/src src/execute_unit.v
```

### 设计要点

1. **前递路径**
   - `FWD_NONE`: 使用寄存器文件数据
   - `FWD_MEM`: 使用 MEM 阶段数据
   - `FWD_WB`: 使用 WB 阶段数据

2. **条件执行**
   - 支持 16 种条件码
   - 根据 CPSR 标志判断

3. **分支计算**
   - target = PC + 8 + SignExtend(offset) << 2
