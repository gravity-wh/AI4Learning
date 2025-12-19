# Lab 5: 链接器与 ELF 文件生成

## 实验目标
1. 理解 ELF 文件的结构和格式
2. 掌握链接器的工作原理和流程
3. 学会编写和使用链接脚本
4. 了解静态链接与动态链接的区别
5. 掌握分析 ELF 文件的工具和方法

## 实验背景

链接器是编译过程的最后一个阶段，它负责将多个目标文件组合成一个可执行文件或库。ELF（Executable and Linkable Format）是现代 Unix-like 系统中常用的目标文件格式，它定义了可执行文件、共享库、目标文件和核心转储文件的格式。

### ELF 文件的基本结构

ELF 文件由以下主要部分组成：
- ELF 头：包含文件的基本信息，如文件类型、机器架构、入口点等
- 程序头表：描述如何将文件映射到内存
- 节头表：描述文件中的各个节（section）
- 节：包含实际的代码、数据、符号表等内容

### 链接器的主要功能

- 符号解析：将引用与定义关联起来
- 重定位：调整目标文件中的地址引用
- 内存布局：根据链接脚本安排各个节的位置
- 库处理：处理静态库和动态库

## 实验环境

- 已搭建完成的 GCC/RISC-V 工具链开发环境
- 常用的 ELF 文件分析工具：objdump, readelf, nm, size
- 文本编辑器：vim 或其他

## 实验步骤

### 1. ELF 文件格式分析

#### 1.1 创建一个简单的程序

```bash
# 创建一个简单的 C 程序
cat > simple_elf.c << EOF
#include <stdio.h>

int global_var = 42;
const int const_var = 100;

int add(int a, int b) {
    return a + b;
}

int main() {
    int local_var = 10;
    int result = add(local_var, global_var);
    printf("Result: %d\n", result);
    printf("Const var: %d\n", const_var);
    return 0;
}
EOF

# 编译成 ELF 文件
riscv64-unknown-elf-gcc simple_elf.c -o simple_elf.elf
```

#### 1.2 使用 readelf 分析 ELF 头

```bash
# 查看 ELF 头信息
riscv64-unknown-elf-readelf -h simple_elf.elf

# 查看程序头表
riscv64-unknown-elf-readelf -l simple_elf.elf

# 查看节头表
riscv64-unknown-elf-readelf -S simple_elf.elf
```

#### 1.3 分析各个节的内容

```bash
# 查看代码节 (.text)
riscv64-unknown-elf-objdump -d simple_elf.elf | less

# 查看数据节 (.data)
riscv64-unknown-elf-objdump -s -j .data simple_elf.elf

# 查看只读数据节 (.rodata)
riscv64-unknown-elf-objdump -s -j .rodata simple_elf.elf

# 查看未初始化数据节 (.bss)
riscv64-unknown-elf-objdump -s -j .bss simple_elf.elf
```

### 2. 链接器工作原理

#### 2.1 生成多个目标文件

```bash
# 创建第一个源文件
cat > module1.c << EOF
int global_data = 100;

int module1_function(int x) {
    return x * 2;
}
EOF

# 创建第二个源文件
cat > module2.c << EOF
int module1_function(int x); // 外部函数声明
extern int global_data;       // 外部变量声明

int module2_function(int x) {
    return module1_function(x) + global_data;
}
EOF

# 创建主程序
cat > main.c << EOF
#include <stdio.h>

int module2_function(int x); // 外部函数声明

global int main_variable = 200;

int main() {
    int result = module2_function(main_variable);
    printf("Result: %d\n", result);
    return 0;
}
EOF

# 编译成目标文件
riscv64-unknown-elf-gcc -c module1.c -o module1.o
riscv64-unknown-elf-gcc -c module2.c -o module2.o
riscv64-unknown-elf-gcc -c main.c -o main.o
```

#### 2.2 查看符号表

```bash
# 查看单个目标文件的符号表
riscv64-unknown-elf-nm module1.o
riscv64-unknown-elf-nm module2.o
riscv64-unknown-elf-nm main.o

# 查看详细的符号信息
riscv64-unknown-elf-readelf -s module1.o
```

#### 2.3 链接目标文件

```bash
# 链接目标文件生成可执行文件
riscv64-unknown-elf-gcc module1.o module2.o main.o -o program.elf

# 查看链接后的符号表
riscv64-unknown-elf-nm program.elf

# 查看重定位信息
riscv64-unknown-elf-readelf -r module2.o
```

### 3. 链接脚本编写

#### 3.1 查看默认链接脚本

```bash
# 查看 GCC 使用的默认链接脚本
riscv64-unknown-elf-gcc --verbose | grep SEARCH_DIR
riscv64-unknown-elf-ld --verbose | head -n 100 > default_linker_script.ld
```

#### 3.2 编写自定义链接脚本

创建一个名为 `custom.ld` 的自定义链接脚本：

```bash
cat > custom.ld << EOF
/* 自定义链接脚本 */
OUTPUT_FORMAT("elf64-littleriscv", "elf64-littleriscv", "elf64-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(main)

MEMORY {
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 1M
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 1M
}

SECTIONS {
    /* 代码段 */
    .text : {
        *(.text)
        *(.text.*)
        . = ALIGN(4);
    } > ROM

    /* 只读数据段 */
    .rodata : {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
    } > ROM

    /* 数据段 */
    .data : {
        *(.data)
        *(.data.*)
        . = ALIGN(4);
    } > RAM AT> ROM

    /* 未初始化数据段 */
    .bss : {
        *(.bss)
        *(.bss.*)
        . = ALIGN(4);
    } > RAM

    /* 符号表和调试信息 */
    .symtab : {
        *(.symtab)
    }

    .strtab : {
        *(.strtab)
    }

    .shstrtab : {
        *(.shstrtab)
    }

    .debug_info : {
        *(.debug_info)
    }

    .debug_abbrev : {
        *(.debug_abbrev)
    }

    .debug_line : {
        *(.debug_line)
    }

    .debug_frame : {
        *(.debug_frame)
    }
}
EOF
```

#### 3.3 使用自定义链接脚本

```bash
# 使用自定义链接脚本链接程序
riscv64-unknown-elf-gcc -T custom.ld module1.o module2.o main.o -o program_custom.elf

# 比较使用不同链接脚本生成的程序
riscv64-unknown-elf-size program.elf program_custom.elf

# 查看内存布局
riscv64-unknown-elf-readelf -l program_custom.elf
```

### 4. 静态链接与动态链接

#### 4.1 静态链接

```bash
# 静态链接 libc
riscv64-unknown-elf-gcc -static simple_elf.c -o simple_elf_static.elf

# 比较静态链接和动态链接的文件大小
riscv64-unknown-elf-size simple_elf.elf simple_elf_static.elf

# 查看依赖的动态库
riscv64-unknown-elf-readelf -d simple_elf.elf
```

#### 4.2 创建和使用静态库

```bash
# 创建静态库
riscv64-unknown-elf-ar rcs libmymath.a module1.o

# 查看静态库内容
riscv64-unknown-elf-ar t libmymath.a

# 使用静态库
riscv64-unknown-elf-gcc main.o module2.o -L. -lmymath -o program_lib.elf
```

#### 4.3 创建和使用动态库

```bash
# 创建动态库
riscv64-unknown-elf-gcc -shared -fpic module1.c -o libmymath.so

# 使用动态库
riscv64-unknown-elf-gcc main.o module2.o -L. -lmymath -o program_dyn.elf

# 查看动态库依赖
riscv64-unknown-elf-readelf -d program_dyn.elf
```

### 5. ELF 文件调试与分析

#### 5.1 使用 GDB 调试 ELF 文件

```bash
# 编译带调试信息的程序
riscv64-unknown-elf-gcc -g simple_elf.c -o simple_elf_debug.elf

# 使用 GDB 调试
riscv64-unknown-elf-gdb simple_elf_debug.elf
```

在 GDB 中可以执行以下命令：
- `file simple_elf_debug.elf`：加载可执行文件
- `disassemble main`：反汇编 main 函数
- `break main`：在 main 函数设置断点
- `run`：运行程序
- `info files`：查看文件信息
- `info sections`：查看节信息

#### 5.2 使用 objdump 分析 ELF 文件

```bash
# 反汇编所有段
riscv64-unknown-elf-objdump -D simple_elf.elf > disassembly.txt

# 查看重定位信息
riscv64-unknown-elf-objdump -r module2.o

# 查看符号表
riscv64-unknown-elf-objdump -t simple_elf.elf
```

## 实验内容

1. **ELF 文件格式分析**：
   - 创建并编译简单程序
   - 使用 readelf 和 objdump 分析 ELF 文件结构
   - 理解各个节的内容和作用

2. **链接器工作原理**：
   - 生成多个目标文件
   - 分析符号表和重定位信息
   - 手动执行链接过程

3. **链接脚本编写**：
   - 查看默认链接脚本
   - 编写自定义链接脚本
   - 比较不同链接脚本的效果

4. **静态链接与动态链接**：
   - 比较静态链接和动态链接的区别
   - 创建和使用静态库
   - 创建和使用动态库

5. **ELF 文件调试与分析**：
   - 使用 GDB 调试 ELF 文件
   - 分析调试信息和符号表

## 实验结果分析

1. **ELF 文件结构分析**：
   - 描述 ELF 文件的各个部分及其作用
   - 分析不同类型节的内容和特点

2. **链接过程分析**：
   - 解释符号解析和重定位的过程
   - 分析链接前后符号表的变化

3. **链接脚本效果分析**：
   - 比较不同链接脚本生成的程序的内存布局
   - 分析链接脚本对程序执行的影响

4. **链接方式比较**：
   - 比较静态链接和动态链接的优缺点
   - 分析库的创建和使用过程

## 思考问题

1. ELF 文件的程序头表和节头表有什么区别？它们各自的作用是什么？

2. 符号解析和重定位的区别是什么？它们在链接过程中分别扮演什么角色？

3. 链接脚本中的 MEMORY 命令和 SECTIONS 命令分别有什么作用？

4. 静态链接和动态链接的区别是什么？它们各自的优缺点是什么？

5. 如何确定一个 ELF 文件是静态链接还是动态链接？

6. 为什么需要重定位？重定位的过程是怎样的？

7. 静态库和动态库在链接过程中的处理方式有什么不同？

8. ELF 文件中的调试信息存储在哪里？如何使用这些调试信息？

## 实验总结

通过本实验，你应该已经掌握了：
1. ELF 文件的结构和格式
2. 链接器的工作原理和流程
3. 链接脚本的编写和使用方法
4. 静态链接与动态链接的区别和应用场景
5. 分析和调试 ELF 文件的工具和方法

这些知识将帮助你理解编译过程的最后阶段，为深入理解程序的加载和执行奠定基础。

## 参考资料

- [ELF Specification](https://refspecs.linuxfoundation.org/elf/elf.pdf)
- [GNU Binutils Documentation](https://sourceware.org/binutils/docs/)
- [GNU Linker Scripts](https://sourceware.org/binutils/docs/ld/Scripts.html)
- [Understanding the ELF File Format](https://www.airs.com/blog/archives/38)
- [Static vs Dynamic Linking](https://www.baeldung.com/linux/static-vs-dynamic-libraries)
