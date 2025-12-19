# Lab 4: 汇编优化实践

## 实验目的
1. 了解汇编优化的基本原理
2. 掌握常用的汇编优化技术
3. 学会分析程序性能
4. 能够手动优化汇编代码

## 实验环境
- RISC-V GCC工具链
- 文本编辑器
- 性能分析工具（如perf、gprof）

## 汇编优化技术

### 1. 循环展开
将循环体展开，减少循环控制的开销。

**优化前：**
```asm
loop:
    lw t0, 0(a0)
    add t1, t1, t0
    addi a0, a0, 4
    addi t2, t2, -1
    bnez t2, loop
```

**优化后：**
```asm
loop:
    lw t0, 0(a0)
    lw t1, 4(a0)
    lw t2, 8(a0)
    lw t3, 12(a0)
    add t4, t4, t0
    add t4, t4, t1
    add t4, t4, t2
    add t4, t4, t3
    addi a0, a0, 16
    addi t5, t5, -4
    bnez t5, loop
```

### 2. 指令调度
重排指令顺序，减少流水线停顿。

**优化前：**
```asm
lw t0, 0(a0)     ; 加载数据，可能需要等待
add t1, t0, t2   ; 使用加载的数据，流水线停顿
add t3, t4, t5   ; 独立指令，可提前执行
```

**优化后：**
```asm
lw t0, 0(a0)     ; 加载数据
add t3, t4, t5   ; 执行独立指令，隐藏加载延迟
add t1, t0, t2   ; 使用加载的数据，流水线可能不再停顿
```

### 3. 寄存器分配
减少内存访问，尽量使用寄存器存储临时变量。

### 4. 消除冗余计算
避免重复计算相同的值。

## 实验步骤

### 1. 分析未优化的程序

创建 `unoptimized.c` 文件：
```c
int sum(int *arr, int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        total += arr[i];
    }
    return total;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int n = 10;
    int result = sum(arr, n);
    return result;
}
```

生成未优化的汇编代码：
```bash
riscv64-unknown-elf-gcc -S -O0 unoptimized.c -o unoptimized.s
```

### 2. 分析编译器优化的代码

使用不同优化级别生成汇编代码：
```bash
# O1优化
riscv64-unknown-elf-gcc -S -O1 unoptimized.c -o optimized_O1.s

# O2优化
riscv64-unknown-elf-gcc -S -O2 unoptimized.c -o optimized_O2.s

# O3优化
riscv64-unknown-elf-gcc -S -O3 unoptimized.c -o optimized_O3.s
```

比较不同优化级别下的汇编代码差异，特别是：
- 循环是否被展开
- 寄存器使用是否更高效
- 是否有冗余指令被消除

### 3. 手动优化汇编代码

基于编译器生成的优化代码，手动进一步优化：

创建 `manual_optimized.s` 文件：
```asm
.text
.globl main
main:
    # 初始化数组（假设在内存中）
    la a0, array      # 数组地址
    li a1, 10         # 数组大小
    jal ra, sum       # 调用sum函数
    ret

sum:
    li t0, 0          # 累加结果
    li t1, 0          # 计数器
loop:
    bge t1, a1, done  # 如果计数器 >= 数组大小，结束循环
    slli t2, t1, 2    # t2 = i * 4（字节偏移）
    add t3, a0, t2    # t3 = &arr[i]
    lw t4, 0(t3)      # t4 = arr[i]
    add t0, t0, t4    # 累加
    addi t1, t1, 1    # 计数器+1
    j loop

done:
    mv a0, t0         # 返回结果
    ret

.data
array: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
```

### 4. 性能测试

编译并运行优化前后的程序，比较性能差异：
```bash
# 编译所有版本
riscv64-unknown-elf-gcc -O0 unoptimized.c -o unoptimized
riscv64-unknown-elf-gcc -O2 unoptimized.c -o optimized
riscv64-unknown-elf-as manual_optimized.s -o manual_optimized.o
riscv64-unknown-elf-ld manual_optimized.o -o manual_optimized

# 性能测试
perf stat ./unoptimized
perf stat ./optimized
perf stat ./manual_optimized
```

## 实验报告
1. 分析编译器在不同优化级别下生成的汇编代码
2. 解释循环展开、指令调度等优化技术的原理
3. 比较优化前后程序的性能差异
4. 总结汇编优化的经验和技巧

## 参考资源
- [RISC-V性能优化指南](https://riscv.org/wp-content/uploads/2017/05/riscv-isa-privileged-v1.10.pdf)
- [计算机体系结构：量化研究方法](https://www.amazon.com/Computer-Architecture-Quantitative-Approach-6th/dp/0128119055)
