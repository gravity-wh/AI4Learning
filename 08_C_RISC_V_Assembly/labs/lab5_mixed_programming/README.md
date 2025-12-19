# Lab 5: C与汇编混合编程

## 实验目的
1. 掌握C语言中内联汇编的使用
2. 学会在C程序中调用汇编函数
3. 学会在汇编程序中调用C函数
4. 理解混合编程的注意事项和最佳实践

## 实验环境
- RISC-V GCC工具链
- 文本编辑器

## 混合编程技术

### 1. 内联汇编
内联汇编允许在C代码中直接嵌入汇编指令，语法如下：

```c
asm volatile(
    "assembly code"        /* 汇编指令 */
    : output operands      /* 输出操作数 */
    : input operands       /* 输入操作数 */
    : clobbers             /* 被修改的寄存器 */
);
```

**约束符说明：**
- `r`: 任意通用寄存器
- `m`: 内存操作数
- `i`: 立即数
- `a`: a0寄存器
- `s`: s0寄存器

### 2. 外部汇编
外部汇编允许C程序调用汇编函数，或汇编程序调用C函数：

**C调用汇编：**
```c
// C代码中声明汇编函数
extern int asm_add(int a, int b);

int main() {
    int result = asm_add(5, 3);
    return result;
}
```

**汇编实现：**
```asm
.text
.globl asm_add
asm_add:
    add a0, a0, a1  # a0 = a0 + a1
    ret
```

## 实验步骤

### 1. 使用内联汇编

创建 `inline_asm.c` 文件，使用内联汇编实现加法：
```c
#include <stdio.h>

int main() {
    int a = 5;
    int b = 3;
    int result;

    // 内联汇编实现result = a + b
    asm volatile(
        "add %0, %1, %2"  /* 汇编指令: result = a + b */
        : "=r" (result)   /* 输出: result */
        : "r" (a), "r" (b) /* 输入: a, b */
        :                 /* 没有被修改的寄存器 */
    );

    printf("Result: %d\n", result);
    return 0;
}
```

编译并运行：
```bash
riscv64-unknown-elf-gcc -o inline_asm inline_asm.c
```

### 2. 使用内联汇编实现更复杂的功能

创建 `inline_asm_complex.c` 文件，实现数组求和：
```c
#include <stdio.h>

#define ARRAY_SIZE 10

int main() {
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int sum = 0;

    asm volatile(
        "li t0, 0"                 /* t0 = 0 (索引) */
        "li %0, 0"                 /* sum = 0 */
        "loop:"                    /* 循环开始 */
        "slli t1, t0, 2"           /* t1 = t0 * 4 (字节偏移) */
        "add t2, %1, t1"           /* t2 = &arr[t0] */
        "lw t3, 0(t2)"             /* t3 = arr[t0] */
        "add %0, %0, t3"           /* sum += t3 */
        "addi t0, t0, 1"           /* t0 += 1 */
        "blt t0, %2, loop"         /* 如果t0 < ARRAY_SIZE，跳转到loop */
        : "=r" (sum)               /* 输出: sum */
        : "r" (arr), "i" (ARRAY_SIZE) /* 输入: arr, ARRAY_SIZE */
        : "t0", "t1", "t2", "t3"     /* 被修改的寄存器 */
    );

    printf("Sum: %d\n", sum);
    return 0;
}
```

### 3. C调用汇编函数

创建 `asm_function.s` 文件，实现汇编函数：
```asm
.text
.globl asm_multiply
asm_multiply:
    mul a0, a0, a1  # a0 = a0 * a1
    ret
```

创建 `call_asm.c` 文件，调用汇编函数：
```c
#include <stdio.h>

// 声明汇编函数
extern int asm_multiply(int a, int b);

int main() {
    int a = 5;
    int b = 3;
    int result = asm_multiply(a, b);
    printf("Result: %d\n", result);
    return 0;
}
```

编译并链接：
```bash
riscv64-unknown-elf-as asm_function.s -o asm_function.o
riscv64-unknown-elf-gcc -o call_asm call_asm.c asm_function.o
```

### 4. 汇编调用C函数

创建 `c_function.c` 文件，实现C函数：
```c
#include <stdio.h>

extern void asm_main();

void print_message() {
    printf("Hello from C function!\n");
}

int add(int a, int b) {
    return a + b;
}

int main() {
    asm_main();
    return 0;
}
```

创建 `call_c.s` 文件，调用C函数：
```asm
.text
.globl asm_main
.globl main

asm_main:
    # 调用print_message函数
    jal ra, print_message

    # 调用add函数，计算5+3
    li a0, 5
    li a1, 3
    jal ra, add

    # 调用printf函数，打印结果
    mv a1, a0       # 将结果移动到a1
    la a0, format   # 将格式字符串地址加载到a0
    jal ra, printf

    ret

.data
format: .asciz "5 + 3 = %d\n"
```

编译并链接：
```bash
riscv64-unknown-elf-gcc -c c_function.c -o c_function.o
riscv64-unknown-elf-as call_c.s -o call_c.o
riscv64-unknown-elf-gcc -o call_c call_c.o c_function.o
```

## 实验报告
1. 解释内联汇编的语法和约束符
2. 分析C调用汇编函数和汇编调用C函数的过程
3. 讨论混合编程的优缺点
4. 总结混合编程的最佳实践

## 参考资源
- [GCC Inline Assembly HOWTO](https://gcc.gnu.org/onlinedocs/gcc/Using-Assembly-Language-with-C.html)
