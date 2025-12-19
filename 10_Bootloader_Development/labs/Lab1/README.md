# Lab1: RISC-V Bootloader 基础与开发环境搭建

## 实验目标
1. 了解 Bootloader 的基本概念和作用
2. 掌握 RISC-V 架构的核心特性
3. 搭建 RISC-V 交叉编译环境
4. 安装并使用 QEMU RISC-V 模拟器
5. 分析 U-Boot 源码结构

## 实验内容
1. 学习 Bootloader 与 RISC-V 架构基础理论
2. 安装 GCC/RISC-V 交叉编译工具链
3. 安装 QEMU 模拟器和其他开发工具
4. 下载并分析 U-Boot 源码
5. 编译 U-Boot 并在 QEMU 中运行

## 实验步骤

### 步骤 1：学习 Bootloader 与 RISC-V 架构基础
1. 阅读课程大纲中的模块 1 内容
2. 理解 Bootloader 的定义、作用和分类
3. 掌握 RISC-V 特权级模式和寄存器模型
4. 了解《RISC-V Boot Flow Specification》的基本内容

### 步骤 2：安装 GCC/RISC-V 交叉编译工具链

#### 在 Linux 系统上安装
```bash
# 使用包管理器安装
sudo apt-get update
sudo apt-get install gcc-riscv64-linux-gnu

# 验证安装
riscv64-linux-gnu-gcc --version
```

#### 在 Windows 系统上安装
1. 下载 RISC-V 工具链：https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases
2. 解压到指定目录
3. 将工具链的 bin 目录添加到系统环境变量 PATH
4. 在命令提示符中验证：
   ```cmd
   riscv-none-elf-gcc --version
   ```

#### 在 macOS 系统上安装
```bash
# 使用 Homebrew 安装
brew tap riscv-software-src/riscv
brew install riscv-tools

# 验证安装
riscv64-unknown-elf-gcc --version
```

### 步骤 3：安装 QEMU 模拟器

#### 在 Linux 系统上安装
```bash
sudo apt-get install qemu-system-riscv64
```

#### 在 Windows 系统上安装
1. 下载 QEMU：https://www.qemu.org/download/
2. 运行安装程序并选择 RISC-V 架构支持
3. 将 QEMU 的安装目录添加到系统环境变量 PATH
4. 在命令提示符中验证：
   ```cmd
   qemu-system-riscv64 --version
   ```

#### 在 macOS 系统上安装
```bash
brew install qemu
```

### 步骤 4：安装其他开发工具
```bash
# 安装 Git
sudo apt-get install git

# 安装 Make
sudo apt-get install make

# 安装 Device Tree Compiler
sudo apt-get install device-tree-compiler
```

### 步骤 5：下载并分析 U-Boot 源码
1. 克隆 U-Boot 源码仓库：
   ```bash
   git clone https://github.com/u-boot/u-boot.git
   cd u-boot
   ```

2. 查看 U-Boot 目录结构：
   ```bash
   ls -la
   ```

3. 重点分析以下目录：
   - `arch/riscv/`：RISC-V 架构相关代码
   - `board/`：开发板配置文件
   - `include/`：头文件
   - `drivers/`：设备驱动

### 步骤 6：编译 U-Boot 并在 QEMU 中运行
1. 配置 U-Boot 为 QEMU RISC-V 64 位目标：
   ```bash
   make qemu-riscv64_smode_defconfig
   ```

2. 编译 U-Boot：
   ```bash
   make CROSS_COMPILE=riscv64-linux-gnu-
   ```

3. 在 QEMU 中运行 U-Boot：
   ```bash
   qemu-system-riscv64 -machine virt -m 128M -nographic \
       -bios u-boot.bin
   ```

4. 测试 U-Boot 命令：
   ```
   # 查看帮助信息
   help
   
   # 查看内存信息
   bdinfo
   
   # 退出 QEMU
   Ctrl+a 然后按 x
   ```

## 思考问题
1. Bootloader 与固件、BIOS 有什么区别？
2. 为什么需要多级引导加载器？
3. RISC-V 特权级设计的优势是什么？
4. 不同 RISC-V 工具链（如 riscv64-linux-gnu-、riscv-none-elf-）有什么区别？
5. U-Boot 的模块化设计有哪些优点？

## 实验报告要求
1. 记录实验过程中的关键步骤和命令输出
2. 分析 U-Boot 源码结构，绘制目录结构示意图
3. 回答上述思考问题
4. 总结实验中遇到的问题和解决方法

## 参考资料
1. 《RISC-V Boot Flow Specification》
2. U-Boot 官方文档：https://www.denx.de/wiki/U-Boot
3. QEMU RISC-V 文档：https://www.qemu.org/docs/master/system/riscv/
4. RISC-V 官方网站：https://riscv.org/

## 实验评分标准
1. 环境搭建完成度（30%）
2. U-Boot 编译与运行（30%）
3. 源码分析深度（20%）
4. 思考问题回答质量（20%）