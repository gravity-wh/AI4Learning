# Lab 9: 系统验证

## 快速参考

### 文件结构
```
lab09_verification/
├── Guide.md              # 详细实验指导
├── README.md             # 本文件
└── tb/
    └── tb_arm_core.v     # 综合测试平台
```

### 验证方法

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Test       │────▶│    DUT      │────▶│  Checker    │
│  Program    │     │ (arm_core)  │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

### 测试覆盖

| 测试类别 | 测试项 |
|----------|--------|
| 数据处理 | ADD, SUB, AND, ORR, MOV, CMP |
| 移位运算 | LSL, LSR, ASR, ROR |
| 存储访问 | LDR, STR |
| 分支 | B, BL, 条件分支 |
| 冒险 | 前递, Load-Use, 分支冲刷 |

### 运行测试

```tcl
# 编译
xvlog -i ../lab01_top_framework/src \
    ../lab02_alu_shifter/src/*.v \
    ../lab03_regfile_decoder/src/*.v \
    ../lab04_execute_unit/src/*.v \
    ../lab05_control_hazard/src/*.v \
    ../lab08_pipeline_integration/src/arm_core.v \
    tb/tb_arm_core.v

# 仿真
xelab tb_arm_core -debug typical
xsim tb_arm_core -R
```

### 自检测试程序

测试程序使用特定内存地址作为结果标志：
- `0x800`: 测试结果 (1=PASS, 0=FAIL)

### 波形调试

```tcl
# 打开波形
open_wave_database tb_arm_core.vcd

# 关键信号
add_wave /tb_arm_core/u_dut/pc
add_wave /tb_arm_core/u_dut/if_id_instr
add_wave /tb_arm_core/u_dut/id_ex_*
add_wave /tb_arm_core/u_dut/ex_mem_*
add_wave /tb_arm_core/u_dut/cpsr_flags
```

### 预期结果

- 所有基本指令测试通过
- 前递机制正确工作
- 分支正确执行
- 无死锁或意外行为
