# Course 6: C & Rust Embedded Programming: RISC-V & STM32 Bare-Metal Development

## 课程愿景 (Course Vision)
本课程旨在为嵌入式开发人员提供**双语言** (C + Rust) 嵌入式编程的核心技能，聚焦于 RISC-V 和 STM32 平台的裸机开发。
我们将从底层硬件抽象层 (HAL) 开始，逐步构建完整的嵌入式应用，同时对比 C 和 Rust 两种语言在安全性、性能和开发效率上的优劣。

> **核心哲学**: "嵌入式开发的本质是与硬件的直接对话，而语言则是我们的翻译器。" —— 掌握多种语言，才能在不同场景下选择最合适的工具。

---

## 课程大纲 (Syllabus)

### Module 1: 嵌入式开发基础与工具链 (Weeks 1-2)
**关键词**: *Toolchain, Linker Script, Startup Code, Debugging*
*   **核心内容**:
    *   **嵌入式开发概述**: 裸机 (Bare-Metal) vs RTOS vs Linux
    *   **工具链搭建**: GCC/Cross GCC, Rustup, Cargo, OpenOCD
    *   **链接脚本 (Linker Script)**: 如何告诉编译器将代码放在 ROM，变量放在 RAM？
    *   **启动代码 (Startup Code)**: Reset Handler, Stack Initialization, Vector Table
    *   **调试技术**: GDB, Semihosting, SWD/JTAG
*   **💡 思考引导**:
    *   为什么嵌入式程序不需要操作系统也能运行？
    *   链接脚本中的 `MEMORY` 和 `SECTIONS` 段有什么作用？

### Module 2: C语言嵌入式编程核心 (Weeks 3-4)
**关键词**: *HAL, Registers, Interrupts, GPIO*
*   **核心内容**:
    *   **寄存器编程**: 如何通过指针直接操作硬件寄存器？
    *   **硬件抽象层 (HAL)**: 从寄存器到 API 的封装艺术
    *   **中断处理**: NVIC, Interrupt Service Routines (ISRs)
    *   **GPIO 编程**: 点亮 LED, 按键输入
    *   **定时器 (Timer)**: 延时、PWM 输出
*   **💡 思考引导**:
    *   为什么 C 语言在嵌入式领域占据统治地位？它的优势和劣势是什么？
    *   中断嵌套和中断优先级如何影响程序执行？

### Module 3: Rust嵌入式编程入门 (Weeks 5-7)
**关键词**: *Ownership, Borrow Checker, Embedded HAL, PAC*
*   **核心内容**:
    *   **Rust 基础回顾**: Ownership, Borrowing, Lifetimes
    *   **嵌入式 Rust 生态**: embedded-hal, cortex-m-rt, PAC (Peripheral Access Crate)
    *   ** unsafe Rust**: 为什么在嵌入式开发中无法避免 unsafe？
    *   **Rust 寄存器编程**: svd2rust 和 PAC 的使用
    *   **Rust 中断处理**: #[interrupt], Mutex
*   **💡 思考引导**:
    *   Rust 的内存安全特性在嵌入式开发中有什么实际价值？
    *   为什么嵌入式 Rust 需要使用 `static mut` 和 `Mutex` 来处理共享资源？

### Module 4: RISC-V 裸机开发实战 (Weeks 8-9)
**关键词**: *RISC-V ISA, RV32I, UART, SPI*
*   **核心内容**:
    *   **RISC-V 架构简介**: 指令集、寄存器、特权级别
    *   **RISC-V 开发板**: QEMU 模拟 vs 真实硬件 (如 FE310)
    *   **UART 通信**: 实现串口收发
    *   **SPI/I2C 协议**: 与外设通信
    *   **C 与 Rust 对比实现**: 在 RISC-V 上实现相同功能
*   **💡 思考引导**:
    *   RISC-V 与 ARM 架构相比有什么优势？
    *   为什么 RISC-V 被认为是嵌入式领域的未来？

### Module 5: STM32 高级应用开发 (Weeks 10-11)
**关键词**: *STM32CubeMX, ADC, DMA, RTOS Integration*
*   **核心内容**:
    *   **STM32 系列概述**: Cortex-M0/M3/M4/M7 差异
    *   **STM32CubeMX**: 快速配置时钟和外设
    *   **ADC 与 DMA**: 高速数据采集
    *   **实时时钟 (RTC)**: 低功耗应用
    *   **RTOS 基础**: FreeRTOS 任务与调度
*   **💡 思考引导**:
    *   什么时候需要使用 RTOS？裸机编程和 RTOS 编程的主要区别是什么？
    *   DMA 如何提高系统性能？

### Module 6: C 与 Rust 混合编程 (Week 12)
**关键词**: *FFI, Linking, Performance Comparison*
*   **核心内容**:
    *   **Foreign Function Interface (FFI)**: Rust 调用 C，C 调用 Rust
    *   **混合编译**: 将 C 和 Rust 代码链接到同一个可执行文件
    *   **性能对比**: 相同功能在 C 和 Rust 中的执行效率
    *   **项目架构**: 如何决定哪些模块用 C，哪些用 Rust？
*   **💡 思考引导**:
    *   在现有 C 项目中引入 Rust 有什么挑战和收益？
    *   如何平衡 Rust 的安全性和 C 的兼容性？

---

## 推荐实验项目 (Labs)

1.  **Lab 1: 开发环境搭建** - 安装并配置 C 和 Rust 工具链，点亮第一个 LED。
2.  **Lab 2: 串口通信** - 在 RISC-V/STM32 上实现 UART 收发功能，C 和 Rust 版本对比。
3.  **Lab 3: 传感器读取** - 使用 I2C/SPI 接口读取温度传感器数据。
4.  **Lab 4: 定时器与 PWM** - 实现呼吸灯效果，对比 C 和 Rust 的中断处理。
5.  **Lab 5: ADC 数据采集** - 使用 DMA 实现高速 ADC 采样并通过串口发送。
6.  **Lab 6: 混合编程项目** - 用 C 实现性能敏感部分，Rust 实现安全关键部分，构建完整应用。

---

## 顶级学习资源 (Top-Tier Resources)

### 1. 经典教材 (Textbooks)
*   **Mastering STM32** ( Carmine Noviello) - *STM32 开发的权威指南。*
*   **The Rust Programming Language** (Steve Klabnik & Carol Nichols) - *Rust 官方教程。*
*   **Embedded Rust Book** (The Embedded WG) - *嵌入式 Rust 开发的必读书籍。*
*   **Programming Embedded Systems** (Michael Barr) - *嵌入式系统编程的经典之作。*

### 2. 开发板与硬件
*   **RISC-V**: HiFive1 Rev B (FE310), Longan Nano (GD32VF103)
*   **STM32**: STM32F103C8T6 (Blue Pill), STM32F4 Discovery

### 3. 工具与框架
*   **C 工具链**: ARM GNU Toolchain, RISC-V GNU Toolchain
*   **Rust 工具链**: rustup, cargo-generate, probe-rs
*   **调试工具**: OpenOCD, GDB, SEGGER J-Link
*   **IDE**: VS Code + Cortex-Debug, STM32CubeIDE

### 4. 在线资源
*   **Rust Embedded WG**: https://github.com/rust-embedded/wg
*   **STM32 官方文档**: https://www.st.com/en/microcontrollers-microprocessors/stm32-32-bit-arm-cortex-mcus.html
*   **RISC-V 官方网站**: https://riscv.org/
*   **Embedded Artistry**: https://embeddedartistry.com/
