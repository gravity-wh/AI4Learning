# Lab 3 Guide: Randomization & Constraints (随机化与约束)

## 1. 实验概览 (Lab Overview)
**目标**: 掌握 SystemVerilog 的受约束随机验证 (Constrained Random Verification, CRV) 技术。你将不再手动编写每一个测试向量，而是教会计算机如何生成合法的、有趣的测试场景。

**被测对象 (DUT)**: 一个简单的 ALU (算术逻辑单元)。
*   输入: `op_a` (8-bit), `op_b` (8-bit), `opcode` (2-bit).
*   功能: 00:ADD, 01:SUB, 10:AND, 11:OR.

**工具**: Vivado Simulator / Questasim / VCS.

---

## 2. 实验前思考 (Pre-Lab Thinking)
在开始写代码之前，请思考以下问题：
*   **Q1**: 为什么要随机化？完全随机 (Pure Random) 有什么问题？
    *   *提示*: 如果 `opcode` 完全随机，覆盖到所有 4 种操作的概率是多少？如果 `opcode` 是 32-bit 呢？
*   **Q2**: 什么是“合法”的激励？
    *   *提示*: 对于减法 `a - b`，如果设计不支持负数输出，那么 `a` 和 `b` 需要满足什么关系？
*   **Q3**: 如何验证随机化是否成功？
    *   *提示*: 仅仅打印出来看一眼够吗？如果跑 10000 次呢？

---

## 3. 实验步骤拆解 (Step-by-Step Guide)

### Step 1: 定义 Transaction 类 (The Blueprint)
创建一个 `alu_trans.sv` 文件。这是你的数据包蓝图。

*   **任务**:
    1.  定义类 `alu_trans`。
    2.  声明随机变量 `rand bit [7:0] op_a, op_b;` 和 `rand bit [1:0] opcode;`。
    3.  编写 `display()` 函数用于打印当前值。

```systemverilog
class alu_trans;
    rand bit [7:0] op_a;
    rand bit [7:0] op_b;
    rand bit [1:0] opcode;

    function void display(string prefix="");
        $display("[%s] Time=%0t Op=%0d A=%0d B=%0d", prefix, $time, opcode, op_a, op_b);
    endfunction
endclass
```

### Step 2: 添加约束 (Adding Rules)
在类中添加约束块。

*   **任务**:
    1.  **基础约束**: 限制 `op_a` 必须大于 10。
    2.  **分布约束**: 让 `opcode` 中 ADD(0) 出现的概率是其他操作的 2 倍。
    3.  **关系约束**: 当 `opcode` 为 SUB(1) 时，要求 `op_a >= op_b`。

```systemverilog
    constraint c_basic {
        op_a > 10;
    }
    
    constraint c_dist {
        opcode dist { 0 := 40, [1:3] := 20 }; // 0权重40, 1-3各权重20
    }

    constraint c_relation {
        (opcode == 1) -> (op_a >= op_b);
    }
```

### Step 3: 搭建测试平台 (The Testbench)
创建 `tb_top.sv`。

*   **任务**:
    1.  实例化 `alu_trans` 对象。
    2.  在 `initial` 块中循环调用 `randomize()`。
    3.  **关键**: 检查 `randomize()` 的返回值！如果失败必须报错。

```systemverilog
module tb_top;
    alu_trans tr;

    initial begin
        tr = new();
        repeat(20) begin
            if (!tr.randomize()) 
                $fatal("Randomization failed!");
            tr.display("RAND");
        end
    end
endmodule
```

### Step 4: 内嵌约束测试 (Inline Constraint)
在 `tb_top.sv` 中尝试使用 `randomize() with {}`。

*   **任务**: 强制产生一个 Corner Case，例如 `op_a` 必须是最大值 255，且 `opcode` 必须是 AND。

```systemverilog
        // 强制产生 Corner Case
        if (!tr.randomize() with { op_a == 255; opcode == 2; })
            $error("Inline constraint failed!");
        else
            tr.display("CORNER");
```

---

## 4. 结果验证与分析 (Verification Goals)

运行仿真，观察输出日志：
1.  **分布检查**: 统计 20 次输出中，Opcode 0 出现了几次？是否接近 40% 的概率？
2.  **约束检查**: 检查所有的 SUB 操作，是否都满足 A >= B？
3.  **Corner Case**: 最后的内嵌约束是否成功生成了 A=255 的包？

---

## 5. 进阶挑战 (Challenge)
*   **任务**: 修改约束，使得 `op_a` 永远是偶数，`op_b` 永远是奇数。
*   **思考**: 有几种写法？(提示: 使用 `%` 操作符，或者位操作 `op_a[0] == 0`)。

---

## 6. 常见错误排查 (Troubleshooting)
*   **Error**: `Constraint solver failed`
    *   *原因*: 约束冲突。例如你约束 `a > 10` 同时又在 inline constraint 中写 `a == 5`。
*   **Error**: 变量没有随机化 (一直是 0)
    *   *原因*: 忘记加 `rand` 关键字。
