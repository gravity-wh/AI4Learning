# Bootloader 开发（系统引导）课程大纲

## 课程愿景
本课程旨在教授 Bootloader 开发的核心原理与实践技能，重点关注 RISC-V 架构下的系统引导流程。学员将学习 Bootloader 的工作机制、RISC-V 特权级切换、设备树基础，并最终为自研 RISC 软核实现一个简化版 Bootloader，掌握从硬件初始化到内核启动的完整流程。

## 模块划分及关键主题/思考指南

### 模块 1：Bootloader 基础与 RISC-V 架构
**关键主题：**
- Bootloader 的定义与作用
- RISC-V 架构概述
- RISC-V 特权级模式（M/S/U 模式）
- RISC-V 寄存器模型与内存管理
- 《RISC-V Boot Flow Specification》解读

**思考指南：**
- Bootloader 与固件、操作系统的区别是什么？
- 为什么需要多级引导加载器？
- RISC-V 特权级设计的优势有哪些？

### 模块 2：Bootloader 工作流程
**关键主题：**
- 系统上电启动流程
- 硬件初始化（时钟、UART、GPIO）
- 内存初始化（DDR、SDRAM）
- 内核镜像加载机制
- 跳转到内核执行的技术细节

**思考指南：**
- 硬件初始化的顺序为什么很重要？
- 如何处理不同硬件平台的兼容性？
- 内核镜像的格式有哪些要求？

### 模块 3：RISC-V 特权级切换
**关键主题：**
- M 模式到 S 模式的切换流程
- RISC-V 控制状态寄存器（CSR）操作
- OpenSBI 的工作原理与使用
- 异常处理与中断向量表

**思考指南：**
- 特权级切换时需要保存哪些上下文？
- OpenSBI 在 Bootloader 中的角色是什么？
- 如何实现安全的特权级跳转？

### 模块 4：设备树（Device Tree）基础
**关键主题：**
- 设备树的起源与作用
- DTS/DTB 文件格式
- 硬件资源描述方法
- 设备树解析工具链
- Bootloader 与内核的设备树传递

**思考指南：**
- 设备树解决了什么问题？
- 如何为自定义硬件编写设备树？
- Bootloader 需要修改设备树吗？

### 模块 5：Bootloader 高级特性
**关键主题：**
- U-Boot 核心逻辑分析
- 镜像加载方式（SD 卡、网络、串口）
- 启动参数传递
- 安全启动机制
- Bootloader 调试技术

**思考指南：**
- U-Boot 的模块化设计有哪些优点？
- 如何实现可靠的镜像验证？
- 如何调试早期 Bootloader 代码？

### 模块 6：Bootloader 项目实践
**关键主题：**
- 自研 RISC 软核 Bootloader 设计
- UART/DDR/GPIO 初始化实现
- 内核镜像接收与加载
- 特权级切换与内核启动
- 系统测试与验证

**思考指南：**
- 如何设计可扩展的 Bootloader 架构？
- 如何优化 Bootloader 的启动速度？
- 如何确保 Bootloader 的稳定性？

## 推荐实验

### 实验 1：RISC-V Bootloader 基础与开发环境搭建
- 目标：搭建 RISC-V 交叉编译环境
- 内容：安装 GCC/RISC-V 工具链、QEMU 模拟器、U-Boot 源码分析
- 思考：不同 RISC-V 工具链的差异是什么？

### 实验 2：硬件初始化与特权级切换
- 目标：实现基本硬件初始化与特权级切换
- 内容：UART 初始化、M 模式到 S 模式切换、OpenSBI 集成
- 思考：如何验证特权级切换的正确性？

### 实验 3：内核加载与设备树处理
- 目标：实现内核镜像加载与设备树传递
- 内容：从串口接收内核镜像、设备树解析、内存管理
- 思考：如何处理大尺寸内核镜像的加载？

### 实验 4：完整 Bootloader 实现与测试
- 目标：实现完整的 Bootloader 并验证系统启动
- 内容：整合所有模块、系统测试、性能优化
- 思考：如何设计自动化测试框架验证 Bootloader？

## 学习资源

### 核心文档
- 《RISC-V Boot Flow Specification》
- 《RISC-V 架构手册》
- 《U-Boot 开发者手册》

### 开源项目
- U-Boot（RISC-V 分支）
- OpenSBI
- QEMU（RISC-V 支持）

### 在线课程与教程
- RISC-V International 官方教程
- CS140e: Operating Systems from the Ground Up (Stanford)
- Linux Booting Process 系列教程

### 工具链
- GCC/RISC-V 交叉编译工具链
- QEMU RISC-V 模拟器
- Device Tree Compiler (DTC)
- GDB 调试工具

## 课程要求
- 具备 C 语言编程基础
- 了解计算机体系结构基本概念
- 熟悉 RISC-V 汇编语言优先
- 具备嵌入式系统开发经验优先

## 学习成果
完成本课程后，学员将能够：
- 理解 Bootloader 的完整工作流程
- 掌握 RISC-V 特权级切换技术
- 能够为 RISC-V 平台编写基本的 Bootloader
- 理解设备树的原理与应用
- 具备分析和调试 Bootloader 的能力