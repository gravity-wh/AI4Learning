# Course 9: Compiler Construction - GCC/RISC-V Toolchain (编译原理 - GCC/RISC-V工具链)

## 课程愿景 (Course Vision)
本课程对标 **Stanford CS143**、**CMU 15-411** 等顶尖计算机编译原理课程，结合实际工程应用，聚焦于 GCC/RISC-V 工具链的后端开发与定制。

> **核心哲学**: "Compilers are the bridge between human-readable code and machine-executable instructions." —— 编译原理不仅是理论学科，更是构建计算机生态系统的关键工程技术。

本课程的独特之处在于：
- **实战导向**: 直接在真实的 GCC 代码库上进行开发
- **硬件协同**: 针对自研 RISC-V 软核定制编译器后端
- **完整流程**: 从源语分析到最终 ELF 文件生成的全链路实践

---

## 课程大纲 (Syllabus)

### Module 1: 编译原理基础与 GCC 架构 (Weeks 1-2)
**关键词**: *Compiler Phases, GCC Architecture, RISC-V ISA*
*   **核心内容**:
    *   **编译流程**: 词法分析、语法分析、语义分析、中间代码生成、优化、目标代码生成
    *   **GCC 整体架构**: 前端、中端、后端的分离与协作
    *   **RISC-V 指令集基础**: 加载/存储架构、寄存器模型、指令格式
*   **💡 思考引导**:
    *   GCC 为什么采用前后端分离的架构？这种设计有什么优势？
    *   RISC-V 指令集的模块化设计如何影响编译器后端开发？

### Module 2: GCC 后端架构与中间表示 (Weeks 3-4)
**关键词**: *GIMPLE, RTL, Target Description, RISC-V Backend*
*   **核心内容**:
    *   **GCC 中间表示**: GIMPLE 和 RTL 的结构与用途
    *   **GCC 后端框架**: 目标描述文件、指令选择、代码生成、寄存器分配
    *   **RISC-V 后端分析**: riscv.md、riscv.c、riscv-protos.h 等关键文件分析
*   **💡 思考引导**:
    *   GIMPLE 和 RTL 有什么区别？它们分别在编译流程的哪个阶段使用？
    *   目标描述文件 (*.md) 在 GCC 后端中扮演什么角色？

### Module 3: GCC 指令选择与目标代码生成 (Weeks 5-6)
**关键词**: *Pattern Matching, Insn Patterns, Code Generation, RISC-V Instructions*
*   **核心内容**:
    *   **指令模式**: RTL 指令模板的定义与匹配
    *   **指令选择算法**: 动态规划、模式匹配
    *   **RISC-V 指令实现**: 如何在 GCC 中添加新指令支持
*   **💡 思考引导**:
    *   GCC 如何将中间代码映射到目标平台的具体指令？
    *   指令选择过程中如何平衡代码质量和编译效率？

### Module 4: 寄存器分配与指令调度 (Weeks 7-8)
**关键词**: *Register Allocation, Graph Coloring, Instruction Scheduling, RISC-V Pipeline*
*   **核心内容**:
    *   **寄存器分配算法**: 图着色算法原理与 GCC 实现
    *   **指令调度**: 基于流水线的指令重排序优化
    *   **RISC-V 寄存器模型**: 调用约定、寄存器分类
*   **💡 思考引导**:
    *   为什么寄存器分配是编译器优化中最关键的环节之一？
    *   如何针对 RISC-V 的流水线特性进行指令调度优化？

### Module 5: 自定义指令集扩展与后端修改 (Weeks 9-10)
**关键词**: *Custom Instructions, ISA Extension, GCC Backend Modification, RISC-V Custom Extensions*
*   **核心内容**:
    *   **RISC-V 自定义扩展**: X 扩展规范与实现方法
    *   **GCC 后端修改**: 添加新指令、修改指令选择、更新目标描述
    *   **指令编码与解码**: 自定义指令的二进制格式设计
*   **💡 思考引导**:
    *   如何设计高效的自定义指令以加速特定算法？
    *   在 GCC 中添加新指令需要修改哪些关键文件？

### Module 6: 链接器与 ELF 文件格式 (Weeks 11-12)
**关键词**: *Linker, ELF Format, Symbol Resolution, Relocation, RISC-V ELF*
*   **核心内容**:
    *   **ELF 文件格式**: 头部、节表、符号表、重定位表
    *   **链接过程**: 符号解析、重定位、地址分配
    *   **RISC-V ELF 规范**: 特殊节、重定位类型、目标属性
*   **💡 思考引导**:
    *   链接器与编译器的区别和联系是什么？
    *   为什么需要重定位？RISC-V 中有哪些常见的重定位类型？

### Module 7: 编译器测试与验证 (Weeks 13-14)
**关键词**: *Compiler Testing, Regression Testing, ISA Simulator, RISC-V Emulator*
*   **核心内容**:
    *   **编译器测试方法**: 单元测试、集成测试、回归测试
    *   **测试套件**: GCC testsuite、RISC-V testsuite
    *   **模拟验证**: 使用 QEMU、Spike 模拟器测试生成的代码
*   **💡 思考引导**:
    *   如何确保编译器修改不会引入回归 bug？
    *   如何验证自定义指令在真实硬件或模拟器上的正确性？

---

## 实验项目 (Labs)

### Lab 1: GCC/RISC-V 工具链搭建与编译流程
**目标**: 掌握 GCC/RISC-V 工具链的安装与使用，理解完整编译流程
**内容**:
*   安装 GCC/RISC-V 交叉编译工具链
*   编译简单 C 程序并生成 RISC-V 汇编代码
*   使用 objdump、readelf 等工具分析编译产物
*   理解预处理、编译、汇编、链接的完整流程

### Lab 2: GCC 后端架构与中间表示分析
**目标**: 深入理解 GCC 后端架构和中间表示
**内容**:
*   分析 GCC 源码目录结构，定位 RISC-V 后端文件
*   使用 `-fdump-tree-*` 和 `-fdump-rtl-*` 选项生成中间表示
*   分析 GIMPLE 和 RTL 的结构与转换关系
*   理解 RISC-V 后端的关键文件 (riscv.md, riscv.c)

### Lab 3: 自定义指令集扩展与 GCC 后端修改
**目标**: 在 GCC 中添加自定义指令支持
**内容**:
*   设计简单的 RISC-V 自定义指令 (如自定义加法、位操作)
*   修改 GCC 后端文件添加新指令支持:
    *   更新 riscv.md 添加指令模式
    *   修改 riscv.c 添加指令处理函数
    *   更新头文件和配置
*   编译测试程序验证新指令的生成

### Lab 4: 指令选择与代码生成优化
**目标**: 优化指令选择和代码生成过程
**内容**:
*   分析现有指令选择模式的效率
*   添加新的指令组合模式以提高代码质量
*   实现简单的窥孔优化
*   对比优化前后的汇编代码质量和性能

### Lab 5: 链接器与 ELF 文件生成
**目标**: 理解链接过程和 ELF 文件格式
**内容**:
*   使用 ld 链接器手动链接目标文件
*   分析 ELF 文件的结构和内容
*   理解符号解析和重定位过程
*   编写简单的链接脚本控制内存布局

### Lab 6: 综合项目 - 完整自定义 ISA 支持
**目标**: 为自研 RISC-V 软核构建完整的编译器后端支持
**内容**:
*   定义自定义 RISC-V 软核的完整指令集
*   在 GCC 中实现完整的指令集支持
*   实现自定义的函数调用约定
*   生成能在自研软核上运行的 ELF 文件
*   使用模拟器或 FPGA 验证生成代码的正确性

---

## 推荐学习资源 (Top-Tier Resources)

### 1. 经典教材 (Textbooks)
*   **Compilers: Principles, Techniques, and Tools** (Dragon Book) - Alfred V. Aho, Monica S. Lam, Ravi Sethi, Jeffrey D. Ullman - *编译原理的圣经*
*   **Advanced Compiler Design and Implementation** (Whale Book) - Steven S. Muchnick - *高级编译优化技术*
*   **GCC Internals** - Richard M. Stallman, et al. - *GCC 内部结构权威参考*
*   **The RISC-V Reader** - David Patterson, Andrew Waterman - *RISC-V 架构权威介绍*

### 2. 在线课程
*   **Stanford CS143: Compilers** - *经典编译原理课程*
*   **CMU 15-411: Compiler Design** - *侧重于编译器工程实践*
*   **RISC-V Assembly Programming** (Udemy) - *实用的 RISC-V 汇编编程课程*

### 3. 工具与资源
*   **GCC 源码仓库** - [https://gcc.gnu.org/git.html](https://gcc.gnu.org/git.html) - *GCC 官方源码*
*   **RISC-V ISA 手册** - [https://riscv.org/technical/specifications/](https://riscv.org/technical/specifications/) - *RISC-V 指令集规范*
*   **QEMU** - [https://www.qemu.org/](https://www.qemu.org/) - *RISC-V 模拟器*
*   **Spike** - [https://github.com/riscv-software-src/riscv-isa-sim](https://github.com/riscv-software-src/riscv-isa-sim) - *RISC-V ISA 模拟器*
*   **Binutils** - [https://www.gnu.org/software/binutils/](https://www.gnu.org/software/binutils/) - *二进制工具集 (objdump, readelf 等)*

### 4. 实践资源
*   **GCC Wiki** - [https://gcc.gnu.org/wiki/](https://gcc.gnu.org/wiki/) - *GCC 开发指南*
*   **RISC-V GCC Port** - [https://github.com/riscv-collab/riscv-gcc](https://github.com/riscv-collab/riscv-gcc) - *RISC-V GCC 移植代码*
*   **RISC-V Toolchain Conventions** - [https://github.com/riscv/riscv-toolchain-conventions](https://github.com/riscv/riscv-toolchain-conventions) - *RISC-V 工具链约定*
