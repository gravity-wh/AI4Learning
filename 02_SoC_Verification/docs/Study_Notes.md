# 学习笔记：System-on-Chip Verification (SoC 验证方法学)

这份文档用于记录《SoC Verification》课程的学习心得、核心概念整理、实验记录以及待解决的问题。

---

## Phase 1: SystemVerilog 语言进阶 (SV Fundamentals)

### 1.1 数据类型与过程块 (Data Types & Procedural Blocks)
*   **Logic vs Wire**:
    *   *思考*: 为什么 SV 引入 `logic`？在什么情况下必须用 `wire`？(提示: 多驱动)
    *   *笔记*:
        1.  **4态逻辑 (4-State Logic)**:
            *   `0`: 逻辑低电平 (GND)。
            *   `1`: 逻辑高电平 (VCC)。
            *   `X`: 未知状态 (Unknown)。通常由未初始化的寄存器、多驱动冲突或时序违例产生。
            *   `Z`: 高阻态 (High Impedance)。表示线路断开或未被驱动，常见于三态门总线。
        2.  **Logic (SV 新特性)**:
            *   **定义**: `logic` 是 SystemVerilog 引入的单一数据类型，旨在统一 Verilog 中的 `reg` 和 `wire`。
            *   **用法**: 在过程块 (`always`, `initial`) 中被赋值时，它表现得像 `reg`；在连续赋值 (`assign`) 中被赋值时，它表现得像 `wire`。
            *   **限制**: `logic` **只能有一个驱动源**。如果你试图在两个不同的 `always` 块中驱动同一个 `logic` 变量，编译器会报错。
        3.  **Wire (Verilog 遗产)**:
            *   **定义**: `wire` 是真正的“导线”。
            *   **核心能力**: **多驱动解析 (Multiple Driver Resolution)**。
            *   **场景**: 当你需要设计双向总线 (如 I2C 的 SDA 线) 或三态总线时，**必须**使用 `wire`。
            *   **解析函数**: 当多个驱动源同时驱动 `wire` 时 (例如一个驱动 `1`，一个驱动 `0`)，结果由解析函数决定 (通常是 `X`)。而 `logic` 会直接报错，这反而是一种保护机制，防止意外的多驱动。
*   **过程块 (Procedural Blocks)**:
    *   *最佳实践*: `always_comb`, `always_ff`, `always_latch` vs `always`。
    *   *笔记*:
        *   **组合逻辑 (`always_comb`)**:
            ```systemverilog
            // 自动推断敏感列表 (无需手动写 @(a, b, sel))
            // 严查 latch 生成 (如果分支不全，编译器会警告)
            always_comb begin
                if (sel) 
                    y = a;
                else 
                    y = b;
            end
            ```
        *   **时序逻辑 (`always_ff`)**:
            ```systemverilog
            // 明确表示这是触发器逻辑
            // 必须带时钟沿敏感列表
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n)
                    q <= '0;
                else
                    q <= d;
            end
            ```
        *   **为什么不用老式 `always`?**: 老式 `always @(*)` 或 `always @(posedge clk)` 语义模糊。SV 的新关键字明确了**设计意图 (Design Intent)**，让仿真器和综合器能更好地帮你检查错误（例如在 `always_ff` 里写了组合逻辑，或者 `always_comb` 产生了 latch）。
*   **数组与队列**:
    *   *场景*: 什么时候用 `queue` (FIFO)，什么时候用 `associative array` (稀疏存储/记分板)？
    *   *笔记*:

### 1.2 面向对象编程 (OOP Fundamentals)
*   **Class vs Module**:
    *   *核心区别*: 静态 (编译时分配) vs 动态 (运行时分配)。这对验证平台的灵活性意味着什么？
    *   *笔记*:
*   **深拷贝 vs 浅拷贝**:
    *   *陷阱*: 如果类中包含另一个类的句柄，直接 `new` 复制会发生什么？
    *   *笔记*:

### 1.3 随机化与约束 (Randomization)
*   **约束技巧**:
    *   *思考*: 如何用 `solve...before` 解决分布不均的问题？
    *   *笔记*:
*   **Randc**:
    *   *机制*: `randc` 是如何保证遍历所有值之前不重复的？它对仿真性能有何影响？

### 1.4 线程与通信 (IPC)
*   **Fork...Join**:
    *   *陷阱*: 在循环中使用 `fork...join_none` 时，循环变量的自动捕获问题 (automatic variable)。
    *   *笔记*:
*   **Mailbox vs Queue**:
    *   *选择*: 为什么组件间通信首选 Mailbox 而不是 Queue？(提示: 阻塞/非阻塞特性)

---

## Phase 2: 验证方法学核心 (Methodology Core)

### 2.1 分层验证平台 (Layered Testbench)
*   **组件角色**:
    *   *Driver*: 为什么 Driver 只负责“翻译”事务，而不负责产生数据？
    *   *Monitor*: Monitor 如何做到“被动”采样？它能驱动总线吗？
    *   *Scoreboard*: 记分板如何处理乱序 (Out-of-order) 事务？
*   **Interface**:
    *   *Virtual Interface*: 为什么 Class 不能直接包含 Interface？(提示: 静态与动态世界的桥梁)

### 2.2 功能覆盖率 (Functional Coverage)
*   **Code vs Functional**:
    *   *思考*: 代码覆盖率 100% 了，功能覆盖率只有 50%，说明了什么？反之呢？
    *   *笔记*:
*   **Covergroup 策略**:
    *   *Cross Coverage*: 什么时候需要交叉覆盖？(例如: 读写操作 x 地址范围)
    *   *Bins*: 如何处理非法值 (Illegal bins) 和忽略值 (Ignore bins)？

### 2.3 SystemVerilog 断言 (SVA)
*   **Immediate vs Concurrent**:
    *   *应用*: 组合逻辑检查用哪个？时序协议检查用哪个？
    *   *笔记*:
*   **Sequence**:
    *   *思考*: 如何写一个断言来检查 "Req 拉高后，Ack 必须在 3~5 个周期内拉高"？

---

## Phase 3: UVM 实战 (UVM Practice)

### 3.1 UVM 基础机制 (UVM Basics)
*   **Factory 机制**:
    *   *核心价值*: 为什么不直接 `new()` 对象，而要用 `type_id::create()`？(提示: Override)
    *   *笔记*:
*   **Phase 机制**:
    *   *思考*: 为什么 `build_phase` 是自顶向下，而 `connect_phase` 是自底向上？
    *   *Objection*: 如何控制仿真的结束？(`raise_objection` / `drop_objection`)

### 3.2 UVM 通信 (TLM)
*   **Port vs Export**:
    *   *理解*: 谁发起连接？谁提供实现？
    *   *Analysis Port*: 为什么 Monitor 到 Scoreboard 通常用 Analysis Port？(广播特性)

### 3.3 UVM 序列 (Sequences)
*   **Sequencer-Driver 握手**:
    *   *流程*: `get_next_item` -> `item_done` 的交互时序是怎样的？
    *   *笔记*:
*   **Virtual Sequence**:
    *   *作用*: 如何协调多个 Agent (例如 CPU 接口和 DMA 接口) 同时工作？

### 3.4 寄存器模型 (UVM RAL)
*   **前门 vs 后门访问**:
    *   *对比*: 前门走总线协议 (耗时)，后门走仿真器路径 (零耗时)。什么时候用哪个？
    *   *笔记*:
*   **预测机制 (Prediction)**:
    *   *Auto Predict*: 寄存器模型如何知道 DUT 内部的值变了？

---

## 课程项目记录 (Project: DMA Controller)

### 4.1 验证计划 (Verification Plan)
*   [ ] **Feature 1**: 单通道数据搬运 (Sanity Test)
*   [ ] **Feature 2**: 4通道轮询仲裁 (Round-Robin)
*   [ ] **Feature 3**: 寄存器读写 (RW, RO, W1C)
*   [ ] **Feature 4**: 中断触发逻辑

### 4.2 遇到的问题与解决方案 (Troubleshooting)
*   *Issue 1*: APB Driver 时序不满足协议要求。
    *   *Fix*: 使用 Clocking Block 消除竞争。
*   *Issue 2*: Scoreboard 无法匹配乱序数据。
    *   *Fix*: 使用 Associative Array 以地址为 Key 进行存储。

### 4.3 深度思考 (Deep Dive)
1.  **Q**: 在 UVM 中，如何处理复位 (Reset)？如果仿真过程中突然复位，Testbench 应该怎么反应？
    *   **A**: (待补充... `reset_phase`? `handle_reset`?)
2.  **Q**: 如何验证一个“死锁”场景？(即证明设计在某些情况下**不会**死锁)
    *   **A**: (待补充... Formal Verification?)
