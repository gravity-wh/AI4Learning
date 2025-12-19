# Lab 6: RISC-V系统调用

## 实验目的
1. 理解RISC-V系统调用的机制
2. 掌握常用的RISC-V系统调用
3. 学会使用系统调用进行输入输出操作
4. 理解系统调用在操作系统中的作用

## 实验环境
- RISC-V GCC工具链
- 文本编辑器
- QEMU模拟器（用于运行RISC-V程序）

## RISC-V系统调用基础

### 1. 系统调用机制
RISC-V使用`ecall`指令触发系统调用，系统调用号存储在`a7`寄存器中，参数存储在`a0-a5`寄存器中，返回值存储在`a0`寄存器中。

### 2. 常用系统调用
| 系统调用号 | 功能 | 参数 | 返回值 |
|-----------|------|------|--------|
| 63        | read | a0: 文件描述符<br>a1: 缓冲区地址<br>a2: 缓冲区大小 | 读取的字节数 |
| 64        | write | a0: 文件描述符<br>a1: 缓冲区地址<br>a2: 缓冲区大小 | 写入的字节数 |
| 93        | exit | a0: 退出码 | 无 |
| 1024      | open | a0: 文件名地址<br>a1: 标志<br>a2: 权限 | 文件描述符 |
| 1025      | close | a0: 文件描述符 | 成功返回0 |

### 3. 文件描述符
- 0: 标准输入 (stdin)
- 1: 标准输出 (stdout)
- 2: 标准错误 (stderr)

## 实验步骤

### 1. 使用系统调用进行输出

创建 `syscall_write.s` 文件，使用系统调用输出字符串：
```asm
.data
    msg: .asciz "Hello, RISC-V System Call!\n"

.text
.globl main
main:
    # 使用write系统调用输出字符串
    li a0, 1          # 文件描述符1（标准输出）
    la a1, msg        # 字符串地址
    li a2, 27         # 字符串长度（包括换行符）
    li a7, 64         # write系统调用号
    ecall             # 触发系统调用

    # 使用exit系统调用退出程序
    li a0, 0          # 退出码0
    li a7, 93         # exit系统调用号
    ecall             # 触发系统调用
```

编译并使用QEMU运行：
```bash
riscv64-unknown-elf-as syscall_write.s -o syscall_write.o
riscv64-unknown-elf-ld syscall_write.o -o syscall_write
qemu-riscv64 ./syscall_write
```

### 2. 使用系统调用进行输入

创建 `syscall_read.s` 文件，使用系统调用读取用户输入：
```asm
.data
    prompt: .asciz "Enter your name: "
    hello:  .asciz "Hello, "
    buffer: .space 100  # 100字节的缓冲区

.text
.globl main
main:
    # 输出提示信息
    li a0, 1
    la a1, prompt
    li a2, 17
    li a7, 64
    ecall

    # 读取用户输入
    li a0, 0          # 文件描述符0（标准输入）
    la a1, buffer     # 缓冲区地址
    li a2, 100        # 缓冲区大小
    li a7, 63         # read系统调用号
    ecall

    # 保存读取的字节数
    mv t0, a0

    # 输出"Hello, "
    li a0, 1
    la a1, hello
    li a2, 7
    li a7, 64
    ecall

    # 输出用户输入
    li a0, 1
    la a1, buffer
    mv a2, t0         # 使用实际读取的字节数
    li a7, 64
    ecall

    # 退出程序
    li a0, 0
    li a7, 93
    ecall
```

### 3. 使用系统调用进行文件操作

创建 `syscall_file.s` 文件，使用系统调用进行文件读写：
```asm
.data
    filename: .asciz "test.txt"
    content:  .asciz "Hello, File World!\n"
    buffer:   .space 100

.text
.globl main
main:
    # 打开文件（创建并写入）
    li a0, 1024      # open系统调用号
    la a1, filename  # 文件名
    li a2, 1         # O_WRONLY
    li a3, 0o644     # 文件权限
    li a7, 1024
    ecall

    # 保存文件描述符
    mv t0, a0

    # 写入文件
    li a0, t0
    la a1, content
    li a2, 19        # 内容长度
    li a7, 64
    ecall

    # 关闭文件
    li a0, t0
    li a7, 1025      # close系统调用号
    ecall

    # 重新打开文件（只读）
    li a0, 1024
    la a1, filename
    li a2, 0         # O_RDONLY
    li a3, 0
    li a7, 1024
    ecall

    # 保存文件描述符
    mv t0, a0

    # 读取文件内容
    li a0, t0
    la a1, buffer
    li a2, 100
    li a7, 63
    ecall

    # 保存读取的字节数
    mv t1, a0

    # 输出文件内容
    li a0, 1
    la a1, buffer
    mv a2, t1
    li a7, 64
    ecall

    # 关闭文件
    li a0, t0
    li a7, 1025
    ecall

    # 退出程序
    li a0, 0
    li a7, 93
    ecall
```

## 实验报告
1. 解释RISC-V系统调用的机制
2. 分析系统调用在操作系统中的作用
3. 比较系统调用与普通函数调用的区别
4. 总结常用的RISC-V系统调用

## 参考资源
- [RISC-V特权架构手册](https://riscv.org/wp-content/uploads/2017/05/riscv-privileged-v1.10.pdf)
- [QEMU用户手册](https://www.qemu.org/docs/master/)
