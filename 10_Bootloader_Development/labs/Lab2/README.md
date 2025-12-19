# Lab2: 硬件初始化与特权级切换

## 实验目标
1. 掌握 UART 串口的初始化方法
2. 理解 RISC-V 特权级切换的原理
3. 实现 M 模式到 S 模式的切换逻辑
4. 学习 OpenSBI 的工作原理与集成方法
5. 掌握 RISC-V 控制状态寄存器（CSR）的操作

## 实验内容
1. 编写 UART 初始化代码
2. 实现简单的串口输出功能
3. 编写 M 模式到 S 模式的切换代码
4. 集成 OpenSBI 到 Bootloader 中
5. 测试特权级切换功能

## 实验步骤

### 步骤 1：学习 UART 硬件初始化
1. 阅读课程大纲中的模块 2 内容
2. 了解 UART 的基本工作原理
3. 掌握目标硬件平台的 UART 寄存器配置
4. 学习串口通信协议（波特率、数据位、停止位、奇偶校验）

### 步骤 2：编写 UART 初始化代码

1. 创建项目目录结构：
   ```bash
   mkdir -p bootloader/src
   cd bootloader
   ```

2. 编写 UART 初始化代码 `src/uart.c`：
   ```c
   #include "uart.h"
   
   #define UART_BASE 0x10000000
   #define UART_REG(offset) ((volatile uint32_t *)(UART_BASE + offset))
   
   #define UART_RBR 0x00  // 接收缓冲寄存器
   #define UART_THR 0x00  // 发送保持寄存器
   #define UART_DLL 0x00  // 除数锁存低位
   #define UART_DLM 0x04  // 除数锁存高位
   #define UART_IER 0x04  // 中断使能寄存器
   #define UART_IIR 0x08  // 中断识别寄存器
   #define UART_FCR 0x08  // FIFO 控制寄存器
   #define UART_LCR 0x0C  // 线路控制寄存器
   #define UART_MCR 0x10  // 调制解调器控制寄存器
   #define UART_LSR 0x14  // 线路状态寄存器
   #define UART_MSR 0x18  // 调制解调器状态寄存器
   #define UART_SCR 0x1C  // 划痕寄存器
   
   void uart_init(uint32_t baud_rate) {
       // 设置波特率
       uint32_t divisor = 115200 / baud_rate;
       volatile uint32_t *lcr = UART_REG(UART_LCR);
       *lcr |= 0x80;  // 设置 DLAB 位
       
       UART_REG(UART_DLL)[0] = divisor & 0xFF;
       UART_REG(UART_DLM)[0] = (divisor >> 8) & 0xFF;
       
       // 设置线路控制：8 位数据，1 位停止，无校验
       *lcr = 0x03;
       
       // 使能 FIFO
       UART_REG(UART_FCR)[0] = 0x01;
   }
   
   void uart_putc(char c) {
       while (!(UART_REG(UART_LSR)[0] & 0x20));  // 等待发送缓冲区为空
       UART_REG(UART_THR)[0] = c;
   }
   
   void uart_puts(const char *s) {
       while (*s) {
           if (*s == '\n') {
               uart_putc('\r');
           }
           uart_putc(*s++);
       }
   }
   ```

3. 编写头文件 `src/uart.h`：
   ```c
   #ifndef UART_H
   #define UART_H
   
   #include <stdint.h>
   
   void uart_init(uint32_t baud_rate);
   void uart_putc(char c);
   void uart_puts(const char *s);
   
   #endif
   ```

### 步骤 3：编写特权级切换代码

1. 编写 RISC-V 汇编代码 `src/start.S`：
   ```assembly
   .section .text
   .globl _start
   
   _start:
       # 初始化栈指针
       la sp, stack_top
       
       # 调用 C 语言入口函数
       call main
       
       # 无限循环
   loop:
       j loop
       
   .section .bss
   .align 16
   stack:
       .space 4096  # 4KB 栈空间
   stack_top:
   ```

2. 编写 C 语言主函数 `src/main.c`，包含特权级切换逻辑：
   ```c
   #include "uart.h"
   
   #define CSR_MSTATUS 0x300
   #define CSR_MEPC    0x341
   #define CSR_MTVEC   0x305
   #define CSR_MIDELEG 0x303
   #define CSR_MEDELEG 0x302
   
   void csr_write(uint32_t csr, uint32_t value) {
       asm volatile ("csrw %0, %1" :: "i"(csr), "r"(value));
   }
   
   uint32_t csr_read(uint32_t csr) {
       uint32_t value;
       asm volatile ("csrr %0, %1" : "=r"(value) :: "i"(csr));
       return value;
   }
   
   // S 模式入口函数
   void s_mode_entry() {
       uart_puts("Entered Supervisor Mode!\n");
       while (1);
   }
   
   int main() {
       // 初始化 UART
       uart_init(115200);
       uart_puts("Bootloader started in Machine Mode!\n");
       
       // 配置中断委托
       csr_write(CSR_MIDELEG, 0x00000000);  // 不委托中断
       csr_write(CSR_MEDELEG, 0x00000000);  // 不委托异常
       
       // 设置 S 模式异常向量表
       csr_write(CSR_MTVEC, (uint32_t)s_mode_entry);
       
       // 设置 MSTATUS 寄存器，准备切换到 S 模式
       uint32_t mstatus = csr_read(CSR_MSTATUS);
       mstatus &= ~(0x3 << 11);  // 清除 MPP 位
       mstatus |= (0x1 << 11);   // 设置 MPP 为 S 模式
       mstatus |= (0x1 << 3);    // 使能 MIE
       csr_write(CSR_MSTATUS, mstatus);
       
       // 设置 MEPC 为 S 模式入口地址
       csr_write(CSR_MEPC, (uint32_t)s_mode_entry);
       
       // 执行 MRET 指令，切换到 S 模式
       uart_puts("Switching to Supervisor Mode...\n");
       asm volatile ("mret");
       
       // 这里不应该执行到
       return 0;
   }
   ```

### 步骤 4：编写 Makefile

创建 `Makefile`：
```makefile
CROSS_COMPILE = riscv64-none-elf-
CC = $(CROSS_COMPILE)gcc
OBJCOPY = $(CROSS_COMPILE)objcopy
LD = $(CROSS_COMPILE)ld

CFLAGS = -march=rv32im -mabi=ilp32 -O2 -Wall -Wextra -fno-builtin -nostdlib -nostartfiles
LDFLAGS = -T linker.ld

SRCS = src/start.S src/main.c src/uart.c
OBJS = $(SRCS:.S=.o)
OBJS = $(OBJS:.c=.o)

TARGET = bootloader.elf
BIN = bootloader.bin

all: $(BIN)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(BIN): $(TARGET)
	$(OBJCOPY) -O binary $< $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET) $(BIN)
```

### 步骤 5：编写链接脚本 `linker.ld`
```ld
ENTRY(_start)

SECTIONS {
    . = 0x80000000;
    
    .text : {
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
```

### 步骤 6：编译并测试

1. 编译 Bootloader：
   ```bash
   make
   ```

2. 使用 QEMU 测试：
   ```bash
   qemu-system-riscv32 -machine virt -m 128M -nographic -bios bootloader.bin
   ```

### 步骤 7：集成 OpenSBI

1. 下载 OpenSBI：
   ```bash
   git clone https://github.com/riscv-software-src/opensbi.git
   cd opensbi
   ```

2. 编译 OpenSBI：
   ```bash
   make CROSS_COMPILE=riscv64-none-elf- PLATFORM=generic
   ```

3. 复制生成的 OpenSBI 固件：
   ```bash
   cp build/platform/generic/firmware/fw_jump.bin ../bootloader/
   ```

4. 修改 Bootloader，使其与 OpenSBI 兼容

5. 使用 QEMU 测试集成了 OpenSBI 的 Bootloader：
   ```bash
   qemu-system-riscv32 -machine virt -m 128M -nographic -bios fw_jump.bin -kernel bootloader.bin
   ```

## 思考问题
1. UART 初始化的关键步骤是什么？
2. 特权级切换时需要保存哪些上下文信息？
3. OpenSBI 在 Bootloader 中的角色是什么？
4. RISC-V 控制状态寄存器（CSR）的作用是什么？
5. 如何验证特权级切换的正确性？

## 实验报告要求
1. 记录 UART 初始化的关键寄存器配置
2. 分析特权级切换的代码实现
3. 说明 OpenSBI 的集成过程
4. 记录实验结果和测试输出
5. 回答上述思考问题

## 参考资料
1. 《RISC-V 特权架构手册》
2. OpenSBI 官方文档
3. UART 硬件数据手册
4. QEMU RISC-V 文档

## 实验评分标准
1. UART 初始化与串口输出实现（25%）
2. 特权级切换代码实现（30%）
3. OpenSBI 集成（25%）
4. 实验报告质量（20%）