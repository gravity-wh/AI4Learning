# Lab 2: RISC-V汇编语言基础

## 实验目的
1. 理解RISC-V汇编语言的基本语法
2. 掌握RISC-V的基本指令集
3. 学会编写简单的汇编程序
4. 使用汇编器和链接器生成可执行文件
5. 使用调试器调试汇编程序

## 实验环境
- RISC-V GCC工具链
- 文本编辑器（如VS Code、Vim）
- GDB调试器

## RISC-V汇编基础

### 1. 寄存器
RISC-V有32个通用寄存器（x0-x31），部分寄存器有特殊用途：
- x0: 恒为0
- x1 (ra): 返回地址
- x2 (sp): 栈指针
- x3 (gp): 全局指针
- x4 (tp): 线程指针
- x5-x7 (t0-t2): 临时寄存器
- x8-x9 (s0-s1): 保存寄存器
- x10-x17 (a0-a7): 函数参数和返回值

### 2. 基本指令
- **加载/存储**: lw, sw, lb, sb
- **算术/逻辑**: add, sub, and, or, xor, sll, srl, sra
- **分支/跳转**: beq, bne, blt, bge, jal, jalr

### 3. 汇编程序结构
```asm
.data
    msg: .asciiz "Hello, World!"  # 初始化的数据

.text
.globl main
main:
    # 程序指令
    ret
```

## 实验步骤

### 1. 编写简单的汇编程序

创建 `add.s` 文件，实现两个数的加法：
```asm
.text
.globl main
main:
    li a0, 5        # 将立即数5加载到a0
    li a1, 3        # 将立即数3加载到a1
    add a2, a0, a1  # a2 = a0 + a1
    ret
```

### 2. 汇编和链接
```bash
riscv64-unknown-elf-as add.s -o add.o
riscv64-unknown-elf-ld add.o -o add
```

### 3. 使用GDB调试
```bash
riscv64-unknown-elf-gdb add
(gdb) break main
(gdb) run
(gdb) stepi
(gdb) info registers
(gdb) quit
```

### 4. 实现循环程序

创建 `loop.s` 文件，实现1到5的累加：
```asm
.text
.globl main
main:
    li a0, 0        # 累加结果，初始化为0
    li a1, 1        # 计数器，初始化为1
    li a2, 5        # 循环终止条件
loop:
    bgt a1, a2, end # 如果a1 > a2，跳转到end
    add a0, a0, a1  # a0 = a0 + a1
    addi a1, a1, 1  # a1 = a1 + 1
    j loop          # 跳转到loop
end:
    ret
```

### 5. 实现条件分支

创建 `branch.s` 文件，实现求最大值：
```asm
.text
.globl main
main:
    li a0, 10       # 第一个数
    li a1, 15       # 第二个数
    bgt a0, a1, a0_bigger
    mv a0, a1       # 如果a1更大，将a1的值赋给a0
a0_bigger:
    ret             # 返回a0中的最大值
```

## 实验报告
1. 解释 `add.s`, `loop.s`, `branch.s` 中的每条指令
2. 记录GDB调试过程中的寄存器状态变化
3. 编写一个汇编程序，实现1到10的阶乘计算
4. 总结RISC-V汇编语言的特点

## 参考资源
- [RISC-V ISA Manual](https://riscv.org/technical/specifications/)
- [RISC-V Assembly Programming](https://github.com/riscv/riscv-asm-manual)
