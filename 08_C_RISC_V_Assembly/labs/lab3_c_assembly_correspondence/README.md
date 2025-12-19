# Lab 3: C与汇编的对应关系

## 实验目的
1. 理解C语言如何被编译为RISC-V汇编代码
2. 掌握RISC-V的函数调用约定
3. 了解栈帧结构
4. 分析不同优化级别对汇编代码的影响

## 实验环境
- RISC-V GCC工具链
- 文本编辑器

## C与汇编的对应关系

### 1. 函数调用约定
- **参数传递**: 前8个整数参数通过a0-a7传递，其余通过栈传递
- **返回值**: 通过a0返回整数，通过fa0返回浮点数
- **调用者保存寄存器**: t0-t6（调用者负责保存）
- **被调用者保存寄存器**: s0-s11（被调用者负责保存）

### 2. 栈帧结构
```
+-------------------+
| 局部变量          |
+-------------------+
| 保存的寄存器       |
+-------------------+
| 返回地址          | <-- ra
+-------------------+
| 参数              |
+-------------------+
| 上一个栈帧指针     | <-- s0/fp
+-------------------+
```

## 实验步骤

### 1. 分析简单函数的汇编代码

创建 `simple.c` 文件：
```c
int add(int a, int b) {
    return a + b;
}

int main() {
    int x = 5;
    int y = 3;
    int z = add(x, y);
    return z;
}
```

生成汇编代码：
```bash
riscv64-unknown-elf-gcc -S -O0 simple.c -o simple.s
```

分析生成的汇编代码，特别是：
- 变量x和y如何存储
- 函数add的调用过程
- 参数如何传递
- 返回值如何处理

### 2. 分析不同优化级别

使用不同的优化级别生成汇编代码：
```bash
# 无优化
riscv64-unknown-elf-gcc -S -O0 simple.c -o simple_O0.s

# O1优化
riscv64-unknown-elf-gcc -S -O1 simple.c -o simple_O1.s

# O2优化
riscv64-unknown-elf-gcc -S -O2 simple.c -o simple_O2.s
```

比较不同优化级别下的汇编代码差异。

### 3. 分析数组和指针操作

创建 `array_ptr.c` 文件：
```c
int sum_array(int *arr, int n) {
    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += arr[i];
    }
    return sum;
}

int main() {
    int arr[] = {1, 2, 3, 4, 5};
    int n = 5;
    int result = sum_array(arr, n);
    return result;
}
```

生成汇编代码并分析：
```bash
riscv64-unknown-elf-gcc -S -O0 array_ptr.c -o array_ptr.s
```

### 4. 分析递归函数

创建 `fibonacci.c` 文件：
```c
int fibonacci(int n) {
    if (n <= 1) {
        return n;
    }
    return fibonacci(n-1) + fibonacci(n-2);
}

int main() {
    int result = fibonacci(5);
    return result;
}
```

生成汇编代码并分析递归调用的栈帧变化。

## 实验报告
1. 分析simple.c生成的汇编代码，解释函数调用和参数传递过程
2. 对比不同优化级别下的汇编代码差异
3. 分析array_ptr.c中的数组访问如何转换为汇编指令
4. 解释fibonacci.c中递归调用的栈帧结构

## 参考资源
- [RISC-V Calling Convention](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)
