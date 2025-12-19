# Course 8: C Language and RISC-V Assembly (C语言与RISC-V汇编语言)

## 课程愿景 (Course Vision)
本课程对标 **MIT 6.004**、**UC Berkeley CS61C** 及国内顶尖计算机体系结构课程，旨在培养学生的"系统视角"和"汇编思维"。
我们不仅要掌握C语言的高级编程技巧，更要深入底层，理解C代码如何被编译成RISC-V汇编指令，以及这些指令在硬件上的执行过程。

> **核心哲学**: "If you don't know assembly language, you don't know how computers work. And if you don't know how they work, you can't fix them when they break." —— 汇编语言是连接高级语言与计算机硬件的桥梁。

---

## 课程大纲 (Syllabus)

### Module 1: C语言核心与编译基础 (Weeks 1-2)
**关键词**: *C Syntax, Compilation Process, GCC Toolchain, RISC-V Architecture*
*   **核心内容**:
    *   **C语言基础**: 数据类型、运算符、控制结构、函数、数组、指针
    *   **编译过程**: 预处理、编译、汇编、链接的完整流程
    *   **RISC-V架构概述**: 寄存器结构、指令集分类、内存模型
*   **💡 思考引导**:
    *   为什么C语言被称为"中级语言"？它与低级语言和高级语言的区别是什么？
    *   指针为什么是C语言的核心特性？它如何实现对内存的直接操作？

### Module 2: RISC-V汇编语言基础 (Weeks 3-4)
**关键词**: *RISC-V Instructions, Register Usage, Addressing Modes, Assembly Programming*
*   **核心内容**:
    *   **RISC-V寄存器**: x0-x31通用寄存器的用途和命名规范
    *   **基础指令**: 加载/存储指令、算术/逻辑指令、分支/跳转指令
    *   **汇编程序结构**: 数据段、代码段、符号定义、注释规范
*   **💡 思考引导**:
    *   RISC-V为什么采用加载-存储架构？这种架构有什么优势？
    *   为什么RISC-V使用固定长度的32位指令？

### Module 3: C与汇编的对应关系 (Weeks 5-6)
**关键词**: *Compiler Output, Function Calling Convention, Stack Usage, Variable Allocation*
*   **核心内容**:
    *   **函数调用约定**: 参数传递、返回值处理、栈帧结构
    *   **变量存储**: 全局变量、局部变量、静态变量在内存中的位置
    *   **编译优化**: GCC优化选项对汇编代码的影响
*   **💡 思考引导**:
    *   函数调用时为什么需要建立栈帧？栈帧的结构是怎样的？
    *   编译器如何处理C语言中的局部变量和参数？

### Module 4: 高级汇编编程技术 (Weeks 7-8)
**关键词**: *Floating Point Instructions, Vector Instructions, System Calls, Assembly Optimization*
*   **核心内容**:
    *   **浮点指令集**: F寄存器、浮点运算指令、浮点比较指令
    *   **系统调用**: RISC-V的ECALL指令、常用系统调用号
    *   **汇编优化**: 指令调度、循环展开、寄存器分配技巧
*   **💡 思考引导**:
    *   浮点指令与整数指令有什么区别？它们如何协同工作？
    *   如何通过汇编优化提高程序性能？

### Module 5: C与汇编混合编程 (Weeks 9-10)
**关键词**: *Inline Assembly, External Assembly, Function Interface, Performance Tuning*
*   **核心内容**:
    *   **内联汇编**: 在C代码中嵌入RISC-V汇编
    *   **外部汇编**: C调用汇编函数、汇编调用C函数
    *   **性能调优**: 热点代码的汇编级优化
*   **💡 思考引导**:
    *   什么时候需要使用内联汇编？它的优缺点是什么？
    *   如何在C和汇编之间传递复杂数据结构？

### Module 6: RISC-V高级特性与应用 (Weeks 11-12)
**关键词**: *Privilege Levels, Exception Handling, Interrupts, RV32/RV64 Differences*
*   **核心内容**:
    *   **特权级别**: M-mode、S-mode、U-mode的区别和用途
    *   **异常与中断**: 异常处理流程、中断向量表、中断处理程序
    *   **RV32与RV64**: 32位与64位RISC-V的区别与兼容性
*   **💡 思考引导**:
    *   为什么RISC-V设计了多个特权级别？它们如何保证系统安全？
    *   异常和中断有什么区别？它们的处理流程有何不同？

---

## 推荐实验项目 (Labs)

1.  **Lab 1: C语言基础与编译工具链** - 安装RISC-V GCC工具链，编写简单C程序并分析编译过程
2.  **Lab 2: RISC-V汇编基础** - 编写基本汇编程序，实现算术运算、条件分支和循环
3.  **Lab 3: C与汇编的对应关系** - 编译C程序并反汇编，分析函数调用和变量存储
4.  **Lab 4: 汇编优化实战** - 针对特定算法，编写汇编代码并与C代码比较性能
5.  **Lab 5: C与汇编混合编程** - 使用内联汇编和外部汇编实现高效函数
6.  **Lab 6: 系统调用与异常处理** - 实现系统调用包装函数和简单的异常处理程序
7.  **Lab 7: 综合项目 - 简单计算器** - 使用C和汇编混合编程实现一个命令行计算器

---

## 顶级学习资源 (Top-Tier Resources)

### 1. 经典教材 (Textbooks)
*   **The C Programming Language** (K&R) - Brian W. Kernighan & Dennis M. Ritchie - *C语言的圣经，简洁明了。*
*   **Computer Systems: A Programmer's Perspective** (CS:APP) - Randal E. Bryant & David R. O'Hallaron - *从程序员角度理解计算机系统，包含大量C与汇编的对应关系分析。*
*   **The RISC-V Reader** - David Patterson & Andrew Waterman - *RISC-V架构的权威介绍。*

### 2. 在线课程
*   **MIT 6.004: Computation Structures** - *系统介绍计算机体系结构和汇编语言。*
*   **UC Berkeley CS61C: Great Ideas in Computer Architecture** - *涵盖RISC-V架构和汇编编程。*
*   **RISC-V Assembly Programming** (Udemy) - *实用的RISC-V汇编编程课程。*

### 3. 工具与资源
*   **RISC-V GCC Toolchain** - *官方RISC-V编译工具链。*
*   **QEMU** - *RISC-V模拟器，可以在PC上运行RISC-V程序。*
*   **RISC-V ISA Manual** - *RISC-V指令集架构官方手册。*
*   **Compiler Explorer** - *在线编译器，可以实时查看C代码对应的汇编输出。*