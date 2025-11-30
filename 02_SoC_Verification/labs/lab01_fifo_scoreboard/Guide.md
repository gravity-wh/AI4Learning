# Lab 1 Guide: FIFO Scoreboard with Queues (基于队列的 FIFO 记分板)

## 1. 实验概览 (Lab Overview)
**目标**: 掌握 SystemVerilog 中最常用的数据结构——**队列 (Queue)**。在验证中，队列常被用来模拟 FIFO (First-In-First-Out) 行为，或者作为记分板 (Scoreboard) 来存储期望数据 (Expected Data)。

**场景**: 假设你正在验证一个硬件 FIFO 模块。
*   **Monitor** 抓取到了写入 FIFO 的数据，你需要把它存起来。
*   **Monitor** 抓取到了从 FIFO 读出的数据，你需要把它拿出来，跟存的数据比对。
*   **Scoreboard** 就是这个存储和比对的中心。

**工具**: Vivado Simulator / Questasim / VCS.

---

## 2. 实验前思考 (Pre-Lab Thinking)
*   **Q1**: 为什么用 SV 的 `queue` 而不是定长数组 `array[100]`？
    *   *提示*: 硬件 FIFO 的深度可能是动态配置的，或者我们只关心逻辑上的顺序，不关心物理存储位置。队列支持动态增删，不需要手动管理索引指针。
*   **Q2**: 记分板什么时候会报错？
    *   *提示*: 
        1.  数据不匹配 (Data Mismatch)。
        2.  FIFO 空了但还在读 (Underflow)。
        3.  FIFO 还有数据但仿真结束了 (Dropped Data)。

---

## 3. 实验步骤拆解 (Step-by-Step Guide)

### Step 1: 定义 Scoreboard 类 (The Container)
创建一个 `fifo_scoreboard.sv` 文件。

*   **任务**:
    1.  定义类 `fifo_scoreboard`。
    2.  声明一个 `int` 类型的队列 `scb_queue[$]`。`$` 代表这是一个动态队列。
    3.  定义两个统计变量：`match_count` (匹配数) 和 `error_count` (错误数)。

```systemverilog
class fifo_scoreboard;
    // 队列定义: int类型, 动态大小
    int scb_queue[$];
    
    int match_count = 0;
    int error_count = 0;

    function new();
        // 构造函数
    endfunction
endclass
```

### Step 2: 实现写入方法 (Write Method)
模拟“数据进入 DUT”的过程。

*   **任务**: 编写 `write_data(int data)` 函数。
*   **逻辑**: 将数据推入队列尾部 (`push_back`)。

```systemverilog
    function void write_data(int data);
        scb_queue.push_back(data);
        $display("[SCB] Write data: %0h, Queue size: %0d", data, scb_queue.size());
    endfunction
```

### Step 3: 实现检查方法 (Check Method)
模拟“数据从 DUT 出来”的过程，并进行比对。

*   **任务**: 编写 `check_data(int actual_data)` 函数。
*   **逻辑**:
    1.  检查队列是否为空？如果空了还来数据，报错 (Underflow)。
    2.  从队列头部弹出一个期望数据 (`pop_front`)。
    3.  比对 `expected_data` 和 `actual_data`。
    4.  更新统计计数。

```systemverilog
    function void check_data(int actual_data);
        int expected_data;

        if (scb_queue.size() == 0) begin
            $error("[SCB] Error: FIFO Underflow! Received %0h but queue is empty.", actual_data);
            error_count++;
            return;
        end

        expected_data = scb_queue.pop_front();

        if (expected_data === actual_data) begin
            $display("[SCB] Match! Data: %0h", actual_data);
            match_count++;
        end else begin
            $error("[SCB] Mismatch! Expected: %0h, Received: %0h", expected_data, actual_data);
            error_count++;
        end
    endfunction
```

### Step 4: 搭建测试平台 (The Testbench)
创建 `tb_fifo.sv` 来模拟 Monitor 的行为。

*   **任务**:
    1.  实例化 `fifo_scoreboard`。
    2.  模拟写入序列：写入 0xAA, 0xBB, 0xCC。
    3.  模拟读出序列：
        *   读出 0xAA (应该匹配)。
        *   读出 0xDD (应该报错 - Mismatch)。
        *   读出 0xCC (应该匹配)。
        *   再读一次 (应该报错 - Underflow)。

```systemverilog
module tb_fifo;
    fifo_scoreboard scb;

    initial begin
        scb = new();
        
        $display("--- Start Simulation ---");

        // 1. 模拟写入
        scb.write_data(32'hAA);
        scb.write_data(32'hBB);
        scb.write_data(32'hCC);

        // 2. 模拟读出与检查
        scb.check_data(32'hAA); // Expect Match
        scb.check_data(32'hDD); // Expect Mismatch (Expected BB)
        scb.check_data(32'hCC); // Expect Match
        
        // 3. 模拟 Underflow
        scb.check_data(32'hEE); // Expect Underflow Error

        $display("--- Simulation Finished ---");
        $display("Matches: %0d, Errors: %0d", scb.match_count, scb.error_count);
    end
endmodule
```

---

## 4. 结果验证 (Verification Goals)
运行仿真，你的 Log 应该包含以下关键信息：
1.  **Write**: 看到队列 size 增加到 3。
2.  **Match**: 第一笔 0xAA 成功匹配。
3.  **Mismatch**: 第二笔报错，期望 0xBB 但收到 0xDD。
4.  **Underflow**: 第四次检查时报错，提示队列为空。
5.  **Summary**: 最终统计 Matches=2, Errors=2。

---

## 5. 进阶挑战 (Challenge)
*   **任务**: 给 `fifo_scoreboard` 增加一个 `check_empty()` 函数。
*   **场景**: 在仿真结束 (`final` 块) 调用它。如果队列里还有数据没被读走 (Dropped Data)，报错并打印剩余的数据。
*   **提示**: 使用 `while(scb_queue.size() > 0)` 循环打印。

---

## 6. 常见错误排查 (Troubleshooting)
*   **Error**: `SystemVerilog keyword 'class' is not expected`
    *   *原因*: 编译器版本太老或未开启 SV 支持。确保文件后缀是 `.sv`，或者添加编译选项 `-sv`。
*   **Error**: `Null pointer access`
    *   *原因*: 忘记调用 `scb = new();` 进行实例化。
