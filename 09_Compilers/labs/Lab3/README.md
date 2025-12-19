# Lab 3: 自定义指令集扩展与 GCC 后端修改

## 实验目标
1. 理解如何在 GCC 后端添加自定义 RISC-V 指令
2. 掌握修改 GCC 后端文件的基本方法
3. 学习重新编译 GCC 以应用自定义修改
4. 验证自定义指令是否正确生成和执行

## 实验背景

在实际的处理器设计中，经常需要添加自定义指令来加速特定应用。GCC 提供了灵活的扩展机制，允许我们通过修改后端文件来支持新的指令。本实验将指导你添加一个自定义的 RISC-V 指令，并验证其正确性。

### 自定义指令设计

我们将添加一个名为 `sum4` 的自定义指令，该指令可以同时对四个 32 位整数进行求和操作。指令格式如下：

```
sum4 rd, rs1, rs2, rs3, rs4
```

功能：`rd = rs1 + rs2 + rs3 + rs4`

## 实验环境

- 已搭建完成的 GCC/RISC-V 工具链开发环境（来自 Lab1）
- 完整的 GCC 源码树
- 支持 RISC-V 指令集扩展的模拟器或硬件平台

## 实验步骤

### 1. 准备工作

#### 1.1 进入 GCC 源码目录

```bash
cd ~/gcc_riscv_lab/gcc-12.2.0
```

#### 1.2 了解 RISC-V 指令集架构

RISC-V 指令集采用模块化设计，自定义指令通常放在自定义扩展中。我们将使用 `X` 开头的扩展名称，例如 `Xsum4`。

### 2. 修改 RISC-V 后端文件

#### 2.1 修改指令模式定义文件 (riscv.md)

指令模式定义文件是添加新指令的核心。我们需要在其中定义指令的模式、约束和输出模板。

```bash
# 备份原始文件
cp gcc/riscv.md gcc/riscv.md.bak

# 编辑 riscv.md 文件
vim gcc/riscv.md
```

在文件中添加以下内容：

```
;; 自定义指令: sum4
(define_insn "sum4"
  [(set (match_operand:SI 0 "register_operand" "=r")
        (plus:SI
          (plus:SI
            (plus:SI
              (match_operand:SI 1 "register_operand" "r")
              (match_operand:SI 2 "register_operand" "r"))
            (match_operand:SI 3 "register_operand" "r"))
          (match_operand:SI 4 "register_operand" "r")))
]
"TARGET_XSUM4"
  "sum4\t%0, %1, %2, %3, %4"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")
])
```

这个定义告诉 GCC：
- 指令名称为 `sum4`
- 操作数 0 是目标寄存器 (rd)
- 操作数 1-4 是源寄存器 (rs1-rs4)
- 指令在 TARGET_XSUM4 条件下可用（我们将在后面定义这个目标选项）
- 汇编输出模板为 `sum4\t%0, %1, %2, %3, %4`

#### 2.2 添加目标选项定义 (riscv.opt)

```bash
# 备份原始文件
cp gcc/riscv.opt gcc/riscv.opt.bak

# 编辑 riscv.opt 文件
vim gcc/riscv.opt
```

在文件中添加以下内容：

```
-mxsum4
Target Undocumented Var(riscv_xsum4) Init(0) Save
Enable Xsum4 extension.
```

这定义了一个新的命令行选项 `-mxsum4`，用于启用我们的自定义扩展。

#### 2.3 更新目标宏定义 (riscv.h)

```bash
# 备份原始文件
cp gcc/config/riscv/riscv.h gcc/config/riscv/riscv.h.bak

# 编辑 riscv.h 文件
vim gcc/config/riscv/riscv.h
```

在文件中添加以下宏定义：

```c
/* Xsum4 extension */
#define TARGET_XSUM4 (riscv_xsum4)
#define MASK_XSUM4    0x40000000
#define RISCV_XSUM4     (1 << 30)
```

这定义了 TARGET_XSUM4 宏，用于在条件中检查扩展是否启用。

#### 2.4 更新子目标相关代码 (riscv-subtarget.c)

```bash
# 备份原始文件
cp gcc/config/riscv/riscv-subtarget.c gcc/config/riscv/riscv-subtarget.c.bak

# 编辑 riscv-subtarget.c 文件
vim gcc/config/riscv/riscv-subtarget.c
```

在文件中添加以下内容：

1. 在 `riscv_subtarget` 结构体中添加字段：

```c
unsigned int xsum4 : 1;        /* Xsum4 extension */
```

2. 在 `RISCV_SUBTARGET_INITIALIZER` 宏中添加初始化：

```c
.xsum4       = 0,
```

3. 在 `riscv_parse_cpu` 函数中添加支持：

```c
/* 可以在这里添加对自定义CPU的支持 */
```

4. 在 `riscv_override_options` 函数中添加：

```c
riscv_subtarget.xsum4 |= riscv_xsum4;
```

5. 在 `riscv_emit_attributes` 函数中添加属性：

```c
if (riscv_subtarget.xsum4)
  fprintf (file,