# Lab 2: GCC 后端架构与中间表示分析

## 实验目标
1. 掌握 GCC 源码的目录结构，定位 RISC-V 后端相关文件
2. 理解 GCC 中间表示 GIMPLE 和 RTL 的结构与用途
3. 学会使用 GCC 调试选项生成和分析中间表示
4. 分析 RISC-V 后端的关键文件，理解编译器后端的工作原理

## 实验背景
GCC 采用了前后端分离的架构，前端负责将源代码转换为中间表示（IR），中端负责优化中间表示，后端负责将优化后的中间表示转换为目标平台的机器代码。

GCC 使用两种主要的中间表示：
- **GIMPLE**: 高级中间表示，接近源代码结构，适合进行高级优化
- **RTL (Register Transfer Language)**: 低级中间表示，接近目标平台指令，适合进行机器相关的优化和代码生成

本实验将通过分析 GCC 源码和生成的中间表示，帮助你理解 GCC 后端的工作原理，为后续修改 GCC 后端支持自定义指令集打下基础。

## 实验环境
- **操作系统**: Linux (推荐 Ubuntu 20.04 或更高版本)
- **GCC 工具链**: 已安装的 GCC/RISC-V 交叉编译工具链
- **GCC 源码**: 需要下载 GCC 源代码
- **磁盘空间**: 至少 20GB 可用空间（用于存放 GCC 源码和构建文件）

## 实验步骤

### 1. 获取 GCC 源码

#### 1.1 下载 GCC 源码

```bash
# 创建工作目录
mkdir -p ~/gcc_riscv_lab && cd ~/gcc_riscv_lab

# 下载 GCC 源码（选择稳定版本）
wget https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz

# 解压源码
tar -xf gcc-12.2.0.tar.gz
cd gcc-12.2.0

# 下载依赖
./contrib/download_prerequisites
```

#### 1.2 查看 GCC 目录结构

```bash
ls -la
```

主要目录说明：
- `gcc/`: 主编译器目录，包含 GCC 的核心代码
- `libgcc/`: GCC 运行时库
- `libstdc++-v3/`: C++ 标准库
- `riscv/`: RISC-V 后端相关文件（可能在 gcc 目录下）

### 2. 分析 GCC 后端目录结构

```bash
# 定位 RISC-V 后端文件
find . -name "riscv*.c" -o -name "riscv*.h" -o -name "riscv*.md"

# 进入 GCC 主目录
cd gcc

# 查看 RISC-V 后端文件
ls -la riscv*
```

RISC-V 后端的关键文件：
- `riscv.md`: 指令模式定义文件，包含 RISC-V 指令的 RTL 模板
- `riscv.c`: 目标平台特定的代码生成函数
- `riscv-protos.h`: RISC-V 后端函数原型声明
- `riscv.opt`: RISC-V 相关的命令行选项定义
- `riscv-subtarget.c`: RISC-V 子目标相关代码
- `riscv-c.c`: RISC-V C 语言特定代码

### 3. 生成和分析 GIMPLE

#### 3.1 创建示例 C 程序

创建一个名为 `simple_math.c` 的文件，内容如下：

```c
extern int printf(const char *format, ...);

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    int result = 0;
    for (int i = 0; i < b; i++) {
        result = add(result, a);
    }
    return result;
}

int main() {
    int x = 5;
    int y = 3;
    int sum = add(x, y);
    int product = multiply(x, y);
    printf("Sum: %d, Product: %d\n", sum, product);
    return 0;
}
```

#### 3.2 生成 GIMPLE

使用 GCC 的 `-fdump-tree-*` 选项生成 GIMPLE 表示：

```bash
# 生成所有 GIMPLE 阶段的输出
riscv64-unknown-elf-gcc -fdump-tree-all simple_math.c -o simple_math.elf

# 查看生成的文件
ls -la simple_math.c.*
```

主要的 GIMPLE 输出文件：
- `simple_math.c.004t.gimple`: 初始 GIMPLE
- `simple_math.c.005t.omplower`: 简化后的 GIMPLE
- `simple_math.c.014t.cfg`: 控制流图

#### 3.3 分析 GIMPLE

查看初始 GIMPLE：

```bash
cat simple_math.c.004t.gimple
```

GIMPLE 是一种三地址码，每个语句最多包含三个操作数。分析 GIMPLE 代码，理解以下内容：
- 函数定义和参数传递
- 变量声明和赋值
- 控制流结构（循环、条件）
- 函数调用

### 4. 生成和分析 RTL

#### 4.1 生成 RTL

使用 GCC 的 `-fdump-rtl-*` 选项生成 RTL 表示：

```bash
# 生成所有 RTL 阶段的输出
riscv64-unknown-elf-gcc -fdump-rtl-all simple_math.c -o simple_math.elf

# 查看生成的文件
ls -la simple_math.c.*rtl*
```

主要的 RTL 输出文件：
- `simple_math.c.008t.rtl`: 初始 RTL
- `simple_math.c.016t.into_cfglayout`: 控制流图布局后的 RTL
- `simple_math.c.021t.split1`: 指令拆分后的 RTL
- `simple_math.c.157r.dfinish`: 最终的 RTL

#### 4.2 分析 RTL

查看最终的 RTL：

```bash
cat simple_math.c.157r.dfinish
```

RTL 是一种基于寄存器传输的中间表示，描述了指令级别的操作。分析 RTL 代码，理解以下内容：
- RTL 表达式的结构
- 指令模板的定义
- 寄存器的使用
- 内存访问操作

### 5. 分析 RISC-V 后端关键文件

#### 5.1 分析 riscv.md 文件

riscv.md 文件包含了 RISC-V 指令的 RTL 模式定义，是 GCC 后端最重要的文件之一。

```bash
# 查看 riscv.md 文件的前 100 行
head -n 100 riscv.md

# 搜索特定指令的模式定义
grep -A 10 "define_insn.*add" riscv.md
```

riscv.md 文件中的主要结构：
- `define_insn`: 定义普通指令的模式
- `define_expand`: 定义可扩展的指令模式
- `define_split`: 定义指令拆分规则
- `define_peephole`: 定义窥孔优化规则
- `define_constraint`: 定义寄存器和操作数约束

#### 5.2 分析 riscv.c 文件

riscv.c 文件包含了 RISC-V 目标平台特定的代码生成函数。

```bash
# 查看 riscv.c 文件的前 100 行
head -n 100 riscv.c

# 搜索指令生成相关函数
grep -n "riscv_emit" riscv.c
```

riscv.c 文件中的主要内容：
- 指令生成函数
- 寄存器分配相关函数
- 内存访问相关函数
- 目标平台特定的优化函数

#### 5.3 分析 riscv-protos.h 文件

riscv-protos.h 文件包含了 RISC-V 后端函数的原型声明。

```bash
# 查看 riscv-protos.h 文件
cat riscv-protos.h
```

### 6. 使用 GCC 调试选项

GCC 提供了许多调试选项，可以帮助我们理解编译过程：

```bash
# 显示编译的各个阶段
riscv64-unknown-elf-gcc -v simple_math.c -o simple_math.elf

# 生成汇编代码并显示行号对应关系
riscv64-unknown-elf-gcc -S -fverbose-asm simple_math.c -o simple_math.s

# 生成带有 RTL 注释的汇编代码
riscv64-unknown-elf-gcc -S -fdump-rtl-final simple_math.c -o simple_math.s
```

## 实验内容

1. **GCC 源码分析**:
   - 下载 GCC 源码并查看目录结构
   - 定位 RISC-V 后端相关文件
   - 理解主要目录和文件的用途

2. **GIMPLE 分析**:
   - 创建示例 C 程序
   - 生成 GIMPLE 表示
   - 分析 GIMPLE 的结构和内容
   - 理解 GIMPLE 与源代码的对应关系

3. **RTL 分析**:
   - 生成 RTL 表示
   - 分析 RTL 的结构和内容
   - 理解 RTL 与 GIMPLE 的转换关系
   - 分析 RTL 与最终汇编代码的对应关系

4. **RISC-V 后端文件分析**:
   - 分析 riscv.md 文件中的指令模式定义
   - 分析 riscv.c 文件中的代码生成函数
   - 理解 riscv-protos.h 中的函数原型

## 实验结果分析

1. **GIMPLE 与 RTL 比较**:
   - 对比 GIMPLE 和 RTL 的表达方式
   - 分析它们在编译流程中的不同作用
   - 理解为什么需要两种不同的中间表示

2. **指令模式分析**:
   - 分析 riscv.md 中 ADD 指令的模式定义
   - 理解模式匹配的原理
   - 分析指令模式如何映射到实际的机器指令

3. **代码生成流程**:
   - 跟踪从源代码到最终汇编代码的转换过程
   - 理解每个阶段的主要任务和输出结果
   - 分析 GCC 后端的工作流程

## 思考问题

1. GIMPLE 和 RTL 有什么区别？它们分别适合进行哪种类型的优化？

2. GCC 为什么采用分层的中间表示？这种设计有什么优势？

3. riscv.md 文件中的指令模式是如何与实际的机器指令对应的？

4. RTL 中的表达式结构是怎样的？如何理解 RTL 指令？

5. 从 GIMPLE 到 RTL 的转换过程中发生了哪些主要变化？

6. 如何通过修改 RISC-V 后端文件来支持新的指令？

## 实验总结

通过本实验，你应该已经掌握了：
1. GCC 源码的目录结构和 RISC-V 后端的关键文件
2. GIMPLE 和 RTL 中间表示的结构和用途
3. 使用 GCC 调试选项生成和分析中间表示的方法
4. RISC-V 后端的工作原理和指令生成过程

这些知识将为后续的自定义指令集支持和编译器后端开发实验打下坚实的基础。

## 参考资料
- [GCC Internals Manual](https://gcc.gnu.org/onlinedocs/gccint/)
- [GCC Wiki](https://gcc.gnu.org/wiki/)
- [RISC-V GCC Port](https://github.com/riscv-collab/riscv-gcc)
- [Understanding GCC RTL](https://gcc.gnu.org/onlinedocs/gccint/RTL.html)
- [Understanding GIMPLE](https://gcc.gnu.org/onlinedocs/gccint/GIMPLE.html)
