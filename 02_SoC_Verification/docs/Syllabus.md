# Course 2: System-on-Chip Verification (SoC 验证方法学)

## 课程愿景 (Course Vision)
本课程旨在弥合学术界数字逻辑设计与工业界大规模 SoC 验证之间的巨大鸿沟。参考 UT Austin (EE 382V), Stanford (EE 272C) 及业界标准培训体系，本课程将引导学生从传统的定向测试 (Directed Testing) 思维转变为现代的覆盖率驱动验证 (Coverage-Driven Verification, CDV) 思维。

通过本课程，学生将掌握 SystemVerilog (SV) 语言的高级特性，精通 UVM (Universal Verification Methodology) 架构，并具备搭建工业级验证环境的能力。

---

## 教学大纲 (Syllabus)

### Phase 1: SystemVerilog 语言进阶 (Weeks 1-4)
> **目标**: 掌握 SV 作为验证语言 (HVL) 的核心特性，建立面向对象编程 (OOP) 思维。

#### Week 1: 数据类型与过程块 (Data Types & Procedural Blocks)
*   **Lecture**:
    *   Logic vs Wire: 4态逻辑与双向驱动。
    *   复杂数据类型: Dynamic Arrays, Queues, Associative Arrays (哈希表)。
    *   Struct vs Union (Packed/Unpacked)。
    *   过程块: `initial`, `always_comb/ff/latch`, `final`。
*   **Lab 1**: 实现一个 FIFO 的记分板 (Scoreboard) 数据结构，练习队列操作 (push/pop)。

#### Week 2: 面向对象编程基础 (OOP Fundamentals)
*   **Lecture**:
    *   Class vs Module: 静态与动态生命周期。
    *   Handle, Object, `new()` 构造函数。
    *   `this` 指针, `static` 成员。
    *   深拷贝 (Deep Copy) vs 浅拷贝 (Shallow Copy)。
*   **Lab 2**: 定义一个 `Packet` 类，实现其拷贝和打印函数。

#### Week 3: 随机化与约束 (Randomization & Constraints)
*   **Lecture**:
    *   `rand` vs `randc`。
    *   约束块: `constraint`, `inside`, `dist` (权重分布)。
    *   约束求解器原理: Hard vs Soft constraints。
    *   `pre_randomize()` 与 `post_randomize()` 回调。
*   **Lab 3**: 为 ALU 设计一个随机激励生成器，约束操作码分布和操作数范围。

#### Week 4: 线程与通信 (Threads & IPC)
*   **Lecture**:
    *   `fork...join`, `fork...join_any`, `fork...join_none`。
    *   线程控制: `wait fork`, `disable fork`。
    *   通信机制: Semaphores (信号量), Mailboxes (信箱), Events。
*   **Lab 4**: 使用 Mailbox 实现 Generator 到 Driver 的数据传递。

---

### Phase 2: 验证方法学核心 (Weeks 5-8)
> **目标**: 理解分层验证平台架构，掌握功能覆盖率与断言。

#### Week 5: 分层验证平台架构 (Layered Testbench Architecture)
*   **Lecture**:
    *   验证组件划分: Generator, Driver, Monitor, Agent, Scoreboard, Environment。
    *   Transaction Level Modeling (TLM) 概念。
    *   Interface 与 Virtual Interface (连接静态 RTL 与动态 Class 的桥梁)。
*   **Lab 5**: 搭建一个非 UVM 的纯 SV 分层验证平台。

#### Week 6: 功能覆盖率 (Functional Coverage)
*   **Lecture**:
    *   Code Coverage (Line, Toggle, FSM) 的局限性。
    *   Covergroup, Coverpoint, Bins (自动/手动分仓)。
    *   Cross Coverage (交叉覆盖率)。
    *   覆盖率采样时机。
*   **Lab 6**: 为总线协议定义覆盖率模型，确保覆盖所有读写组合及边界地址。

#### Week 7: SystemVerilog 断言 (SVA)
*   **Lecture**:
    *   Immediate Assertions vs Concurrent Assertions。
    *   Sequence, Property, Assert 指令。
    *   常用操作符: `|->` (蕴含), `##n` (延时), `[*n]` (重复)。
    *   Binding SVA to RTL。
*   **Lab 7**: 编写 SVA 检查 FIFO 的满/空标志位逻辑是否正确。

#### Week 8: 接口与总线协议 (Interfaces & Bus Protocols)
*   **Lecture**:
    *   标准总线协议概览: APB, AHB, AXI (简要)。
    *   Clocking Block: 解决竞争冒险 (Race Conditions)，实现同步驱动/采样。
    *   Modport 的使用。
*   **Lab 8**: 实现一个符合 APB 时序的 Driver 和 Monitor。

---

### Phase 3: UVM 实战 (Weeks 9-12)
> **目标**: 掌握工业界标准 UVM 框架，能够开发可重用的验证 IP (VIP)。

#### Week 9: UVM 基础机制 (UVM Basics)
*   **Lecture**:
    *   UVM 类树: `uvm_object` vs `uvm_component`。
    *   UVM Phase 机制: Build, Connect, Run (Time consuming), Report。
    *   UVM Factory: `type_id::create()` 与多态覆盖 (Override)。
    *   UVM Reporting: `uvm_info`, `uvm_error`, `uvm_fatal`。
*   **Lab 9**: 将 Lab 5 的 SV 平台迁移到 UVM 架构，实现 Hello World。

#### Week 10: UVM 通信与配置 (TLM & Config DB)
*   **Lecture**:
    *   TLM 1.0: Port, Export, Imp, FIFO。
    *   Analysis Port: 一对多广播 (Monitor -> Scoreboard/Coverage)。
    *   `uvm_config_db`: 跨层次参数配置与 Virtual Interface 传递。
*   **Lab 10**: 连接 Driver, Sequencer 和 Monitor，实现完整的 UVM Agent。

#### Week 11: UVM 序列机制 (Sequences)
*   **Lecture**:
    *   `uvm_sequence`, `uvm_sequencer`, `uvm_driver` 的握手 (start_item, finish_item)。
    *   Sequence 的层次化与嵌套。
    *   Virtual Sequence & Virtual Sequencer: 协调多 Agent 的激励。
*   **Lab 11**: 编写一系列测试序列 (Sanity, Random, Error Injection) 并通过 Test 启动。

#### Week 12: 寄存器模型 (UVM RAL)
*   **Lecture**:
    *   Register Abstraction Layer (RAL) 概念。
    *   RAL Model 的生成 (通常由脚本从 Excel/IP-XACT 生成)。
    *   Frontdoor vs Backdoor Access。
    *   内置寄存器测试序列 (hw_reset, bit_bash)。
*   **Lab 12**: 集成 RAL 到验证环境，通过寄存器名读写 DUT 配置。

---

## 课程项目 (Course Project)

**项目名称**: **多通道 DMA 控制器验证 (Multi-Channel DMA Controller Verification)**

**DUT 描述**:
*   支持 4 个独立的 DMA 通道。
*   配置接口: APB Slave (用于配置源/目的地址、传输长度、控制寄存器)。
*   数据接口: AXI4-Lite Master (用于搬运数据)。
*   支持中断生成。

**项目要求**:
1.  **验证计划 (Verification Plan)**: 列出测试点 (Testpoints) 和覆盖率目标。
2.  **UVM 环境搭建**:
    *   开发 APB UVM Agent (Master)。
    *   开发 AXI4-Lite UVM Agent (Slave/Memory Model)。
    *   集成 RAL 模型。
3.  **测试用例 (Testcases)**:
    *   `test_sanity`: 单通道基本搬运。
    *   `test_multi_channel`: 4通道轮询/优先级仲裁测试。
    *   `test_reg_access`: 寄存器读写测试。
4.  **覆盖率闭环**: 确保代码覆盖率 > 95%，功能覆盖率 100%。

---

## 推荐教材与资源 (Resources)

1.  **Core Textbook**: *SystemVerilog for Verification: A Guide to Learning the Testbench Language Features*, Chris Spear. (SV 圣经)
2.  **UVM Reference**: *Universal Verification Methodology (UVM) 1.2 Class Reference*.
3.  **Online**:
    *   ChipVerify.com (SystemVerilog & UVM Tutorials).
    *   Verification Academy (Siemens/Mentor Graphics).
4.  **Tools**:
    *   Simulator: Vivado Simulator (Xsim), Questasim, or VCS.
    *   Waveform: Verdi or GTKWave.
