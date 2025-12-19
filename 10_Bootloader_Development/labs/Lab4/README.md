# Lab4: 完整Bootloader实现与测试

## 实验目标
1. 整合前面实验的所有模块，实现完整的Bootloader
2. 为自研RISC软核定制Bootloader
3. 实现UART、DDR、GPIO的完整初始化
4. 实现从SD卡/串口接收OS内核镜像的功能
5. 实现将内核加载到内存指定地址并切换特权级启动
6. 测试Bootloader的完整功能并进行性能优化

## 实验内容
1. 整合Bootloader各个模块
2. 定制化开发板支持
3. 实现SD卡驱动和文件系统访问
4. 完善内核加载和启动流程
5. 编写测试用例
6. 性能优化和稳定性测试

## 实验步骤

### 步骤 1：整合Bootloader各个模块

1. 创建完整的Bootloader项目结构：
   ```bash
   mkdir -p bootloader/{src,include,board,lib,tools}
   ```

2. 整合前面实验的代码模块：
   - `src/start.S`：启动汇编代码
   - `src/main.c`：主函数
   - `src/uart.c`：UART驱动
   - `src/mm.c`：内存管理
   - `src/device_tree.c`：设备树解析
   - `src/privilege.c`：特权级切换
   - `src/load_kernel.c`：内核加载

3. 编写头文件：
   - `include/uart.h`
   - `include/mm.h`
   - `include/device_tree.h`
   - `include/privilege.h`
   - `include/load_kernel.h`
   - `include/board.h`

### 步骤 2：定制化开发板支持

1. 编写开发板相关代码 `board/my_riscv_board/board.c`：
   ```c
   #include "board.h"
   #include "uart.h"
   #include "gpio.h"
   #include "ddr.h"
   
   void board_init() {
       // 初始化时钟
       clock_init();
       
       // 初始化UART
       uart_init(115200);
       
       // 初始化GPIO
       gpio_init();
       
       // 初始化DDR内存
       ddr_init();
       
       // 初始化其他外设
       other_peripherals_init();
   }
   
   void clock_init() {
       // 时钟初始化代码
   }
   
   void gpio_init() {
       // GPIO初始化代码
   }
   
   void ddr_init() {
       // DDR初始化代码
   }
   
   void other_peripherals_init() {
       // 其他外设初始化代码
   }
   ```

2. 编写开发板配置文件 `board/my_riscv_board/config.h`：
   ```c
   #ifndef CONFIG_H
   #define CONFIG_H
   
   // 开发板配置
   #define BOARD_NAME "My RISC-V Board"
   #define CPU_FREQ 500000000  // 500MHz
   
   // 内存配置
   #define MEMORY_BASE 0x80000000
   #define MEMORY_SIZE 0x10000000  // 256MB
   
   // UART配置
   #define UART_BASE 0x10000000
   #define UART_CLOCK 115200
   
   // GPIO配置
   #define GPIO_BASE 0x10001000
   
   // DDR配置
   #define DDR_BASE 0x80000000
   #define DDR_SIZE 0x10000000
   
   // SD卡配置
   #define SD_BASE 0x10002000
   
   // 内核加载地址
   #define KERNEL_LOAD_ADDR 0x80200000
   
   #endif
   ```

### 步骤 3：实现SD卡驱动和文件系统访问

1. 编写SD卡驱动 `src/sd.c`：
   ```c
   #include "sd.h"
   #include "board.h"
   
   #define SD_CMD_TIMEOUT 10000
   
   int sd_init() {
       // SD卡初始化代码
       return 0;
   }
   
   int sd_read_block(uint32_t block_num, uint8_t *buffer) {
       // 读取单个SD卡块
       return 0;
   }
   
   int sd_write_block(uint32_t block_num, uint8_t *buffer) {
       // 写入单个SD卡块
       return 0;
   }
   ```

2. 编写简单的FAT文件系统访问 `src/fatfs.c`：
   ```c
   #include "fatfs.h"
   #include "sd.h"
   
   int fatfs_init() {
       // FAT文件系统初始化
       return 0;
   }
   
   int fatfs_open_file(const char *filename, file_t *file) {
       // 打开文件
       return 0;
   }
   
   int fatfs_read_file(file_t *file, uint8_t *buffer, uint32_t size) {
       // 读取文件内容
       return 0;
   }
   
   int fatfs_close_file(file_t *file) {
       // 关闭文件
       return 0;
   }
   ```

### 步骤 4：完善内核加载和启动流程

1. 更新内核加载代码 `src/load_kernel.c`：
   ```c
   #include "load_kernel.h"
   #include "uart.h"
   #include "sd.h"
   #include "fatfs.h"
   #include "mm.h"
   
   int load_kernel_from_sd(const char *filename, uint8_t **kernel_addr, uint32_t *kernel_size) {
       file_t file;
       
       if (fatfs_open_file(filename, &file) != 0) {
           uart_puts("Failed to open kernel file.\n");
           return -1;
       }
       
       *kernel_size = file.size;
       *kernel_addr = mm_alloc(*kernel_size);
       
       if (*kernel_addr == NULL) {
           uart_puts("Failed to allocate memory for kernel.\n");
           fatfs_close_file(&file);
           return -1;
       }
       
       if (fatfs_read_file(&file, *kernel_addr, *kernel_size) != 0) {
           uart_puts("Failed to read kernel file.\n");
           mm_free(*kernel_addr);
           fatfs_close_file(&file);
           return -1;
       }
       
       fatfs_close_file(&file);
       uart_puts("Kernel loaded from SD card successfully.\n");
       return 0;
   }
   
   int load_kernel_from_uart(uint8_t **kernel_addr, uint32_t *kernel_size) {
       // 从串口接收内核镜像（使用YMODEM协议）
       uart_puts("Waiting for kernel image via UART...\n");
       // YMODEM接收实现
       return -1;
   }
   
   void start_kernel(uint8_t *kernel_addr, uint32_t kernel_size, void *dtb_addr) {
       uart_puts("Starting kernel...\n");
       
       // 设置启动参数
       setup_boot_args(kernel_addr, kernel_size, dtb_addr);
       
       // 切换到S模式并启动内核
       switch_to_s_mode_and_boot(kernel_addr);
   }
   ```

2. 更新主函数 `src/main.c`：
   ```c
   #include "board.h"
   #include "uart.h"
   #include "mm.h"
   #include "device_tree.h"
   #include "load_kernel.h"
   
   int main() {
       // 初始化开发板
       board_init();
       uart_puts("Board initialized.\n");
       
       // 初始化内存管理
       mm_init();
       uart_puts("Memory management initialized.\n");
       
       // 初始化SD卡和文件系统
       if (sd_init() == 0) {
           uart_puts("SD card initialized.\n");
           
           if (fatfs_init() == 0) {
               uart_puts("FAT filesystem initialized.\n");
           } else {
               uart_puts("Failed to initialize FAT filesystem.\n");
           }
       } else {
           uart_puts("Failed to initialize SD card.\n");
       }
       
       // 初始化设备树
       void *dtb_addr = (void *)0x83000000;
       if (dt_init(dtb_addr) == 0) {
           uart_puts("Device tree initialized.\n");
       } else {
           uart_puts("Failed to initialize device tree.\n");
       }
       
       // 加载内核
       uint8_t *kernel_addr;
       uint32_t kernel_size;
       
       if (load_kernel_from_sd("kernel.bin", &kernel_addr, &kernel_size) != 0) {
           uart_puts("Trying to load kernel from UART...\n");
           if (load_kernel_from_uart(&kernel_addr, &kernel_size) != 0) {
               uart_puts("Failed to load kernel from all sources.\n");
               while (1);
           }
       }
       
       // 启动内核
       start_kernel(kernel_addr, kernel_size, dtb_addr);
       
       return 0;
   }
   ```

### 步骤 5：编写Makefile和链接脚本

1. 编写Makefile：
   ```makefile
   CROSS_COMPILE = riscv64-none-elf-
   CC = $(CROSS_COMPILE)gcc
   AS = $(CROSS_COMPILE)as
   LD = $(CROSS_COMPILE)ld
   OBJCOPY = $(CROSS_COMPILE)objcopy
   OBJDUMP = $(CROSS_COMPILE)objdump
   
   BOARD = my_riscv_board
   
   INCLUDES = -Iinclude -Iboard/$(BOARD)
   CFLAGS = -march=rv32im -mabi=ilp32 -O2 -Wall -Wextra -fno-builtin -nostdlib -nostartfiles $(INCLUDES)
   LDFLAGS = -T link.ld
   
   SRCS = src/start.S src/main.c src/uart.c src/mm.c src/device_tree.c \
          src/privilege.c src/load_kernel.c src/sd.c src/fatfs.c src/gpio.c src/ddr.c
   
   BOARD_SRCS = board/$(BOARD)/board.c
   
   OBJS = $(SRCS:.S=.o) $(SRCS:.c=.o) $(BOARD_SRCS:.c=.o)
   
   TARGET = bootloader.elf
   BIN = bootloader.bin
   
   all: $(BIN)
   
   $(TARGET): $(OBJS)
       $(LD) $(LDFLAGS) -o $@ $^
   
   $(BIN): $(TARGET)
       $(OBJCOPY) -O binary $< $@
   
   %.o: %.S
       $(AS) $(CFLAGS) -c $< -o $@
   
   %.o: %.c
       $(CC) $(CFLAGS) -c $< -o $@
   
   clean:
       rm -f $(OBJS) $(TARGET) $(BIN)
   
   disasm:
       $(OBJDUMP) -d $(TARGET) > $(TARGET).disasm
   ```

2. 编写链接脚本 `link.ld`：
   ```ld
   ENTRY(_start)
   
   MEMORY {
       rom : ORIGIN = 0x80000000, LENGTH = 0x20000  /* 128KB */
       ram : ORIGIN = 0x80200000, LENGTH = 0x10000000  /* 256MB */
   }
   
   SECTIONS {
       .text : {
           *(.text)
       } > rom
       
       .rodata : {
           *(.rodata)
       } > rom
       
       .data : {
           *(.data)
       } > ram AT > rom
       
       .bss : {
           *(.bss)
       } > ram
       
       .stack : {
           *(.stack)
       } > ram
   }
   ```

### 步骤 6：编译并测试

1. 编译Bootloader：
   ```bash
   make
   ```

2. 编译测试内核：
   ```bash
   # 使用前面实验的内核代码
   riscv64-none-elf-gcc -march=rv32im -mabi=ilp32 -O2 -Wall -Wextra -fno-builtin -nostdlib -nostartfiles -T kernel.ld kernel.c -o kernel.elf
   riscv64-none-elf-objcopy -O binary kernel.elf kernel.bin
   ```

3. 使用QEMU测试：
   ```bash
   qemu-system-riscv32 -machine virt -m 256M -nographic -bios bootloader.bin -drive file=sdcard.img,format=raw,id=sd0 -device sd-card,drive=sd0
   ```

4. 在自研RISC软核上测试：
   ```bash
   # 使用开发板的烧录工具
   ./tools/flash bootloader.bin
   ```

### 步骤 7：性能优化和稳定性测试

1. 性能优化：
   - 减少不必要的初始化步骤
   - 优化内存访问模式
   - 实现缓存管理
   - 优化串口通信速度

2. 稳定性测试：
   - 长时间运行测试
   - 异常情况处理测试
   - 电源波动测试
   - 多内核镜像测试

## 思考问题
1. 如何设计可扩展的Bootloader架构？
2. Bootloader的启动速度受哪些因素影响？如何优化？
3. 如何确保Bootloader的稳定性和可靠性？
4. 不同存储设备（SD卡/串口）的内核加载方式有什么优缺点？
5. 如何实现Bootloader的安全启动功能？

## 实验报告要求
1. 详细描述完整Bootloader的架构设计
2. 说明自研RISC软核的定制化实现
3. 记录SD卡驱动和文件系统的实现细节
4. 分析Bootloader的启动时间和性能优化效果
5. 总结实验过程中的问题和解决方法
6. 回答上述思考问题

## 参考资料
1. U-Boot源码分析
2. OpenSBI官方文档
3. 《RISC-V Boot Flow Specification》
4. SD卡规范文档
5. FAT文件系统规范

## 实验评分标准
1. 完整Bootloader架构实现（25%）
2. 自研RISC软核定制支持（20%）
3. SD卡驱动和文件系统实现（20%）
4. 内核加载和启动流程（15%）
5. 性能优化和稳定性测试（10%）
6. 实验报告质量（10%）