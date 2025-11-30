# 学习笔记：Advanced Digital IC (高级数字集成电路)

这份文档用于记录《Advanced Digital IC》课程的学习心得、核心概念整理、实验记录以及待解决的问题。

---

## Module 1: 深入 MOS 模型与逻辑努力 (MOS Models & Logical Effort)

### 1.1 核心概念速查
*   **MOSFET 寄生参数**:
    *   *电容*: $C_{gs}, C_{gd}, C_{db}, C_{sb}$。为什么 $C_{gd}$ 会因为米勒效应 (Miller Effect) 被放大？
    *   *电阻*: 沟道电阻 $R_{on}$ 与宽长比 $W/L$ 的关系。
*   **逻辑努力 (Logical Effort)**:
    *   *定义*: 门延迟 $d = g \cdot h + p$ (逻辑努力 $\times$ 电气努力 + 寄生延迟)。
    *   *核心公式*: 路径最小延迟 $D_{min} = N \cdot F^{1/N} + P$。
    *   *应用*: 如何确定反相器链的最佳级数？(答案：每级放大倍数约为 4)。
    *   **推导详解 (Why 4?)**:
        1.  **场景**: 假设要驱动一个巨大的负载电容 $C_{load}$，输入电容为 $C_{in}$。总电气努力 $H = C_{load}/C_{in}$。
        2.  **级联**: 我们插入 $N$ 级反相器。每级的电气努力为 $f = h = \sqrt[N]{H}$ (假设每级放大倍数相同)。
        3.  **总延迟**: $D = N \cdot (g \cdot f + p)$。对于反相器，$g=1$，$p_{inv} \approx 1$ (归一化)。所以 $D = N(f + 1) = N(\sqrt[N]{H} + 1)$。
        4.  **求极值**: 对 $N$ 求导 $\frac{\partial D}{\partial N} = 0$。
            *   令 $f = H^{1/N}$，则 $N = \ln H / \ln f$。
            *   代入得 $D = \frac{\ln H}{\ln f} (f + 1)$。
            *   对 $f$ 求导，令其为 0，得到方程 $f(\ln f - 1) = 1$。
        5.  **解方程**: 解得 $f \approx 3.59$。
        6.  **结论**: 在考虑寄生延迟 $p$ 后，工程上通常取 **$f=4$** (即 FO4, Fan-out of 4) 作为最佳级间放大倍数。这意味着每级尺寸是前一级的 4 倍时，总延迟最小。
    *   **公式物理意义 (Physical Meaning)**:
        *   **源头**: 归一化的 RC 延迟模型。
        *   **基准**: 定义最小尺寸反相器的延迟为 $\tau = R_{inv} C_{inv}$ (无寄生)。
        *   **推导**: 任意门的延迟 $D = R_{drive} (C_{load} + C_{parasitic})$。
        *   **归一化**: $d = \frac{D}{\tau} = \frac{R_{drive} C_{load}}{R_{inv} C_{inv}} + \frac{R_{drive} C_{parasitic}}{R_{inv} C_{inv}}$。
        *   **公式重写 (Decomposition)**:
            $$ d = \underbrace{\left( \frac{R_{drive} C_{in}}{\tau} \right)}_{\text{门拓扑系数 } g} \cdot \underbrace{\left( \frac{C_{load}}{C_{in}} \right)}_{\text{外部负载比 } h} + \underbrace{\left( \frac{R_{drive} C_{parasitic}}{\tau} \right)}_{\text{自身寄生 } p} $$
            这个公式直观地展示了延迟的三个来源：
            1.  **门拓扑系数 (g)**: 由门的电路结构决定（如 NAND 串联了电阻，导致 RC 乘积变大）。
            2.  **外部负载比 (h)**: 纯粹由外部负载电容和自身输入电容的比例决定（扇出）。
            3.  **自身寄生 (p)**: 门自身的漏极电容带来的固有延迟，与负载无关。
*   **互连线 (Interconnect)**:
    *   *Elmore Delay*: RC 链的延迟估算公式 $\tau = \sum R_i C_{downstream}$。
    *   *趋肤效应 (Skin Effect)*: 高频下电流为何只在导体表面流动？

### 1.2 重点难点记录
- [ ] 为什么 PMOS 通常设计得比 NMOS 宽 (2~3倍)？(迁移率差异)。
- [ ] 什么是 Velocity Saturation (速度饱和)？它如何影响短沟道器件的电流公式？

### 1.3 实验记录 (Lab 1)
*   **Lab 1 (Logical Effort)**:
    *   *仿真*: 验证 FO4 (Fan-out of 4) 反相器的延迟。

---

## Module 2: 时序分析与时钟树设计 (Timing Analysis & CTS)

### 2.1 核心概念速查
*   **时序约束 (Timing Constraints)**:
    *   **Setup Time ($T_{su}$)**: 数据必须在时钟沿之前稳定的时间。违例导致亚稳态。
        *   *公式*: $T_{clk} \ge T_{cq} + T_{logic} + T_{su} + T_{skew}$。
    *   **Hold Time ($T_{hold}$)**: 数据必须在时钟沿之后保持稳定的时间。
        *   *公式*: $T_{cq} + T_{logic} \ge T_{hold} + T_{skew}$。
    *   *关键区别*: Setup 违例可以通过降频解决；Hold 违例是致命的 (芯片报废)。
*   **时钟不确定性 (Clock Uncertainty)**:
    *   **Skew (偏斜)**: **空间上的不确定性**。由于时钟树路径长度、负载、Buffer 延迟不同，导致同一时钟沿到达不同寄存器的时间差。
        *   **Positive Skew (正偏斜)**: $T_{capture} > T_{launch}$ (时钟晚到接收端)。
            *   *场景*: 就像接收端的门晚关了一会儿，数据有更多时间跑过来。
            *   *影响*: **对 Setup 有利** (增加 Slack)，**对 Hold 有害** (容易发生透传/Race Condition)。
            *   *Useful Skew*: 故意引入正偏斜来修复 Setup 违例的技术。
        *   **Negative Skew (负偏斜)**: $T_{capture} < T_{launch}$ (时钟早到接收端)。
            *   *场景*: 接收端的门提前关了，数据还没跑过来就被拒之门外。
            *   *影响*: **对 Setup 有害** (减少 Slack，降低最高频率)，**对 Hold 有利**。
    *   **Jitter (抖动)**: **时间上的不确定性**。时钟边沿在理想时间点附近的随机波动。
        *   *来源*: PLL 噪声、电源纹波、热噪声。
        *   *影响*:
            *   **Setup**: 必须预留余量 ($T_{period} - T_{jitter}$)，直接导致最大工作频率降低。
            *   **Hold**: 虽然 Hold 检查通常基于同一时钟沿，但在考虑 OCV (On-Chip Variation) 时，Launch 和 Capture 路径上的瞬时 Jitter 差异可能导致违例。
*   **静态时序分析 (STA)**:
    *   *PVT Corners*: Process (SS/FF), Voltage (Low/High), Temperature (Min/Max)。
    *   *OCV (On-Chip Variation)*: 同一芯片上不同位置的晶体管速度差异。

### 2.2 重点难点记录
- [ ] 什么是 False Path 和 Multi-cycle Path？如何在 SDC 文件中约束它们？
- [ ] 为什么 Hold Time 检查通常在 Fast Corner (最佳工艺、高压、低温) 下进行？

### 2.3 实验记录 (Lab 2)
*   **Lab 2 (Timing Fix)**:
    *   *Setup 修复*: 插入流水线、逻辑优化、更换 LVT 单元。
    *   *Hold 修复*: 插入 Buffer (延迟单元)。

---

## Module 3: 算术电路架构 (Arithmetic Circuits)

### 3.1 加法器架构对比
| 架构 | 延迟 (Delay) | 面积 (Area) | 复杂度 | 适用场景 |
| :--- | :--- | :--- | :--- | :--- |
| **RCA (Ripple Carry)** | $O(N)$ | $O(N)$ | 低 | 低速、低功耗 |
| **CLA (Carry Lookahead)** | $O(\log N)$ | $O(N \log N)$ | 中 | 中高速 (32-bit) |
| **Kogge-Stone** | $O(\log N)$ | $O(N \log N)$ | 高 | 极高速 (64-bit CPU) |
| **Brent-Kung** | $O(\log N)$ | $O(N)$ | 中高 | 面积受限的高速设计 |

### 3.2 乘法器关键技术
*   **Booth Encoding**: 将乘数分组 (Radix-4)，减少部分积的数量 (减半)。
*   **Wallace Tree / Dadda Tree**: 使用全加器 (3:2压缩器) 并行压缩部分积，直到剩下两行。

### 3.3 实验记录 (Lab 3)
*   **Lab 3 (Adder Design)**:
    *   *RCA*: 观察进位链的传播延迟。
    *   *CLA*: 验证 P/G 信号生成逻辑。

---

## Module 4: 存储器设计 (Memory Design)

### 4.1 6T SRAM 单元详解
*   **结构**: 2个反相器交叉耦合 (存储) + 2个存取管 (Access Transistors)。
*   **读操作 (Read)**:
    *   *预充*: Bitline (BL/BLB) 预充至 VDD。
    *   *放电*: 存储 "0" 的一侧将 BL 拉低。
    *   *稳定性挑战*: 读干扰 (Read Disturbance) —— 读操作可能意外改写数据。要求 $W_{pull-down} > W_{access}$。
*   **写操作 (Write)**:
    *   *强写*: 驱动电路强行将 BL 拉低/拉高。
    *   *写能力挑战*: 必须能够覆盖原数据。要求 $W_{access} > W_{pull-up}$。

### 4.2 外围电路
*   **Sense Amplifier (灵敏放大器)**: 检测 BL 和 BLB 之间的微小电压差 (如 100mV)，迅速放大到逻辑电平。节省功耗并提高速度。

### 4.3 重点难点记录
- [ ] 什么是 SNM (Static Noise Margin)？蝴蝶曲线 (Butterfly Curve) 怎么画？
- [ ] 为什么 DRAM 需要刷新 (Refresh)？(电容漏电)。

---

## Module 5: 低功耗与鲁棒性 (Low Power & Robustness)

### 5.1 功耗公式拆解
$$ P_{total} = P_{dynamic} + P_{static} $$
$$ P_{dynamic} = \alpha \cdot C_L \cdot V_{DD}^2 \cdot f + I_{sc} \cdot V_{DD} $$
$$ P_{static} = I_{leak} \cdot V_{DD} $$

### 5.2 低功耗技术
*   **Clock Gating (时钟门控)**: 关掉不工作模块的时钟翻转。最有效、最常用。
*   **Power Gating (电源门控)**: 彻底切断电源。需要 Header/Footer 开关，面临唤醒延迟和浪涌电流问题。
*   **Multi-Vt**: 关键路径用 LVT (快但漏电大)，非关键路径用 HVT (慢但漏电小)。
*   **DVFS**: 动态调整电压和频率。

### 5.3 可靠性问题
*   **Electromigration (电迁移)**: 大电流密度导致金属原子迁移，造成断路或短路。
*   **HCI (热载流子注入)**: 高能电子损伤栅氧层，导致阈值电压漂移。
