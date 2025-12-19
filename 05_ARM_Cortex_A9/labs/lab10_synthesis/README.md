# Lab 10: 综合与时序分析

## 快速参考

### 文件结构
```
lab10_synthesis/
├── Guide.md              # 详细实验指导
├── README.md             # 本文件
└── constraints/
    └── timing.xdc        # 时序约束文件
```

### 目标器件

| 参数 | 值 |
|------|------|
| 器件 | Zynq-7000 |
| 型号 | xc7z020clg400-1 |
| 目标频率 | 100 MHz |

### Vivado 工作流程

```bash
# 1. 创建工程
create_project arm_core ./arm_core -part xc7z020clg400-1

# 2. 添加源文件
add_files [glob ../lab*/src/*.v]
add_files -fileset constrs_1 constraints/timing.xdc

# 3. 综合
synth_design -top arm_core

# 4. 实现
opt_design
place_design
route_design

# 5. 生成报告
report_timing_summary
report_utilization
```

### 时序约束

| 约束类型 | 说明 |
|----------|------|
| create_clock | 定义时钟周期 |
| set_input_delay | 输入延迟 |
| set_output_delay | 输出延迟 |
| set_false_path | 异步路径 |
| set_multicycle_path | 多周期路径 |

### 时序分析

```
Slack = T_clk - T_clk2q - T_logic - T_setup - T_uncertainty

WNS (Worst Negative Slack) ≥ 0 表示时序满足
```

### 资源利用目标

| 资源 | 目标利用率 |
|------|------------|
| LUT | < 50% |
| FF | < 30% |
| BRAM | < 20% |
| DSP | < 10% |

### 优化策略

1. **流水线化**
   - 拆分长组合路径
   
2. **资源复制**
   - 减少高扇出信号

3. **存储器优化**
   - 使用 BRAM 实现 Cache

### 输出文件

- `*.bit`: 比特流文件
- `timing_summary.rpt`: 时序报告
- `utilization.rpt`: 资源报告
