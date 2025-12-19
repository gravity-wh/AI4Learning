# Lab 4: 指令选择与代码生成优化

## 实验目标
1. 理解指令选择的基本概念和算法
2. 掌握 GCC 中指令选择的实现机制
3. 学会分析和优化代码生成过程
4. 了解常见的代码生成优化技术

## 实验背景

指令选择是编译器后端的核心任务之一，它负责将中间表示（如 RTL）转换为目标平台的机器指令。高效的指令选择对于生成性能良好的代码至关重要。GCC 使用基于模式匹配的指令选择方法，通过定义指令模式来描述指令的行为和约束。

### 指令选择的基本概念

- **模式匹配**：将中间表示与预定义的指令模式进行匹配
- **指令成本**：衡量指令执行的代价，用于选择最优指令序列
- **树模式**：GCC 中用于描述指令结构的高级表示
- **窥孔优化**：对生成的指令序列进行局部优化

## 实验环境

- 已搭建完成的 GCC/RISC-V 工具链开发环境
- 完整的 GCC 源码树
- 用于分析代码生成的调试工具

## 实验步骤

### 1. 指令选择基础

#### 1.1 理解 GCC 中的指令模式

指令模式是 GCC 指令选择的基础。我们先回顾一下 Lab3 中添加的 `sum4` 指令模式：

```
(define_insn "sum4"
  [(set (match_operand:SI 0 "register_operand" "=r")
        (plus:SI
          (plus:SI
            (plus:SI
              (match_operand:SI 1 "register_operand" "r")
              (match_operand:SI 2 "register_operand" "r"))
            (match_operand:SI 3 "register_operand" "r"))
          (match_operand:SI 4 "register_operand" "r")))
]
"TARGET_XSUM4"
  "sum4\t%0, %1, %2, %3, %4"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")
])
```

这个模式描述了一个四数求和的指令，包含模式匹配部分、条件部分和输出模板部分。

#### 1.2 查看现有指令模式

```bash
# 查看 RISC-V 中 ADD 指令的模式定义
grep -A 10 "define_insn.*add" ~/gcc_riscv_lab/gcc-12.2.0/gcc/riscv.md
```

### 2. 指令选择过程分析

#### 2.1 生成带指令选择信息的输出

使用 `-fdump-rtl-*` 选项可以查看指令选择过程的各个阶段：

```bash
# 创建一个简单的测试程序
cat > test_selector.c << EOF
extern int printf(const char *format, ...);

int main() {
    int a = 1, b = 2, c = 3;
    int sum = a + b + c;
    printf("Sum: %d\n", sum);
    return 0;
}
EOF

# 生成指令选择阶段的输出
riscv64-unknown-elf-gcc -fdump-rtl-expand -fdump-rtl-seqabstr -fdump-rtl-combine -fdump-rtl-sched test_selector.c -o test_selector.elf
```

#### 2.2 分析指令选择过程

查看生成的各个阶段的输出文件：

```bash
ls -la test_selector.c.*rtl*
```

主要阶段包括：
- `expand`: 从 GIMPLE 转换为 RTL
- `seqabstr`: 指令序列抽象化
- `combine`: 指令组合优化
- `sched`: 指令调度

### 3. 指令选择优化

#### 3.1 理解指令成本模型

GCC 使用成本模型来选择最优的指令序列。我们可以通过修改指令的成本属性来影响指令选择过程。

查看现有指令的成本定义：

```bash
grep -A 20 "define_attr.*type" ~/gcc_riscv_lab/gcc-12.2.0/gcc/riscv.md | head -n 50
```

#### 3.2 修改指令成本

我们可以通过修改指令的 `type` 属性或直接设置 `cost` 属性来影响指令选择：

```bash
# 编辑 riscv.md 文件
vim ~/gcc_riscv_lab/gcc-12.2.0/gcc/riscv.md
```

在指令定义中添加或修改成本属性：

```
(define_insn "sum4"
  [(set (match_operand:SI 0 "register_operand" "=r")
        (plus:SI
          (plus:SI
            (plus:SI
              (match_operand:SI 1 "register_operand" "r")
              (match_operand:SI 2 "register_operand" "r"))
            (match_operand:SI 3 "register_operand" "r"))
          (match_operand:SI 4 "register_operand" "r")))
]
"TARGET_XSUM4"
  "sum4\t%0, %1, %2, %3, %4"
  [(set_attr "type" "arith")
   (set_attr "mode" "SI")
   (set_attr "cost" "1")  ; 设置指令成本为 1
])
```

#### 3.3 重新编译 GCC 并测试

```bash
# 进入构建目录
cd ~/gcc_riscv_lab/gcc-12.2.0/build

# 重新编译
make -j$(nproc)
make install

# 测试修改后的指令选择
riscv64-unknown-elf-gcc -mxsum4 -O2 test_sum4.c -o test_sum4.elf
riscv64-unknown-elf-objdump -d test_sum4.elf > test_sum4.asm

# 检查是否优先选择了 sum4 指令
cat test_sum4.asm | grep sum4
```

### 4. 代码生成优化技术

#### 4.1 窥孔优化

窥孔优化是对生成的指令序列进行局部优化的技术。GCC 提供了多种窥孔优化选项：

```bash
# 使用不同的窥孔优化选项编译程序
riscv64-unknown-elf-gcc -O2 -fpeephole -fpeephole2 test_selector.c -o test_selector.elf

# 查看优化后的汇编代码
riscv64-unknown-elf-objdump -d test_selector.elf | less
```

#### 4.2 指令重排序

指令重排序可以提高指令级并行度。我们可以使用 `-fschedule-insns` 和 `-fschedule-insns2` 选项来启用指令调度：

```bash
# 启用指令调度
riscv64-unknown-elf-gcc -O2 -fschedule-insns -fschedule-insns2 test_selector.c -o test_selector.elf

# 查看调度后的指令序列
riscv64-unknown-elf-objdump -d test_selector.elf | less
```

#### 4.3 寄存器分配优化

寄存器分配是代码生成中的关键优化点。GCC 提供了多种寄存器分配策略：

```bash
# 使用不同的寄存器分配策略
riscv64-unknown-elf-gcc -O2 -fira-algorithm=priority test_selector.c -o test_selector.elf
riscv64-unknown-elf-gcc -O2 -fira-algorithm=graph test_selector.c -o test_selector.elf

# 比较生成的代码
riscv64-unknown-elf-objdump -d test_selector.elf | less
```

### 5. 高级指令选择技术

#### 5.1 树模式指令选择

GCC 还支持基于树模式的高级指令选择，这种方法可以在更高层次上进行指令选择：

```bash
# 查看树模式定义
find ~/gcc_riscv_lab/gcc-12.2.0/gcc -name "*tree*md" | head -n 10

# 查看 RISC-V 相关的树模式
cat ~/gcc_riscv_lab/gcc-12.2.0/gcc/config/riscv/riscv.cc | grep -A 5 "tree_pattern"
```

#### 5.2 向量指令选择

对于支持向量扩展的平台，GCC 提供了向量指令选择机制：

```bash
# 查看向量指令模式
grep -A 10 "vector" ~/gcc_riscv_lab/gcc-12.2.0/gcc/riscv.md | head -n 50
```

## 实验内容

1. **指令选择基础**：
   - 理解 GCC 中的指令模式定义
   - 学习指令选择的基本概念和算法

2. **指令选择过程分析**：
   - 生成并分析指令选择各个阶段的输出
   - 理解从 RTL 到机器指令的转换过程

3. **指令选择优化**：
   - 修改指令成本模型
   - 分析成本模型对指令选择的影响

4. **代码生成优化**：
   - 应用各种代码生成优化技术
   - 比较不同优化选项的效果
   - 分析优化后的代码质量

## 实验结果分析

1. **指令选择分析**：
   - 比较不同优化级别下的指令选择结果
   - 分析指令成本模型对指令选择的影响

2. **代码质量分析**：
   - 比较优化前后的代码大小和执行效率
   - 分析各种优化技术的效果

3. **性能分析**：
   - 测量不同优化选项下的程序性能
   - 分析性能差异的原因

## 思考问题

1. 指令选择与代码生成的区别和联系是什么？

2. 为什么需要使用成本模型来指导指令选择？

3. 窥孔优化与全局优化有什么区别？它们各自的优缺点是什么？

4. 指令调度如何提高程序性能？有哪些常见的指令调度算法？

5. 寄存器分配对代码质量有什么影响？有哪些常见的寄存器分配算法？

6. 如何在 GCC 中添加对复杂指令（如条件执行指令）的支持？

## 实验总结

通过本实验，你应该已经掌握了：
1. GCC 中指令选择的基本机制和实现方法
2. 如何分析和优化代码生成过程
3. 常见的代码生成优化技术及其应用
4. 如何通过修改指令模式和成本模型来影响指令选择

这些知识将帮助你理解编译器后端的核心工作原理，为设计和优化编译器后端打下坚实的基础。

## 参考资料

- [GCC Internals Manual - Instruction Selection](https://gcc.gnu.org/onlinedocs/gccint/Instruction-Selection.html)
- [GCC Internals Manual - Peephole Optimization](https://gcc.gnu.org/onlinedocs/gccint/Peephole-Optimization.html)
- [GCC Internals Manual - Instruction Scheduling](https://gcc.gnu.org/onlinedocs/gccint/Instruction-Scheduling.html)
- [GCC Internals Manual - Register Allocation](https://gcc.gnu.org/onlinedocs/gccint/Register-Allocation.html)
- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)
