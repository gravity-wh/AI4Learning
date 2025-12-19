# Lab 3: 寄存器文件与指令译码器

## 快速参考

### 文件结构
```
lab03_regfile_decoder/
├── Guide.md              # 详细实验指导
├── README.md             # 本文件
├── src/
│   ├── register_file.v   # 16×32位寄存器文件
│   └── decoder.v         # ARM指令译码器
└── tb/
    ├── tb_register_file.v # 寄存器文件测试
    └── tb_decoder.v       # 译码器测试
```

### 运行仿真

```tcl
# Vivado TCL
cd e:/AI4Learning/05_ARM_Cortex_A9/labs/lab03_regfile_decoder

# 编译
xvlog -i ../lab01_top_framework/src src/register_file.v src/decoder.v
xvlog -i ../lab01_top_framework/src tb/tb_register_file.v tb/tb_decoder.v

# 仿真寄存器文件
xelab tb_register_file -debug typical
xsim tb_register_file -R

# 仿真译码器
xelab tb_decoder -debug typical
xsim tb_decoder -R
```

### 关键模块接口

#### register_file.v
| 端口 | 方向 | 描述 |
|------|------|------|
| raddr1/2/3 | input | 3个读地址 |
| rdata1/2/3 | output | 3个读数据 |
| waddr | input | 写地址 |
| wdata | input | 写数据 |
| we | input | 写使能 |
| pc_in | input | 当前PC值 |

#### decoder.v
| 端口 | 方向 | 描述 |
|------|------|------|
| instruction | input | 32位ARM指令 |
| alu_op | output | ALU操作码 |
| reg_write | output | 寄存器写使能 |
| mem_read/write | output | 存储器访问 |
| branch | output | 分支指令 |
| inst_type | output | 指令类型 |

### 设计要点

1. **寄存器文件**
   - R15 读取返回 PC + 8
   - 写后读旁路 (Bypass)
   - 3读1写端口

2. **指令译码器**
   - 支持数据处理指令
   - 支持Load/Store指令
   - 支持分支指令
   - 条件码提取

### 预期结果

- 所有寄存器读写正确
- R15 正确返回 PC+8
- 写后读旁路工作正常
- 各类指令正确解码
