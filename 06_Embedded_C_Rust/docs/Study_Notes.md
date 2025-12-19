# 学习笔记：C & Rust Embedded Programming (C与Rust嵌入式编程)

这份文档用于记录《C & Rust Embedded Programming》课程的学习心得、核心概念整理、实验记录以及待解决的问题。

---

## Module 1: 嵌入式开发基础与工具链

### 1.1 核心概念速查
*   **嵌入式开发模式**:
    *   **裸机开发 (Bare-Metal)**: 直接操作硬件，无操作系统
    *   **RTOS**: 实时操作系统，如 FreeRTOS、RT-Thread
    *   **Linux**: 适用于资源丰富的嵌入式系统
*   **工具链组件**:
    *   **编译器**: GCC (C/C++), rustc (Rust)
    *   **汇编器**: as, gas
    *   **链接器**: ld, rust-lld
    *   **烧录工具**: OpenOCD, ST-Link Utility
    *   **调试器**: GDB
*   **链接脚本 (Linker Script)**:
    *   **MEMORY 段**: 定义 ROM、RAM 等内存区域的起始地址和大小
    *   **SECTIONS 段**: 定义代码段 (.text)、数据段 (.data)、BSS段 (.bss) 的放置位置
    *   **堆与栈**: 指定堆和栈的大小及位置
*   **启动代码 (Startup Code)**:
    *   **Reset Handler**: 程序入口点，初始化堆栈、复制数据段、清零 BSS 段
    *   **Vector Table**: 中断向量表，包含中断服务程序的地址

### 1.2 重点难点记录
- [ ] 如何编写一个最小的嵌入式程序？它需要哪些必要组件？
- [ ] 链接脚本中的 `PROVIDE` 关键字有什么作用？
- [ ] 为什么嵌入式程序通常不需要动态内存分配？

### 1.3 实验记录
*   **工具链搭建**:
    *   成功安装 GCC for ARM/RISC-V
    *   配置 Rust 嵌入式工具链: `rustup target add thumbv7m-none-eabi riscv32imac-unknown-none-elf`
    *   安装 OpenOCD 和 GDB

---

## Module 2: C语言嵌入式编程核心

### 2.1 核心概念速查
*   **寄存器编程**:
    *   **地址映射**: 硬件寄存器被映射到内存地址空间
    *   **指针操作**: 使用 volatile 指针直接访问寄存器
    *   **位操作**: 设置 (|=)、清除 (&=~)、切换 (^=) 特定位
*   **中断处理**:
    *   **NVIC (Nested Vectored Interrupt Controller)**: 管理中断优先级和使能
    *   **ISR (Interrupt Service Routines)**: 中断服务程序，必须快速执行
    *   **中断标志**: 清除中断标志以避免重复触发
*   **GPIO 编程**:
    *   **模式配置**: 输入、输出、复用功能、模拟
    *   **速度配置**: 低、中、高速，影响功耗和EMI
    *   **上下拉配置**: 输入模式下的内部电阻
*   **定时器**:
    *   **基本定时器**: 用于延时和触发
    *   **通用定时器**: 支持 PWM、输入捕获、输出比较
    *   **高级定时器**: 支持更多高级功能

### 2.2 重点难点记录
- [ ] 为什么在访问寄存器时需要使用 volatile 关键字？
- [ ] 如何避免中断服务程序中的竞态条件？
- [ ] 为什么定时器的时钟源通常需要预分频？

### 2.3 实验记录
*   **LED 点亮**:
    *   配置 GPIO 为推挽输出模式
    *   使用位操作控制 LED 亮灭
*   **按键输入**:
    *   配置 GPIO 为输入模式，启用上拉电阻
    *   实现按键去抖算法

---

## Module 3: Rust嵌入式编程入门

### 3.1 核心概念速查
*   **嵌入式 Rust 生态**:
    *   **PAC (Peripheral Access Crate)**: 由 SVD 文件生成的寄存器访问 API
    *   **embedded-hal**: 跨平台硬件抽象层
    *   **cortex-m-rt**: Cortex-M 处理器的运行时库
    *   **rtfm**: Real-Time For the Masses，一种基于 Rust 的任务调度器
*   **Rust 内存安全**:
    *   **Ownership**: 每个值有且仅有一个所有者
    *   **Borrowing**: 允许临时访问值，分为可变和不可变借用
    *   **Lifetimes**: 确保引用的有效性
*   **unsafe Rust 在嵌入式中的应用**:
    *   直接访问硬件寄存器
    *   实现中断服务程序
    *   处理共享资源
*   **中断处理**:
    *   使用 `#[interrupt]` 属性定义 ISR
    *   使用 `Mutex` 保护共享资源
    *   使用 `critical_section` 进入临界区

### 3.2 重点难点记录
- [ ] 如何在 Rust 中处理裸指针？
- [ ] 为什么嵌入式 Rust 中广泛使用 `static mut`？
- [ ] `embedded-hal` trait 如何实现跨平台兼容性？

### 3.3 实验记录
*   **Rust LED 点亮**:
    *   使用 PAC 访问寄存器
    *   使用 embedded-hal 实现跨平台 GPIO 控制
*   **Rust 中断处理**:
    *   实现按键中断
    *   使用 Mutex 保护共享变量

---

## Module 4: RISC-V 裸机开发实战

### 4.1 核心概念速查
*   **RISC-V 架构**:
    *   **指令集**: RV32I (基础整数指令集)、M (乘法)、A (原子操作)、C (压缩指令)
    *   **寄存器**: 32个通用寄存器 (x0-x31)，x0 恒为 0
    *   **特权级别**: U (用户)、S ( supervisor)、M (机器)，嵌入式通常使用 M 模式
*   **RISC-V 开发**:
    *   **QEMU 模拟**: 使用 `qemu-system-riscv32` 模拟 RISC-V 处理器
    *   **真实硬件**: HiFive1 Rev B、Longan Nano 等开发板
    *   **UART 通信**: 通过串口与主机通信
    *   **SPI/I2C**: 与外设通信的串行协议

### 4.2 重点难点记录
- [ ] RISC-V 与 ARM 架构的主要区别是什么？
- [ ] 如何在 RISC-V 中配置中断？
- [ ] RISC-V 的异常处理机制与 ARM 有什么不同？

### 4.3 实验记录
*   **RISC-V UART 通信**:
    *   在 QEMU 上实现 UART 收发
    *   在真实硬件上验证 UART 功能
*   **SPI 接口**:
    *   配置 SPI 控制器
    *   与 SPI 设备通信

---

## Module 5: STM32 高级应用开发

### 5.1 核心概念速查
*   **STM32 系列**:
    *   **Cortex-M0/M0+**: 低成本、低功耗
    *   **Cortex-M3**: 主流性能
    *   **Cortex-M4/M7**: 高性能，支持 DSP 和 FPU
*   **STM32CubeMX**:
    *   图形化配置工具，生成初始化代码
    *   支持时钟树配置、外设配置、中断配置
*   **ADC 与 DMA**:
    *   **ADC**: 模数转换器，支持多通道、扫描模式
    *   **DMA**: 直接内存访问，无需 CPU 干预即可传输数据
*   **RTOS 基础**:
    *   **任务**: 独立的执行线程
    *   **调度器**: 决定哪个任务获得 CPU 时间
    *   **同步机制**: 信号量、互斥体、事件标志组

### 5.2 重点难点记录
- [ ] STM32 的时钟树结构是怎样的？如何优化时钟配置？
- [ ] DMA 传输完成后如何通知 CPU？
- [ ] 如何在 RTOS 中设计高效的任务？

### 5.3 实验记录
*   **STM32CubeMX 使用**:
    *   生成 GPIO、UART、定时器初始化代码
    *   配置 ADC 和 DMA
*   **FreeRTOS 实验**:
    *   创建多个任务
    *   使用信号量实现任务同步

---

## Module 6: C 与 Rust 混合编程

### 6.1 核心概念速查
*   **FFI (Foreign Function Interface)**:
    *   **Rust 调用 C**: 使用 `extern "C"` 声明 C 函数
    *   **C 调用 Rust**: 使用 `#[no_mangle] extern "C"` 定义可被 C 调用的 Rust 函数
*   **数据类型转换**:
    *   基本类型的对应关系
    *   字符串转换: C字符串与 Rust 字符串
    *   结构体转换: 确保内存布局一致
*   **混合编译**:
    *   使用 Cargo 构建 Rust 库
    *   使用 GCC 编译 C 代码
    *   使用链接器将两者链接在一起

### 6.2 重点难点记录
- [ ] 如何处理 C 和 Rust 之间的内存管理差异？
- [ ] 如何在 Rust 中安全地操作 C 指针？
- [ ] 混合编程时如何处理错误？

### 6.3 实验记录
*   **Rust 调用 C 函数**:
    *   成功在 Rust 中调用 C 编写的 GPIO 控制函数
*   **C 调用 Rust 函数**:
    *   在 C 程序中调用 Rust 实现的安全检查函数
*   **性能对比**:
    *   测量相同功能在 C 和 Rust 中的执行时间和代码大小
