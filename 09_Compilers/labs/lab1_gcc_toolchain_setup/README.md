# Lab 1: GCC/RISC-V 工具链搭建与编译流程

## 实验目标
1. 掌握 GCC/RISC-V 交叉编译工具链的安装与配置方法
2. 理解从 C 源代码到 RISC-V 可执行文件的完整编译流程
3. 学会使用 binutils 工具集分析编译产物
4. 理解编译过程中各个阶段的输出结果

## 实验背景
RISC-V 是一种开源的指令集架构，具有模块化、可扩展的特点，非常适合用于学习编译原理和处理器设计。GCC (GNU Compiler Collection) 是目前最流行的开源编译器之一，支持包括 RISC-V 在内的多种目标架构。

本实验将帮助你搭建 GCC/RISC-V 交叉编译工具链，并通过实际操作理解编译的完整流程，为后续的编译器后端开发和自定义指令集支持实验打下基础。

## 实验环境
- **操作系统**: Linux/macOS/Windows (推荐使用 Linux 或 WSL2)
- **磁盘空间**: 至少 10GB 可用空间
- **网络**: 需要下载工具链和依赖

## 实验步骤

### 1. 安装 GCC/RISC-V 交叉编译工具链

#### 方法 1: 使用预编译工具链（推荐）

##### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```

##### macOS (Homebrew)
```bash
brew tap riscv/riscv
brew install riscv-gnu-toolchain
```

##### Windows (WSL2)
在 WSL2 中按照 Linux 方法安装。

#### 方法 2: 从源代码编译工具链（高级）

如果需要最新版本或自定义配置，可以从源代码编译：

```bash
# 安装依赖
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

# 克隆仓库
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain

# 配置并编译
./configure --prefix=/opt/riscv --with-arch=rv32imac --with-abi=ilp32
sudo make -j$(nproc)

# 添加到环境变量
export PATH=/opt/riscv/bin:$PATH
```

### 2. 验证工具链安装

```bash
riscv64-unknown-elf-gcc --version
riscv64-unknown-elf-as --version
riscv64-unknown-elf-ld --version
```

如果安装成功，应该能看到类似以下的输出：
```
riscv64-unknown-elf-gcc (GCC) 12.2.0
Copyright (C) 2022 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

### 3. 编译流程实践

#### 3.1 创建简单的 C 程序

创建一个名为 `hello.c` 的文件，内容如下：

```c
#include <stdio.h>

int add(int a, int b) {
    return a + b;
}

int main() {
    int x = 5;
    int y = 3;
    int z = add(x, y);
    printf("Hello, RISC-V! %d + %d = %d\n", x, y, z);
    return 0;
}
```

#### 3.2 完整编译流程

编译过程包括四个主要阶段：预处理、编译、汇编和链接。

##### 阶段 1: 预处理 (Preprocessing)

```bash
riscv64-unknown-elf-gcc -E hello.c -o hello.i
```

这一步会：
- 展开 `#include` 指令
- 替换 `#define` 宏
- 处理条件编译指令（如 `#ifdef`）
- 删除注释

##### 阶段 2: 编译 (Compilation)

```bash
riscv64-unknown-elf-gcc -S hello.i -o hello.s
```

这一步会：
- 将预处理后的代码转换为汇编语言
- 进行语法分析、语义分析和中间代码生成
- 执行一些优化

##### 阶段 3: 汇编 (Assembly)

```bash
riscv64-unknown-elf-as hello.s -o hello.o
```

或使用 gcc 直接调用汇编器：

```bash
riscv64-unknown-elf-gcc -c hello.s -o hello.o
```

这一步会：
- 将汇编代码转换为机器码
- 生成目标文件（ELF 格式）

##### 阶段 4: 链接 (Linking)

```bash
riscv64-unknown-elf-gcc hello.o -o hello.elf
```

这一步会：
- 链接目标文件和所需的库
- 解析符号引用
- 分配最终的内存地址
- 生成可执行文件（ELF 格式）

#### 3.3 一步完成编译

也可以使用一条命令完成整个编译流程：

```bash
riscv64-unknown-elf-gcc hello.c -o hello.elf
```

### 4. 使用 binutils 工具分析编译产物

#### 4.1 查看汇编代码

```bash
cat hello.s
```

或使用 `objdump` 反汇编目标文件：

```bash
riscv64-unknown-elf-objdump -d hello.o
```

#### 4.2 查看 ELF 文件结构

```bash
riscv64-unknown-elf-readelf -a hello.elf
```

#### 4.3 反汇编可执行文件

```bash
riscv64-unknown-elf-objdump -d hello.elf
```

#### 4.4 查看符号表

```bash
riscv64-unknown-elf-nm hello.elf
```

#### 4.5 查看段信息

```bash
riscv64-unknown-elf-size hello.elf
```

### 5. 在模拟器上运行程序

可以使用 QEMU 或 Spike 模拟器运行生成的 RISC-V 程序。

#### 使用 QEMU

```bash
# 安装 QEMU
sudo apt-get install qemu-system-misc

# 运行程序
qemu-riscv64 hello.elf
```

#### 使用 Spike

```bash
# 安装 Spike
git clone https://github.com/riscv-software-src/riscv-isa-sim
cd riscv-isa-sim
mkdir build && cd build
../configure
make -j$(nproc)
sudo make install

# 运行程序
spike pk hello.elf
```

## 实验内容

1. **工具链安装**:
   - 选择一种方法安装 GCC/RISC-V 交叉编译工具链
   - 验证工具链安装成功

2. **编译流程实践**:
   - 创建 `hello.c` 文件
   - 按照四个阶段分别编译，查看每个阶段的输出
   - 分析汇编代码，理解 C 代码与汇编代码的对应关系

3. **工具使用**:
   - 使用 `objdump` 反汇编目标文件和可执行文件
   - 使用 `readelf` 查看 ELF 文件结构
   - 使用 `nm` 和 `size` 分析符号表和段信息

4. **程序运行**:
   - 在模拟器上运行生成的可执行文件
   - 观察程序输出

## 实验结果分析

1. **预处理结果分析**:
   - 查看 `hello.i` 文件，观察 `#include <stdio.h>` 展开后的结果
   - 注意文件大小的变化

2. **汇编代码分析**:
   - 找到 `main` 函数和 `add` 函数对应的汇编代码
   - 分析参数传递和返回值处理的方式
   - 观察栈的使用情况

3. **ELF 文件分析**:
   - 识别 ELF 文件的各个节（.text, .data, .bss 等）
   - 理解程序头表和节头表的作用
   - 分析符号表中的符号类型和属性

4. **反汇编分析**:
   - 对比汇编器生成的汇编代码和反汇编的结果
   - 理解机器码与汇编指令的对应关系

## 思考问题

1. 编译过程中的四个阶段分别完成了什么任务？为什么需要将编译过程分为这四个阶段？

2. 预处理后的文件（.i）与原始 C 文件相比有什么变化？

3. C 代码中的函数调用在汇编代码中是如何实现的？参数是如何传递的？返回值是如何处理的？

4. ELF 文件中的 .text、.data 和 .bss 节分别包含什么内容？它们的特点是什么？

5. 链接过程的主要作用是什么？为什么需要链接器？

6. 交叉编译与本地编译有什么区别？为什么在开发 RISC-V 程序时需要使用交叉编译？

## 实验总结

通过本实验，你应该已经掌握了：
1. GCC/RISC-V 交叉编译工具链的安装和配置方法
2. 从 C 源代码到 RISC-V 可执行文件的完整编译流程
3. 使用 binutils 工具集分析编译产物的方法
4. 在模拟器上运行 RISC-V 程序的方法

这些知识将为后续的实验，特别是编译器后端开发和自定义指令集支持实验打下坚实的基础。

## 参考资料
- [RISC-V 官方网站](https://riscv.org/)
- [GCC 官方文档](https://gcc.gnu.org/onlinedocs/)
- [Binutils 官方文档](https://sourceware.org/binutils/docs/)
- [QEMU 官方网站](https://www.qemu.org/)
- [Spike 模拟器](https://github.com/riscv-software-src/riscv-isa-sim)
