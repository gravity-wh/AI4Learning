# Lab 1: C与RISC-V编译工具链安装与配置

## 实验目的
1. 了解RISC-V架构和编译工具链
2. 安装RISC-V GCC工具链
3. 配置编译环境
4. 编译和运行简单的C程序

## 实验环境
- 操作系统：Linux/macOS/Windows（推荐使用Linux或WSL）
- 编译工具：RISC-V GCC工具链 (riscv64-unknown-elf-gcc)

## 实验步骤

### 1. 安装RISC-V GCC工具链

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install gcc-riscv64-unknown-elf
```

#### macOS (Homebrew)
```bash
brew tap riscv/riscv
brew install riscv-tools
```

#### Windows (WSL)
```bash
# 在WSL中安装sudo apt-get update
sudo apt-get install gcc-riscv64-unknown-elf
```

### 2. 验证安装
```bash
riscv64-unknown-elf-gcc --version
```

### 3. 编译简单的C程序

创建一个简单的C程序 `hello.c`：
```c
#include <stdio.h>

int main() {
    printf("Hello, RISC-V Assembly!\n");
    return 0;
}
```

编译C程序：
```bash
riscv64-unknown-elf-gcc -o hello hello.c
```

### 4. 生成汇编代码
```bash
riscv64-unknown-elf-gcc -S hello.c -o hello.s
```

### 5. 查看编译过程的各个阶段
```bash
# 预处理
riscv64-unknown-elf-gcc -E hello.c -o hello.i

# 编译为汇编
riscv64-unknown-elf-gcc -S hello.c -o hello.s

# 汇编为目标文件
riscv64-unknown-elf-as hello.s -o hello.o

# 链接为可执行文件
riscv64-unknown-elf-ld hello.o -o hello -lc -lm -L/opt/riscv/sysroot/lib -I/opt/riscv/sysroot/include
```

## 实验报告
1. 记录安装过程中遇到的问题和解决方案
2. 分析生成的汇编代码 `hello.s`，解释主要的指令
3. 总结编译过程的各个阶段及其作用

## 参考资源
- [RISC-V官方网站](https://riscv.org/)
- [RISC-V工具链安装指南](https://github.com/riscv/riscv-gnu-toolchain)
