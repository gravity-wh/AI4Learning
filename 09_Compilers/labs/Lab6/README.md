# Lab 6: 综合项目 - 完整自定义指令集支持

## 实验目标
1. 设计一个完整的自定义 RISC-V 指令集扩展
2. 实现 GCC 后端对自定义指令集的完整支持
3. 添加汇编器和链接器对自定义指令的支持
4. 实现自定义指令的模拟器或硬件验证
5. 进行性能测试和分析，评估自定义指令的效果

## 实验背景

在前面的实验中，我们已经学习了如何在 GCC 后端添加简单的自定义指令。本实验将综合运用这些知识，设计并实现一个完整的自定义指令集扩展。我们将设计一组用于加速矩阵运算的自定义指令，并完成从编译器后端到模拟器的完整支持链。

### 自定义指令集扩展设计

我们将设计一个名为 `Xmat` 的矩阵运算扩展，包含以下指令：

1. **matmul2x2**: 2x2 矩阵乘法
2. **matadd2x2**: 2x2 矩阵加法
3. **vecmul4**: 4 元素向量乘法
4. **vecadd4**: 4 元素向量加法
5. **vecdot4**: 4 元素向量点积

这些指令将显著加速嵌入式系统中的矩阵和向量运算，特别是在机器学习和信号处理领域。

## 实验环境

- 已搭建完成的 GCC/RISC-V 工具链开发环境
- RISC-V 汇编器和链接器（binutils）源码
- RISC-V 模拟器（如 QEMU 或 Spike）
- 性能测试工具

## 实验步骤

### 1. 自定义指令集扩展设计

#### 1.1 定义指令格式和功能

| 指令名 | 格式 | 功能描述 |
|--------|------|----------|
| matmul2x2 | matmul2x2 rd, rs1, rs2 | rd = rs1 × rs2 (2x2 矩阵乘法) |
| matadd2x2 | matadd2x2 rd, rs1, rs2 | rd = rs1 + rs2 (2x2 矩阵加法) |
| vecmul4 | vecmul4 rd, rs1, rs2 | rd[i] = rs1[i] × rs2[i], i=0-3 |
| vecadd4 | vecadd4 rd, rs1, rs2 | rd[i] = rs1[i] + rs2[i], i=0-3 |
| vecdot4 | vecdot4 rd, rs1, rs2 | rd = Σ(rs1[i] × rs2[i]), i=0-3 |

#### 1.2 定义指令编码

使用 RISC-V 的自定义指令编码格式：

```
|31-25|24-20|19-15|14-12|11-7|6-0|
| funct7 | rs2 | rs1 | funct3 | rd | opcode |
```

为 `Xmat` 扩展分配的编码空间：
- opcode: 0110011 (R-type)
- funct3: 自定义值 (000-111)
- funct7: 0x40 (用于标识 Xmat 扩展)

具体编码：
- matmul2x2: funct3=000, funct7=0x40
- matadd2x2: funct3=001, funct7=0x40
- vecmul4: funct3=010, funct7=0x40
- vecadd4: funct3=011, funct7=0x40
- vecdot4: funct3=100, funct7=0x40

### 2. GCC 后端实现

#### 2.1 修改 GCC 后端文件

1. **修改 riscv.md**：添加自定义指令的模式定义
2. **修改 riscv.opt**：添加 `-mxmat` 命令行选项
3. **修改 riscv.h**：添加目标宏定义
4. **修改 riscv-subtarget.c**：添加子目标支持

#### 2.2 实现指令模式

以 `matmul2x2` 为例，在 `riscv.md` 中添加以下定义：

```
;; 自定义指令: matmul2x2
(define_insn "matmul2x2"
  [(set (match_operand:DI 0 "register_operand" "=r")
        (mult:DI
          (match_operand:DI 1 "register_operand" "r")
          (match_operand:DI 2 "register_operand" "r")))
]
"TARGET_XMAT"
  "matmul2x2\t%0, %1, %2"
  [(set_attr "type" "matmul")
   (set_attr "mode" "DI")
   (set_attr "cost" "2")
])
```

为其他指令添加类似的定义。

#### 2.3 添加指令识别和优化

为了让 GCC 能够自动识别并使用自定义指令，我们需要添加模式匹配规则：

```
;; 识别 2x2 矩阵乘法的模式
(define_peephole2
  [(set (match_operand:SI 0 "register_operand")
        (plus:SI
          (mult:SI (match_operand:SI 1 "register_operand")
                   (match_operand:SI 2 "register_operand"))
          (mult:SI (match_operand:SI 3 "register_operand")
                   (match_operand:SI 4 "register_operand"))))
   (set (match_operand:SI 5 "register_operand")
        (plus:SI
          (mult:SI (match_dup 1)
                   (match_operand:SI 6 "register_operand"))
          (mult:SI (match_dup 3)
                   (match_operand:SI 7 "register_operand"))))
   (set (match_operand:SI 8 "register_operand")
        (plus:SI
          (mult:SI (match_operand:SI 9 "register_operand")
                   (match_dup 2))
          (mult:SI (match_operand:SI 10 "register_operand")
                   (match_dup 4))))
   (set (match_operand:SI 11 "register_operand")
        (plus:SI
          (mult:SI (match_dup 9)
                   (match_dup 6))
          (mult:SI (match_dup 10)
                   (match_dup 7))))
]
"TARGET_XMAT"
  [(set (match_dup 0)
        (unspec:SI [(match_dup 1)
                    (match_dup 3)
                    (match_dup 9)
                    (match_dup 10)
                    (match_dup 2)
                    (match_dup 6)
                    (match_dup 4)
                    (match_dup 7)]
                   UNSPEC_MATMUL2X2))]
  "")
```

#### 2.4 重新编译 GCC

```bash
# 进入构建目录
cd ~/gcc_riscv_lab/gcc-12.2.0/build

# 重新编译
make -j$(nproc)
make install
```

### 3. 汇编器和链接器支持

#### 3.1 下载并编译 binutils

```bash
# 下载 binutils 源码
cd ~/gcc_riscv_lab
wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.gz
tar -xf binutils-2.40.tar.gz
cd binutils-2.40

# 配置并编译
mkdir -p build && cd build
../configure --target=riscv64-unknown-elf --prefix=$HOME/riscv-custom
make -j$(nproc)
make install
```

#### 3.2 添加自定义指令到汇编器

编辑 binutils 中的 RISC-V 汇编器文件：

```bash
# 备份原始文件
cp ~/gcc_riscv_lab/binutils-2.40/opcodes/riscv-opc.c ~/gcc_riscv_lab/binutils-2.40/opcodes/riscv-opc.c.bak

# 编辑 riscv-opc.c 文件
vim ~/gcc_riscv_lab/binutils-2.40/opcodes/riscv-opc.c
```

在文件中添加自定义指令的定义：

```c
// 自定义矩阵指令 (Xmat 扩展)
{ "matmul2x2", 0, INSN_CLASS_I, "d,r,r", MATCH_MATMUL2X2, MASK_MATMUL2X2, match_opcode, 0 },
{ "matadd2x2", 0, INSN_CLASS_I, "d,r,r", MATCH_MATADD2X2, MASK_MATADD2X2, match_opcode, 0 },
{ "vecmul4",   0, INSN_CLASS_I, "d,r,r", MATCH_VECMUL4,   MASK_VECMUL4,   match_opcode, 0 },
{ "vecadd4",   0, INSN_CLASS_I, "d,r,r", MATCH_VECADD4,   MASK_VECADD4,   match_opcode, 0 },
{ "vecdot4",   0, INSN_CLASS_I, "d,r,r", MATCH_VECDOT4,   MASK_VECDOT4,   match_opcode, 0 },
```

同时需要在 `riscv-opc.h` 中添加对应的宏定义：

```c
// 自定义矩阵指令 (Xmat 扩展)
#define MATCH_MATMUL2X2 0x40000033
#define MASK_MATMUL2X2  0xfe00707f
#define MATCH_MATADD2X2 0x40100033
#define MASK_MATADD2X2  0xfe00707f
#define MATCH_VECMUL4   0x40200033
#define MASK_VECMUL4    0xfe00707f
#define MATCH_VECADD4   0x40300033
#define MASK_VECADD4    0xfe00707f
#define MATCH_VECDOT4   0x40400033
#define MASK_VECDOT4    0xfe00707f
```

#### 3.3 重新编译 binutils

```bash
# 进入构建目录
cd ~/gcc_riscv_lab/binutils-2.40/build

# 重新编译
make -j$(nproc)
make install
```

### 4. 模拟器支持

#### 4.1 修改 QEMU 以支持自定义指令

下载 QEMU 源码并修改：

```bash
# 下载 QEMU 源码
cd ~/gcc_riscv_lab
git clone https://github.com/qemu/qemu.git
cd qemu

# 配置并编译
mkdir -p build && cd build
../configure --target-list=riscv64-softmmu --prefix=$HOME/riscv-custom
make -j$(nproc)
make install
```

编辑 QEMU 中的 RISC-V 指令处理文件：

```bash
# 编辑指令处理文件
vim ~/gcc_riscv_lab/qemu/target/riscv/insn_trans/trans_rvi.c
```

在文件中添加自定义指令的处理逻辑：

```c
// 处理 matmul2x2 指令
trans_func(matmul2x2) {
    // 实现 2x2 矩阵乘法的模拟器逻辑
    // ...
    return gen_nop();
}

// 为其他指令添加类似的处理函数
```

#### 4.2 或者使用 Spike 模拟器

Spike 是 RISC-V 官方的指令集模拟器，它提供了更灵活的扩展机制：

```bash
# 下载 Spike 源码
cd ~/gcc_riscv_lab
git clone https://github.com/riscv-software-src/riscv-isa-sim.git
cd riscv-isa-sim

# 编译 Spike
mkdir -p build && cd build
../configure --prefix=$HOME/riscv-custom
make -j$(nproc)
make install
```

为 Spike 添加自定义指令支持：

```bash
# 编辑 Spike 指令集定义
vim ~/gcc_riscv_lab/riscv-isa-sim/riscv/encoding.h

# 添加自定义指令的编码定义
#define MATCH_MATMUL2X2 0x40000033
#define MASK_MATMUL2X2  0xfe00707f

# 编辑指令处理文件
vim ~/gcc_riscv_lab/riscv-isa-sim/riscv/decode.c

# 添加自定义指令的解码逻辑
case MATCH_MATMUL2X2:
    return new Matmul2x2Instruction();
```

### 5. 测试与验证

#### 5.1 创建测试程序

```c
#include <stdio.h>

// 矩阵乘法测试
void test_matmul() {
    // 定义两个 2x2 矩阵
    int a[4] = {1, 2, 3, 4};  // 矩阵 A
    int b[4] = {5, 6, 7, 8};  // 矩阵 B
    int c[4];                 // 结果矩阵 C

    // 使用普通方法计算矩阵乘法
    c[0] = a[0] * b[0] + a[1] * b[2];
    c[1] = a[0] * b[1] + a[1] * b[3];
    c[2] = a[2] * b[0] + a[3] * b[2];
    c[3] = a[2] * b[1] + a[3] * b[3];

    printf("Normal matrix multiplication result:\n");
    printf("%d %d\n", c[0], c[1]);
    printf("%d %d\n", c[2], c[3]);

    // 使用自定义指令计算矩阵乘法
    // 注意：这里需要使用内联汇编或编译器自动识别
    // ...
}

int main() {
    test_matmul();
    // 添加其他测试函数
    return 0;
}
```

#### 5.2 编译并测试

```bash
# 编译测试程序
riscv64-unknown-elf-gcc -mxmat -O2 test_matrix.c -o test_matrix.elf

# 检查生成的汇编代码
riscv64-unknown-elf-objdump -d test_matrix.elf | grep matmul2x2

# 在模拟器中运行
spike --extension=mat test_matrix.elf
```

### 6. 性能测试与分析

#### 6.1 编写性能测试程序

```c
#include <time.h>
#include <stdio.h>

#define ITERATIONS 1000000

// 矩阵乘法性能测试
void benchmark_matmul() {
    int a[4] = {1, 2, 3, 4};
    int b[4] = {5, 6, 7, 8};
    int c[4];
    
    clock_t start = clock();
    
    for (int i = 0; i < ITERATIONS; i++) {
        // 使用普通方法
        c[0] = a[0] * b[0] + a[1] * b[2];
        c[1] = a[0] * b[1] + a[1] * b[3];
        c[2] = a[2] * b[0] + a[3] * b[2];
        c[3] = a[2] * b[1] + a[3] * b[3];
    }
    
    clock_t end = clock();
    double time_normal = (double)(end - start) / CLOCKS_PER_SEC;
    
    printf("Normal matrix multiplication: %f seconds\n", time_normal);
    
    // 使用自定义指令的性能测试
    // ...
}

int main() {
    benchmark_matmul();
    return 0;
}
```

#### 6.2 分析性能结果

比较使用自定义指令和普通指令的性能差异，分析加速比和效率提升：

```bash
# 编译两个版本的测试程序
riscv64-unknown-elf-gcc -O2 benchmark.c -o benchmark_normal.elf
riscv64-unknown-elf-gcc -mxmat -O2 benchmark.c -o benchmark_custom.elf

# 运行性能测试
spike benchmark_normal.elf
spike --extension=mat benchmark_custom.elf
```

## 实验内容

1. **自定义指令集扩展设计**：
   - 定义指令格式、功能和编码
   - 设计指令的操作数和结果格式

2. **GCC 后端实现**：
   - 修改 GCC 后端文件添加指令支持
   - 实现指令模式和优化规则
   - 重新编译和安装 GCC

3. **汇编器和链接器支持**：
   - 修改 binutils 添加指令定义
   - 重新编译和安装 binutils

4. **模拟器支持**：
   - 修改 QEMU 或 Spike 添加指令处理逻辑
   - 重新编译和安装模拟器

5. **测试与验证**：
   - 创建测试程序验证指令功能
   - 检查生成的汇编代码
   - 在模拟器中运行测试程序

6. **性能测试与分析**：
   - 编写性能基准测试程序
   - 比较自定义指令和普通指令的性能
   - 分析性能提升和效率

## 实验结果分析

1. **功能验证**：
   - 确认自定义指令能够正确生成
   - 验证指令的功能是否符合预期

2. **性能分析**：
   - 计算自定义指令的加速比
   - 分析性能提升的原因
   - 评估指令集扩展的效果

3. **代码质量分析**：
   - 检查生成的汇编代码质量
   - 分析指令选择和优化的效果

## 思考问题

1. 设计自定义指令集时需要考虑哪些因素？

2. 如何平衡指令集的复杂性和性能提升？

3. 自定义指令集扩展对编译器、汇编器、链接器和模拟器有什么影响？

4. 如何确保自定义指令在不同的优化级别下都能正确生成？

5. 性能测试中可能存在哪些误差来源？如何减少这些误差？

6. 如何将自定义指令集扩展应用到实际的嵌入式系统中？

## 实验总结

通过本实验，你应该已经掌握了：
1. 完整的自定义指令集扩展设计流程
2. GCC 后端、汇编器和链接器的修改方法
3. 模拟器扩展和指令处理逻辑实现
4. 性能测试和分析方法

这个综合项目展示了从指令设计到实际应用的完整流程，为你在实际项目中设计和实现自定义指令集扩展提供了宝贵的经验。

## 参考资料

- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/)
- [GCC Internals Manual](https://gcc.gnu.org/onlinedocs/gccint/)
- [Binutils Documentation](https://sourceware.org/binutils/docs/)
- [QEMU Documentation](https://www.qemu.org/docs/)
- [Spike Simulator Documentation](https://github.com/riscv-software-src/riscv-isa-sim)
- [RISC-V Custom Extensions Guide](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)
