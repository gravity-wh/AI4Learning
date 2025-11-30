# Course 1: Advanced Digital Integrated Circuits (高级数字集成电路)

## 课程愿景 (Course Vision)
本课程对标 **UC Berkeley EE241B**、**Stanford EE271** 及 **MIT 6.374**，旨在培养具备“物理直觉”的数字 IC 设计师。
我们不再满足于“代码能跑通”，而是要深入晶体管级 (Transistor Level) 和 物理层 (Physical Level)，去理解每一行 Verilog 代码背后的 PPA (Power, Performance, Area) 代价。

> **核心哲学**: "Digital design is just analog design with high gain." —— 所有的数字问题，归根结底都是模拟问题。

---

## 课程大纲 (Syllabus)

### Module 1: 深入 MOS 模型与逻辑努力 (Weeks 1-2)
**关键词**: *Elmore Delay, Logical Effort, Wire Engineering*
*   **核心内容**:
    *   **MOSFET 寄生参数**: 栅电容、扩散电容与米勒效应 (Miller Effect)。
    *   **逻辑努力 (Logical Effort)**: 手算最佳门尺寸 (Sizing) 和级数 (Staging) 的“屠龙技”。
    *   **互连线 (Interconnect)**: 为什么在深亚微米工艺下，线比门更慢？(Resistance, Capacitance, Inductance)。
*   **💡 思考引导**:
    *   如果反相器链驱动一个巨大的负载，为什么级数是 $\ln(C_{load}/C_{in})$ 而不是越少越好？
    *   为什么现在的 CPU 连线要用铜 (Cu) 代替铝 (Al)，并且还要用低-k 介质？

### Module 2: 时序分析与时钟树设计 (Weeks 3-5)
**关键词**: *STA, Jitter, Skew, OCV*
*   **核心内容**:
    *   **时序约束本质**: Setup/Hold Time 的晶体管级来源。
    *   **时钟不确定性**: Jitter (抖动) vs Skew (偏斜) —— 谁是朋友，谁是敌人？
    *   **静态时序分析 (STA)**: 关键路径、False Path、Multi-cycle Path。
    *   **片上变异 (OCV)**: 工艺角 (PVT Corners) 与 AOCV/POCV 简介。
*   **💡 思考引导**:
    *   Hold Time 违例为什么比 Setup Time 违例更致命？
    *   有用偏斜 (Useful Skew) 是如何“借用”时间来提升频率的？

### Module 3: 算术电路架构与数据通路 (Weeks 6-7)
**关键词**: *Adder, Multiplier, Datapath, Pipelining*
*   **核心内容**:
    *   **加法器战争**: RCA vs CLA vs Kogge-Stone vs Brent-Kung (速度与面积的极致博弈)。
    *   **乘法器艺术**: Booth Encoding (减少部分积) 与 Wallace Tree (压缩部分积)。
    *   **对数移位器 (Logarithmic Shifter)**: 桶形移位器 (Barrel Shifter) 的实现。
*   **💡 思考引导**:
    *   为什么 FPGA 里的加法器通常不用 CLA 而是用进位链 (Carry Chain) 硬核？
    *   在 7nm 工艺下，连线延迟占主导，复杂的树形加法器 (如 Kogge-Stone) 真的还比 RCA 快吗？

### Module 4: 存储器设计 (Weeks 8-9) [New!]
**关键词**: *SRAM, DRAM, Sense Amplifier, 6T Cell*
*   **核心内容**:
    *   **6T SRAM 单元**: 读稳定性 (Read Stability) 与写能力 (Write Ability) 的矛盾。
    *   **外围电路**: 灵敏放大器 (Sense Amp)、译码器与预充电路。
    *   **多端口存储器**: Register File 的实现挑战。
*   **💡 思考引导**:
    *   为什么 SRAM 的 Bitline 需要预充电到 VDD 或 VDD/2？
    *   随着电压降低，SRAM 的噪声容限 (SNM) 越来越小，如何保证数据不翻转？

### Module 5: 低功耗与鲁棒性设计 (Weeks 10-11)
**关键词**: *Clock Gating, Power Gating, DVFS, Reliability*
*   **核心内容**:
    *   **功耗拆解**: 动态 (Switching + Short Circuit) vs 静态 (Leakage)。
    *   **低功耗技术**: Clock Gating (最常用), Power Gating (最麻烦), Multi-Vt。
    *   **可靠性**: 电迁移 (Electromigration), NBTI/HCI 老化效应。
*   **💡 思考引导**:
    *   Power Gating 唤醒时会有巨大的浪涌电流 (In-rush Current)，如何防止它把电源轨拉塌？

---

## 推荐实验项目 (Labs)

1.  **Lab 1: 逻辑努力实战** - 用 SPICE 仿真验证手算的 Inverter Chain 最佳尺寸。
2.  **Lab 2: 时序约束与修复** - 在 Vivado 中故意制造 Setup/Hold 违例并修复。
3.  **Lab 3: 高速加法器设计** - (已创建) 实现 RCA 与 CLA，对比综合后的 PPA。
4.  **Lab 4: SRAM 单元仿真** - (进阶) 使用 SPICE 测量 6T SRAM 的 SNM (静态噪声容限)。

---

## 顶级学习资源 (Top-Tier Resources)

### 1. 经典教材 (The Bibles)
*   **Digital Integrated Circuits: A Design Perspective** (Jan Rabaey) - *入门必读，物理直觉的源泉。*
*   **CMOS VLSI Design: A Circuits and Systems Perspective** (Weste & Harris) - *工程性更强，适合查阅。*

### 2. 公开课 (Open Courseware)
*   **UC Berkeley EE241B (Advanced Digital IC)**:
    *   *特点*: 极其硬核，涵盖 SRAM、时序、低功耗的前沿研究。
    *   *资源*: 搜索 "Borivoje Nikolic EE241B" 寻找课件。
*   **MIT 6.374 (Analysis and Design of Digital ICs)**:
    *   *特点*: 理论扎实，Anantha Chandrakasan 教授是低功耗领域的泰斗。
*   **Stanford EE271 (VLSI Systems)**:
    *   *特点*: 偏向系统级视角和 Verilog 生成器。

### 3. 行业标准 (Industry Standards)
*   **Synopsys/Cadence User Guides**: 真正的“武林秘籍”往往藏在工具的 User Guide 里 (如 Design Compiler User Guide)。