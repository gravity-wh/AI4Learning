# Lab3: 内核加载与设备树处理

## 实验目标
1. 了解内核镜像的格式和结构
2. 掌握从串口接收内核镜像的方法
3. 理解设备树的基本概念和结构
4. 学习设备树的解析方法
5. 实现内核镜像加载到内存指定地址

## 实验内容
1. 分析 ELF 格式内核镜像
2. 编写串口接收代码
3. 学习设备树语法和结构
4. 实现设备树解析功能
5. 编写内存管理模块
6. 实现内核镜像加载功能

## 实验步骤

### 步骤 1：学习内核镜像格式与设备树基础
1. 阅读课程大纲中的模块 4 内容
2. 了解 ELF 文件格式的结构
3. 学习设备树的基本语法和节点结构
4. 掌握设备树与内核的关系

### 步骤 2：分析 ELF 格式内核镜像

1. 创建测试用的简单内核：
   ```c
   // kernel.c
   #include <stdint.h>
   
   #define UART_BASE 0x10000000
   #define UART_REG(offset) ((volatile uint32_t *)(UART_BASE + offset))
   #define UART_THR 0x00
   #define UART_LSR 0x14
   
   void uart_putc(char c) {
       while (!(UART_REG(UART_LSR)[0] & 0x20));
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
   
   void _start() {
       uart_puts("Hello from Kernel!\n");
       while (1);
   }
   ```

2. 编写内核的链接脚本 `kernel.ld`：
   ```ld
   ENTRY(_start)
   
   SECTIONS {
       . = 0x80200000;
       
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

3. 编译内核：
   ```bash
   riscv64-none-elf-gcc -march=rv32im -mabi=ilp32 -O2 -Wall -Wextra -fno-builtin -nostdlib -nostartfiles -T kernel.ld kernel.c -o kernel.elf
   
   # 转换为二进制格式
   riscv64-none-elf-objcopy -O binary kernel.elf kernel.bin
   ```

4. 分析 ELF 文件格式：
   ```bash
   riscv64-none-elf-readelf -h kernel.elf  # 查看 ELF 文件头
   riscv64-none-elf-readelf -l kernel.elf  # 查看程序头
   riscv64-none-elf-readelf -S kernel.elf  # 查看节头
   ```

### 步骤 3：编写串口接收代码

1. 在 Lab2 的基础上，扩展 UART 功能，添加接收函数 `src/uart.c`：
   ```c
   // 添加到 uart.c 文件
   char uart_getc() {
       while (!(UART_REG(UART_LSR)[0] & 0x01));  // 等待接收缓冲区有数据
       return (char)UART_REG(UART_RBR)[0];
   }
   
   int uart_gets(char *buf, int len) {
       int i = 0;
       char c;
       
       while (i < len - 1) {
           c = uart_getc();
           if (c == '\r' || c == '\n') {
               break;
           }
           buf[i++] = c;
       }
       
       buf[i] = '\0';
       return i;
   }
   ```

2. 更新头文件 `src/uart.h`：
   ```c
   char uart_getc();
   int uart_gets(char *buf, int len);
   ```

### 步骤 4：学习设备树语法和结构

1. 创建简单的设备树源文件 `test.dts`：
   ```dts
   /dts-v1/;
   
   / {
       #address-cells = <1>;
       #size-cells = <1>;
       
       compatible = "test,platform";
       model = "Test Platform";
       
       cpus {
           #address-cells = <1>;
           #size-cells = <0>;
           
           cpu@0 {
               compatible = "riscv";
               reg = <0>;
               riscv,isa = "rv32im";
               status = "okay";
           };
       };
       
       memory@80000000 {
           device_type = "memory";
           reg = <0x80000000 0x8000000>;  // 128MB
       };
       
       uart@10000000 {
           compatible = "ns16550a";
           reg = <0x10000000 0x100>;
           interrupts = <1>;
           clock-frequency = <115200>;
           status = "okay";
       };
   };
   ```

2. 编译设备树：
   ```bash
   dtc -I dts -O dtb test.dts -o test.dtb
   ```

3. 分析设备树二进制文件：
   ```bash
   fdtdump test.dtb
   ```

### 步骤 5：实现设备树解析功能

1. 编写设备树解析代码 `src/device_tree.c`：
   ```c
   #include "device_tree.h"
   #include <stdint.h>
   
   // 设备树头部结构
   struct fdt_header {
       uint32_t magic;
       uint32_t totalsize;
       uint32_t off_dt_struct;
       uint32_t off_dt_strings;
       uint32_t off_mem_rsvmap;
       uint32_t version;
       uint32_t last_comp_version;
       uint32_t boot_cpuid_phys;
       uint32_t size_dt_strings;
       uint32_t size_dt_struct;
   };
   
   // 设备树节点头结构
   struct fdt_node_header {
       uint32_t tag;
       char name[0];
   };
   
   // 设备树属性结构
   struct fdt_property {
       uint32_t tag;
       uint32_t len;
       uint32_t nameoff;
       char data[0];
   };
   
   #define FDT_MAGIC 0xd00dfeed
   #define FDT_BEGIN_NODE 0x1
   #define FDT_END_NODE 0x2
   #define FDT_PROP 0x3
   #define FDT_NOP 0x4
   #define FDT_END 0x9
   
   static struct fdt_header *fdt;
   static char *fdt_strings;
   
   int dt_init(void *dtb_addr) {
       fdt = (struct fdt_header *)dtb_addr;
       
       // 检查设备树魔数
       if (fdt->magic != FDT_MAGIC) {
           return -1;
       }
       
       fdt_strings = (char *)dtb_addr + fdt->off_dt_strings;
       return 0;
   }
   
   const char *dt_get_property(const char *node_path, const char *prop_name, int *len) {
       // 简化实现，实际需要完整的节点路径解析
       // 这里仅作为示例
       return NULL;
   }
   ```

2. 编写头文件 `src/device_tree.h`：
   ```c
   #ifndef DEVICE_TREE_H
   #define DEVICE_TREE_H
   
   int dt_init(void *dtb_addr);
   const char *dt_get_property(const char *node_path, const char *prop_name, int *len);
   
   #endif
   ```

### 步骤 6：编写内存管理模块

1. 编写内存管理代码 `src/mm.c`：
   ```c
   #include "mm.h"
   #include <stdint.h>
   
   #define MEMORY_BASE 0x80000000
   #define MEMORY_SIZE 0x8000000  // 128MB
   
   static uint32_t next_free_addr = MEMORY_BASE;
   
   void *mm_alloc(uint32_t size) {
       if (next_free_addr + size > MEMORY_BASE + MEMORY_SIZE) {
           return NULL;  // 内存不足
       }
       
       void *addr = (void *)next_free_addr;
       next_free_addr += size;
       
       // 按 4 字节对齐
       next_free_addr = (next_free_addr + 3) & ~3;
       
       return addr;
   }
   
   void mm_free(void *addr) {
       // 简化实现，仅作示例
   }
   
   void mm_init() {
       next_free_addr = MEMORY_BASE;
   }
   ```

2. 编写头文件 `src/mm.h`：
   ```c
   #ifndef MM_H
   #define MM_H
   
   void mm_init();
   void *mm_alloc(uint32_t size);
   void mm_free(void *addr);
   
   #endif
   ```

### 步骤 7：实现内核镜像加载功能

1. 更新主函数 `src/main.c`，添加内核加载功能：
   ```c
   #include "uart.h"
   #include "mm.h"
   #include "device_tree.h"
   
   #define KERNEL_LOAD_ADDR 0x80200000
   #define KERNEL_MAX_SIZE 0x100000  // 1MB
   
   // 简单的 YMODEM 协议接收实现
   int ymodem_receive(uint8_t *buffer, uint32_t *size) {
       uart_puts("Waiting for kernel image via YMODEM...\n");
       // YMODEM 协议实现（简化）
       return -1;  // 示例返回错误
   }
   
   int main() {
       // 初始化 UART
       uart_init(115200);
       uart_puts("Bootloader started!\n");
       
       // 初始化内存管理
       mm_init();
       uart_puts("Memory management initialized.\n");
       
       // 初始化设备树
       void *dtb_addr = (void *)0x83000000;
       if (dt_init(dtb_addr) == 0) {
           uart_puts("Device tree initialized.\n");
       } else {
           uart_puts("Failed to initialize device tree.\n");
       }
       
       // 接收内核镜像
       uint8_t *kernel_buffer = (uint8_t *)KERNEL_LOAD_ADDR;
       uint32_t kernel_size;
       
       if (ymodem_receive(kernel_buffer, &kernel_size) == 0) {
           uart_puts("Kernel image received successfully.\n");
           uart_puts("Kernel size: ");
           // 打印内核大小
       } else {
           uart_puts("Failed to receive kernel image.\n");
           while (1);
       }
       
       // 跳转到内核
       uart_puts("Jumping to kernel...\n");
       void (*kernel_entry)() = (void (*)())KERNEL_LOAD_ADDR;
       kernel_entry();
       
       return 0;
   }
   ```

### 步骤 8：编译并测试

1. 更新 Makefile，添加新的源文件：
   ```makefile
   SRCS = src/start.S src/main.c src/uart.c src/mm.c src/device_tree.c
   ```

2. 编译 Bootloader：
   ```bash
   make
   ```

3. 使用 QEMU 测试：
   ```bash
   qemu-system-riscv32 -machine virt -m 128M -nographic -bios bootloader.bin
   ```

## 思考问题
1. ELF 文件格式的主要组成部分有哪些？
2. 为什么需要将内核镜像加载到内存指定地址？
3. 设备树的主要作用是什么？
4. 如何处理大尺寸内核镜像的加载？
5. 内存管理在 Bootloader 中的重要性是什么？

## 实验报告要求
1. 分析 ELF 文件格式的结构
2. 说明串口接收内核镜像的实现方法
3. 分析设备树的节点结构和属性
4. 记录内存管理模块的设计思路
5. 回答上述思考问题

## 参考资料
1. 《ELF 文件格式详解》
2. 《Device Tree Specification》
3. Linux 内核文档：Documentation/devicetree
4. YMODEM 协议规范

## 实验评分标准
1. ELF 格式分析（15%）
2. 串口接收功能实现（25%）
3. 设备树解析功能（25%）
4. 内存管理模块（20%）
5. 实验报告质量（15%）