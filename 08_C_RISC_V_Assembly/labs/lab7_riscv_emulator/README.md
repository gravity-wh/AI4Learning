# Lab 7: RISC-V模拟器实现

## 实验目的
1. 理解RISC-V指令集架构的细节
2. 掌握计算机组成原理和CPU工作原理
3. 学会设计和实现简单的RISC-V模拟器
4. 培养系统级编程能力

## 实验环境
- C语言编译器（如GCC/Clang）
- 文本编辑器

## RISC-V模拟器架构

### 1. 模拟器核心组件
- **寄存器文件**: 模拟RISC-V的32个通用寄存器
- **内存系统**: 模拟RISC-V的内存空间
- **指令取指单元**: 从内存中获取指令
- **指令解码单元**: 解析RISC-V指令
- **指令执行单元**: 执行指令并更新寄存器和内存
- **程序计数器**: 跟踪当前执行的指令地址

### 2. RISC-V指令格式
RISC-V有六种基本指令格式：
- R型（寄存器-寄存器）
- I型（立即数）
- S型（存储）
- B型（分支）
- U型（长立即数）
- J型（跳转）

## 实验步骤

### 1. 设计模拟器数据结构

创建 `riscv_emulator.c` 文件，定义模拟器的数据结构：
```c
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

// RISC-V寄存器数量
#define REGISTER_COUNT 32

// 内存大小（1MB）
#define MEMORY_SIZE (1024 * 1024)

// 模拟器状态
typedef struct {
    uint32_t registers[REGISTER_COUNT];  // 寄存器文件
    uint8_t memory[MEMORY_SIZE];         // 内存
    uint32_t pc;                         // 程序计数器
} RiscvEmulator;
```

### 2. 实现模拟器初始化函数

```c
// 初始化模拟器
void init_emulator(RiscvEmulator *emulator) {
    // 初始化寄存器（x0恒为0）
    for (int i = 0; i < REGISTER_COUNT; i++) {
        emulator->registers[i] = 0;
    }
    
    // 初始化内存
    for (int i = 0; i < MEMORY_SIZE; i++) {
        emulator->memory[i] = 0;
    }
    
    // 初始化程序计数器（从地址0开始）
    emulator->pc = 0;
}
```

### 3. 实现内存访问函数

```c
// 读取内存（32位）
uint32_t read_memory32(RiscvEmulator *emulator, uint32_t address) {
    if (address + 4 > MEMORY_SIZE) {
        fprintf(stderr, "Memory access out of bounds: 0x%08x\n", address);
        exit(1);
    }
    
    return (uint32_t)emulator->memory[address] |
           (uint32_t)emulator->memory[address + 1] << 8 |
           (uint32_t)emulator->memory[address + 2] << 16 |
           (uint32_t)emulator->memory[address + 3] << 24;
}

// 写入内存（32位）
void write_memory32(RiscvEmulator *emulator, uint32_t address, uint32_t value) {
    if (address + 4 > MEMORY_SIZE) {
        fprintf(stderr, "Memory access out of bounds: 0x%08x\n", address);
        exit(1);
    }
    
    emulator->memory[address] = value & 0xFF;
    emulator->memory[address + 1] = (value >> 8) & 0xFF;
    emulator->memory[address + 2] = (value >> 16) & 0xFF;
    emulator->memory[address + 3] = (value >> 24) & 0xFF;
}
```

### 4. 实现指令解码和执行函数

```c
// 解码并执行一条指令
void execute_instruction(RiscvEmulator *emulator) {
    // 取指
    uint32_t instruction = read_memory32(emulator, emulator->pc);
    
    // 解码指令
    uint32_t opcode = instruction & 0x7F;
    uint32_t rd = (instruction >> 7) & 0x1F;
    uint32_t funct3 = (instruction >> 12) & 0x7;
    uint32_t rs1 = (instruction >> 15) & 0x1F;
    uint32_t rs2 = (instruction >> 20) & 0x1F;
    uint32_t funct7 = (instruction >> 25) & 0x7F;
    
    // 立即数扩展
    int32_t imm_i = (instruction >> 20) & 0xFFF;
    if (imm_i & 0x800) imm_i |= 0xFFFFF000;
    
    // 执行指令
    switch (opcode) {
        case 0x03:  // LOAD指令（lw）
            if (funct3 == 0x03) {  // lw
                uint32_t address = emulator->registers[rs1] + imm_i;
                emulator->registers[rd] = read_memory32(emulator, address);
            }
            break;
            
        case 0x23:  // STORE指令（sw）
            if (funct3 == 0x03) {  // sw
                int32_t imm_s = ((instruction >> 25) << 5) | ((instruction >> 7) & 0x1F);
                if (imm_s & 0x800) imm_s |= 0xFFFFF000;
                uint32_t address = emulator->registers[rs1] + imm_s;
                write_memory32(emulator, address, emulator->registers[rs2]);
            }
            break;
            
        case 0x13:  // I型指令（addi）
            if (funct3 == 0x00) {  // addi
                emulator->registers[rd] = emulator->registers[rs1] + imm_i;
            }
            break;
            
        case 0x33:  // R型指令（add, sub）
            if (funct3 == 0x00) {
                if (funct7 == 0x00) {  // add
                    emulator->registers[rd] = emulator->registers[rs1] + emulator->registers[rs2];
                } else if (funct7 == 0x20) {  // sub
                    emulator->registers[rd] = emulator->registers[rs1] - emulator->registers[rs2];
                }
            }
            break;
            
        case 0x63:  // B型指令（beq）
            if (funct3 == 0x00) {  // beq
                int32_t imm_b = ((instruction >> 12) & 0x1) << 11 |
                                ((instruction >> 25) & 0x3F) << 5 |
                                ((instruction >> 8) & 0xF) << 1 |
                                ((instruction >> 7) & 0x1) << 12;
                if (imm_b & 0x1000) imm_b |= 0xFFFFE000;
                if (emulator->registers[rs1] == emulator->registers[rs2]) {
                    emulator->pc += imm_b - 4;  // 减去4是因为后面会加4
                }
            }
            break;
            
        case 0x6F:  // J型指令（jal）
            int32_t imm_j = ((instruction >> 12) & 0xFF) << 12 |
                            ((instruction >> 20) & 0x1) << 11 |
                            ((instruction >> 21) & 0x3FF) << 1 |
                            ((instruction >> 31) & 0x1) << 20;
            if (imm_j & 0x100000) imm_j |= 0xFFFE0000;
            emulator->registers[rd] = emulator->pc + 4;
            emulator->pc += imm_j - 4;  // 减去4是因为后面会加4
            break;
            
        default:
            fprintf(stderr, "Unknown instruction: 0x%08x\n", instruction);
            exit(1);
    }
    
    // 更新程序计数器（除了jal指令，它已经更新了pc）
    if (opcode != 0x6F) {
        emulator->pc += 4;
    }
    
    // x0寄存器恒为0
    emulator->registers[0] = 0;
}
```

### 5. 实现主函数和测试程序

```c
// 加载程序到内存
void load_program(RiscvEmulator *emulator, const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        fprintf(stderr, "Failed to open file: %s\n", filename);
        exit(1);
    }
    
    // 读取文件内容到内存的起始位置
    fread(emulator->memory, 1, MEMORY_SIZE, file);
    fclose(file);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <program.bin>\n", argv[0]);
        return 1;
    }
    
    // 创建并初始化模拟器
    RiscvEmulator emulator;
    init_emulator(&emulator);
    
    // 加载程序到内存
    load_program(&emulator, argv[1]);
    
    // 运行模拟器
    while (1) {
        execute_instruction(&emulator);
        
        // 简单的退出条件：如果遇到x10寄存器为1的情况
        if (emulator.registers[10] == 1) {
            break;
        }
    }
    
    // 打印寄存器状态
    printf("Registers:\n");
    for (int i = 0; i < REGISTER_COUNT; i++) {
        printf("x%02d: 0x%08x\n", i, emulator.registers[i]);
    }
    
    return 0;
}
```

### 6. 编译并测试模拟器

```bash
gcc -o riscv_emulator riscv_emulator.c
```

创建一个简单的RISC-V程序（test.s）：
```asm
.text
.globl _start
_start:
    addi x10, x0, 10  # x10 = 10
    addi x11, x0, 20  # x11 = 20
    add x12, x10, x11  # x12 = x10 + x11
    addi x10, x0, 1   # 设置退出条件
```

编译RISC-V程序：
```bash
riscv64-unknown-elf-as test.s -o test.o
riscv64-unknown-elf-objcopy -O binary test.o test.bin
```

运行模拟器：
```bash
./riscv_emulator test.bin
```

## 实验报告
1. 解释RISC-V模拟器的设计架构
2. 分析RISC-V指令集的解码和执行过程
3. 讨论模拟器实现中的难点和解决方案
4. 总结实现RISC-V模拟器的收获

## 参考资源
- [RISC-V ISA Manual](https://riscv.org/technical/specifications/)
- [Computer Organization and Design RISC-V Edition](https://www.elsevier.com/books/computer-organization-and-design-risc-v-edition/patterson/978-0-12-820331-6)
