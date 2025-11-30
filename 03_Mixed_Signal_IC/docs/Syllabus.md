# Course 3: Mixed-Signal IC Design (数模混合集成电路设计)

## 课程愿景 (Course Vision)
本课程对标 **MIT 6.776** (High Speed Communication Circuits)、**Stanford EE315** (Analog-Digital Interface Circuits) 及 **UCLA EE215A** (Analog IC Design)，旨在培养能够驾驭数模边界的系统级架构师。
在现代 SoC 中，纯模拟电路正在消失，取而代之的是“数字辅助模拟” (Digitally Assisted Analog) 和“混合信号建模”。本课程将带你从传统的运放设计思维，跃升至系统级建模与架构权衡。

> **核心哲学**: "The best analog circuit is a digital one." —— 但你必须懂得如何用模拟的物理去实现数字的梦想。

---

## 课程大纲 (Syllabus)

### Module 1: 采样理论与量化噪声 (Weeks 1-3)
**关键词**: *Sampling Theorem, ZOH, Jitter, Quantization Noise*
*   **核心内容**:
    *   **采样本质**: 从时域冲激串到频域卷积，深入理解混叠 (Aliasing) 与抗混叠滤波器 (AAF) 的设计权衡。
    *   **非理想采样**: 时钟抖动 (Aperture Jitter) 对 SNR 的致命打击 —— 为什么高频 ADC 对时钟要求极高？
    *   **量化噪声**: 它是白噪声吗？什么时候需要加抖动 (Dither)？SQNR = 6.02N + 1.76 dB 的推导与局限。
*   **💡 思考引导**:
    *   为什么在过采样 (Oversampling) 系统中，量化噪声功率谱密度会降低？
    *   零阶保持 (ZOH) 引入的 $\text{sinc}(f)$ 滚降如何影响 DAC 的高频输出？

### Module 2: 数据转换器架构 (ADC/DAC) (Weeks 4-6)
**关键词**: *SAR, Pipeline, Delta-Sigma, R-2R, Current Steering*
*   **核心内容**:
    *   **SAR ADC**: 电荷再分配 (Charge Redistribution) 原理，CDAC 校准技术，异步时钟逻辑。
    *   **Pipeline ADC**: 级间增益误差、MDAC 设计、数字误差校正 (DEC) 算法。
    *   **Delta-Sigma ADC**: 噪声整形 (Noise Shaping) 魔法，过采样率 (OSR) 与阶数的权衡，MASH 结构。
    *   **高速 DAC**: 电流舵 (Current Steering) 架构，分段 (Segmentation) 策略与动态非线性 (SFDR)。
*   **💡 思考引导**:
    *   为什么 SAR ADC 在先进工艺下越来越受欢迎 (Time-interleaved SAR)？
    *   Delta-Sigma 调制器中的“稳定性”问题是如何产生的？

### Module 3: 锁相环与时钟生成 (PLL/CDR) (Weeks 7-9)
**关键词**: *Phase Noise, Loop Bandwidth, CP-PLL, ADPLL, CDR*
*   **核心内容**:
    *   **线性模型**: 传递函数，阻尼系数，环路带宽对噪声（VCO 噪声 vs 参考噪声）的滤波作用。
    *   **电荷泵 PLL (CP-PLL)**: PFD 死区 (Dead Zone)，电荷泵电流失配，参考杂散 (Spurs) 的产生与抑制。
    *   **全数字 PLL (ADPLL)**: TDC (时间数字转换器) 取代 PFD，DCO 取代 VCO，数字环路滤波器的优势。
    *   **时钟数据恢复 (CDR)**: Bang-Bang 鉴相器，Alexander PD，抖动容限 (Jitter Tolerance)。
*   **💡 思考引导**:
    *   为什么 Type-II PLL 需要一个零点 (Zero) 来稳定环路？
    *   在高速 SerDes 中，为什么 CDR 往往采用“双环”结构？

### Module 4: 混合信号建模与验证 (Weeks 10-11)
**关键词**: *Verilog-AMS, Real Number Modeling (RNM), UVM-AMS*
*   **核心内容**:
    *   **建模分层**: 晶体管级 (SPICE) -> 宏模型 (Verilog-A) -> 实数模型 (wreal/SystemVerilog-RNM) -> 纯数字模型。
    *   **数模接口**: `connect module` 的自动插入，电压/电流与逻辑值的转换。
    *   **验证方法学**: 如何在 UVM 环境中驱动模拟信号？如何定义模拟覆盖率 (Analog Coverage)？
*   **💡 思考引导**:
    *   用 `real` 类型模拟电压有什么局限性？(提示：阻抗信息丢失)。
    *   如何验证一个 PLL 的锁定时间？是用 SPICE 跑几周，还是用 RNM 跑几分钟？

---

## 推荐实验项目 (Labs)

1.  **Lab 1: 采样与重构** - Matlab 仿真：观察混叠、量化噪声分布及 Dither 的效果。
2.  **Lab 2: SAR ADC 建模** - Verilog 实现 SAR 逻辑，配合 Verilog-A 比较器/DAC 进行混合仿真。
3.  **Lab 3: PLL 行为级建模** - 使用 Verilog-A 搭建 Type-II PLL，扫描环路参数观察阶跃响应与抖动传递。
4.  **Lab 4: 混合信号 UVM 验证** - (进阶) 搭建一个简单的 UVM 环境，验证一个受控振荡器 (DCO) 的频率特性。

---

## 顶级学习资源 (Top-Tier Resources)

### 1. 经典教材 (The Bibles)
*   **Design of Analog CMOS Integrated Circuits** (Behzad Razavi) - *模拟电路的圣经，基础必修。*
*   **Understanding Delta-Sigma Data Converters** (Schreier & Temes) - *ADC 领域的权威之作。*
*   **CMOS Mixed-Signal Circuit Design** (R. Jacob Baker) - *注重工程实现与建模。*

### 2. 公开课 (Open Courseware)
*   **MIT 6.776 (High Speed Communication Circuits)**:
    *   *特点*: 聚焦 PLL、CDR 和高速收发器，Michael Perrott 的讲义非常经典。
*   **Stanford EE315 (Analog-Digital Interface Circuits)**:
    *   *特点*: 深入讲解 ADC/DAC 架构，特别是高性能数据转换器设计。
*   **UCLA EE215A (Analog IC Design)**:
    *   *特点*: Razavi 教授亲自授课，深入浅出，打好模拟基础的不二之选。
*   **Berkeley EE247 (Advanced Analog IC)**:
    *   *特点*: 涵盖滤波器、ADC/DAC 的高级话题。

### 3. 行业标准与工具
*   **Cadence Virtuoso AMS Designer**: 混合信号仿真的工业标准工具。
*   **SystemVerilog LRM (IEEE 1800)**: 查阅 Real Number Modeling (RNM) 语法的官方文档。 