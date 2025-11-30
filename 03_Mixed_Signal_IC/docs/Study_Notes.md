# 学习笔记：Mixed-Signal IC Design (数模混合集成电路设计)

这份文档用于记录《Mixed-Signal IC Design》课程的学习心得、核心概念整理、实验记录以及待解决的问题。

---

## Module 1: 采样与数据转换基础 (Sampling & Data Conversion Basics)

### 1.1 核心概念速查
*   **采样定理 (Nyquist Theorem)**:
    *   *理解*: 如何直观理解频谱折叠？
    *   *笔记*:
*   **非理想采样 (Non-ideal Sampling)**:
    *   **时钟抖动 (Aperture Jitter)**:
        *   *公式*: $SNR_{jitter} = -20 \log_{10}(2\pi f_{in} \sigma_t)$。
        *   *直觉*: 信号变化越快 ($f_{in}$ 越高)，采样点的时间偏差 $\sigma_t$ 造成的电压误差 $\Delta V$ 就越大。这就是为什么高频 ADC 对时钟质量要求极高。
    *   **混叠 (Aliasing)**:
        *   *抗混叠滤波器 (AAF)*: 为什么不能用理想砖墙滤波器？实际设计中如何权衡滚降系数与带内平坦度？
*   **量化噪声 (Quantization Noise)**:
    *   *公式*: $SQNR = 6.02N + 1.76 dB$ 的推导关键点。
    *   *白噪声假设*: 什么时候量化噪声不再是“白”的？(输入为直流或周期信号时)。
    *   *Dither (抖动)*: 为什么故意加噪声反而能提高线性度 (SFDR)？(打破量化误差的周期性)。
*   **性能指标 (Metrics)**:
    *   *Static*: DNL (微分非线性) / INL (积分非线性) 的物理意义。
    *   *Dynamic*: SFDR (无杂散动态范围) vs SINAD (信纳比) vs ENOB (有效位数)。

### 1.2 重点难点记录
*   [ ] 如何设计抗混叠滤波器 (Anti-alias Filter)？
*   [ ] R-2R DAC 与 Current Steering DAC 的选型依据是什么？

### 1.3 实验记录 (Lab 1)
*   **Lab 1A (Matlab Sampling)**:
    *   *观察*: 欠采样时的频谱混叠现象。
*   **Lab 1B (DAC Modeling)**:
    *   *问题*: 引入失配后，INL 曲线呈现什么形状？

---

## Module 2: ADC 架构深入 (Advanced ADC Architectures)

### 2.1 架构对比分析
| 架构 | 速度 | 精度 | 功耗 | 典型应用场景 | 关键设计挑战 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **SAR** | 中 | 中高 | 低 | IoT, Bio | CDAC 匹配, 比较器噪声, 异步时钟逻辑 |
| **Flash** | 极高 | 低 | 高 | SerDes, Comm | 比较器 Offset, 输入电容, 气泡误差 |
| **Pipeline**| 高 | 高 | 中 | Video, Comm | 级间增益误差, MDAC 建立时间, 线性度 |
| **Delta-Sigma**| 低 | 极高 | 中 | Audio, Precision | 环路稳定性, 抽取滤波器设计, 闲音 (Idle Tones) |

### 2.2 关键技术笔记
*   **SAR Logic**:
    *   *异步逻辑 (Asynchronous)*: 为什么现代 SAR ADC 不再使用高频外部时钟，而是利用比较器完成信号触发内部状态机？(省功耗，无需高速时钟树)。
    *   *CDAC 校准*: 利用冗余位 (Redundancy) 容忍电容失配。
*   **Pipeline ADC**:
    *   *MDAC (Multiplying DAC)*: 它是 Pipeline 的心脏。如何利用开关电容电路实现“减法”和“乘 2”？
    *   *数字误差校正 (DEC)*: 为什么 1.5-bit 每级结构能容忍比较器的大偏移？
*   **Delta-Sigma ADC**:
    *   *噪声整形 (Noise Shaping)*: $\Delta\Sigma$ 调制器如何将噪声推向高频？
    *   *MASH 结构*: 如何通过级联多个低阶环路来实现高阶整形且保持稳定？

### 2.3 实验记录 (Lab 2)
*   **Lab 2A (SAR Verilog)**:
    *   *状态机设计*:
*   **Lab 2B (Delta-Sigma Matlab)**:
    *   *参数影响*: OSR 加倍对 SNR 的提升效果。

---

## Module 3: 锁相环与时钟生成 (PLL & Clock Generation)

### 3.0 学习目标 (Checklist)
- [ ] 能够画出 PLL 的线性小信号模型 (s域)。
- [ ] 理解 PFD 和 Charge Pump 的非理想效应 (Dead zone, Current mismatch)。
- [ ] 掌握 Phase Noise 和 Jitter 的转换关系。
- [ ] 理解 ADPLL 与模拟 PLL 的本质区别。
- [ ] 理解 CDR (时钟数据恢复) 的基本原理。

### 3.1 经典 PLL 线性模型 (Classical PLL Model)
> **Focus**: 环路稳定性、带宽权衡、传递函数。

*   **相位域建模 (Phase Domain Representation)**:
    *   *思考*: 为什么 VCO 在相位域是一个积分器 ($K_{vco}/s$)？
    *   *笔记*:
        1. **定义**: VCO 的输出频率 $\omega_{out}$ 与控制电压 $V_{ctrl}$ 成正比：$\omega_{out}(t) = \omega_0 + K_{vco} \cdot V_{ctrl}(t)$。
        2. **物理关系**: 相位 $\phi(t)$ 是频率 $\omega(t)$ 对时间的积分：$\phi(t) = \int \omega(t) dt$。
        3. **推导**: 我们关注的是相对于中心频率 $\omega_0$ 的**相位变化**。因此，输出相位 $\phi_{out}(t) = \int (K_{vco} \cdot V_{ctrl}(t)) dt$。
        4. **S域**: 在拉普拉斯变换中，时域积分对应除以 $s$。因此传递函数为 $\frac{\Phi_{out}(s)}{V_{ctrl}(s)} = \frac{K_{vco}}{s}$。
        5. **误区澄清**: **电压不是相位信号**。
            *   电压 $V_{ctrl}$ 控制的是相位的**变化率** (即频率)。
            *   **类比**: 把相位看作“距离”，频率看作“速度”。VCO 就像油门，输入电压决定了车速(频率)。如果你踩着油门不动(电压恒定)，车速恒定，但距离(相位)会一直累积增加。这就是积分的含义。
*   **环路滤波器 (Loop Filter)**:
    *   *Type-I vs Type-II*: 为什么我们需要 Type-II (电荷泵) PLL？
        *   **Type-I (Mixer/XOR PD)**: 只有一个积分器 (VCO)。为了让 VCO 运行在中心频率 $\omega_0$ 以外的频率，必须给它提供一个非零的 $V_{ctrl}$。在 Type-I 中，这个电压直接来自于相位误差 $\Delta \phi$。因此，**频率偏离越大，静态相位误差 (Static Phase Error) 就越大**。
        *   **Type-II (Charge Pump)**: 引入了第二个积分器 (电荷泵+电容)。电容可以**记忆**电荷，维持任意的 $V_{ctrl}$ 电压，而不需要持续的相位误差输入。
        *   **核心优势**: Type-II PLL 可以实现 **零静态相位误差** (Zero Static Phase Error)，即无论 VCO 跑在哪个频率，锁定时输入输出相位都是对齐的。此外，配合 PFD，它拥有极大的频率捕获范围。
        *   **进阶思考**: *为什么 VCO 会跑在中心频率 $\omega_0$ 以外？*
            *   **PVT 变异**: 即使设计目标是 1GHz，由于工艺偏差(Process)、电压波动(Voltage)、温度变化(Temperature)，芯片实际出来的“自然频率”可能变成了 0.9GHz。为了输出 1GHz，PLL 必须调整 $V_{ctrl}$ 把频率“硬拉”回去。
            *   **频率综合**: 我们可能需要同一个 PLL 产生不同的频率 (如 CPU 动态调频)。
    *   *零极点位置*: 电阻电容对相位裕度 (Phase Margin) 的影响。
        *   **问题 (双重积分)**: Type-II PLL 有两个原点极点 (VCO $1/s$ + 电荷泵电容 $1/s$)。这意味着开环相位滞后恒定为 $-180^\circ$。相位裕度为 0，系统极不稳定，必然振荡。
        *   **解法 (引入零点)**: 在环路滤波器电容 $C_1$ 上串联一个电阻 $R$。
        *   **零点作用**: 阻抗变为 $R + 1/sC_1$，引入了一个左半平面零点 $\omega_z = 1/(RC_1)$。零点提供**相位超前 (Phase Lead)**，将相位曲线从 $-180^\circ$ 拉回来 (例如拉到 $-130^\circ$)，从而产生正的相位裕度 (如 $50^\circ$)。
        *   **次级极点 (Ripple Pole)**: 电阻 $R$ 会导致 $V_{ctrl}$ 上出现瞬间电压跳变 (Ripple)。通常并联一个小电容 $C_2$ 来平滑它，但这会引入一个新的高频极点 $\omega_p \approx 1/(RC_2)$，如果 $C_2$ 太大，会吃掉相位裕度。
*   **噪声传递函数 (Noise Transfer Function)**:
    *   *输入参考噪声* (Ref clk) 是低通还是高通？(低通，PLL 跟踪参考)。
    *   *VCO 噪声* 是低通还是高通？(高通，PLL 抑制 VCO 的低频漂移，但高频噪声无法纠正)。
    *   *带宽权衡*: 宽带宽有利于抑制 VCO 噪声，窄带宽有利于滤除参考噪声。如何取舍？

### 3.2 PFD 与电荷泵非理想性 (PFD/CP Non-idealities)
> **Focus**: 杂散 (Spurs) 的来源与抑制。

*   **死区 (Dead Zone)**:
    *   *现象*: 小相位误差时增益为零。
        *   **原因**: 理想的 PFD 在相位误差极小时，应该输出极窄的 UP/DOWN 脉冲。但实际上，逻辑门翻转需要时间 (Rise/Fall time)，电荷泵开关打开也需要时间。如果脉冲宽度小于这个**最小响应时间**，电荷泵根本来不及打开，电流为 0。
        *   **后果**: 在相位误差很小时，环路“失明”了，无法进行调节。这会导致相位在死区内自由漂移，产生低频抖动 (Jitter)。
    *   *解决*: 引入复位延迟 (Reset Delay)。
        *   **方法**: 在 PFD 的复位路径上人为增加一段延迟 (Delay Cell)。
        *   **效果**: 即使相位误差为 0，UP 和 DOWN 信号也会同时输出一个固定的最小脉宽 (例如 1ns)。
        *   **原理**: 虽然 UP 和 DOWN 同时开启会相互抵消 (净电流为 0)，但它们都保证了足够长的时间来完全打开电荷泵开关。一旦有微小的相位误差，其中一个脉冲就会比另一个宽一点点，产生净电流，从而消除了死区。
        *   **时序图对比**:
            ```text
            1. 无延迟 (Dead Zone): 脉冲太窄，开关打不开
            Ref : ____/````\_______
            Fb  : ______/````\_____
            UP  : ____/`\__________  <-- 脉宽 < t_min, 无效
            DOWN: ______/__________
            I_cp: _________________  (无电流输出)

            2. 有延迟 (Reset Delay): 强制展宽，保证开启
            Ref : ____/````````````\_______
            Fb  : ______/````````````\_____
            UP  : ____/``````````````\_____  <-- 足够宽，开关完全打开
            DOWN: ______/````````````\_____  <-- 同时也打开，大部分时间相互抵消
                  |<-- Reset Delay -->|
            I_cp: ____/`\__________________  (有效的净电流脉冲!)
            ```
*   **电荷泵失配 (Charge Pump Mismatch)**:
    *   *后果*: 静态相位误差 (Static Phase Error) -> 参考杂散 (Reference Spurs)。
    *   *笔记*:
*   **电流泄漏 (Leakage)**:
    *   *笔记*:

### 3.3 VCO 与频率综合器 (VCO & Frequency Synthesizer)
> **Focus**: 振荡器架构与分频技术。

*   **LC VCO vs Ring VCO**:
    *   *对比*: 相位噪声 (Q值)、调谐范围、面积。
*   **小数分频 (Fractional-N)**:
    *   *原理*: 如何通过动态改变分频比实现小数分频？
        *   **核心思想**: 分频器只能进行整数分频 (如 /N 或 /N+1)。要实现小数分频 (如 N.25)，可以通过在 N 和 N+1 之间**动态切换**来实现。
        *   **平均值概念**: 如果在 4 个周期里，有 3 个周期分频比为 N，1 个周期为 N+1，那么平均分频比就是 $N + 1/4 = N.25$。
        *   **公式**: $N_{avg} = N \cdot (1-\alpha) + (N+1) \cdot \alpha = N + \alpha$。
    *   *Delta-Sigma Modulator (SDM)*: 在分频器中的应用。
        *   **痛点**: 如果只是简单周期性地切换 (如 N, N, N, N+1...)，会产生很强的周期性杂散 (Spurs)。
        *   **SDM 的作用**: 利用 SDM 生成一个**伪随机**的整数序列 (控制分频比)，使得长期的平均值精确等于目标小数，同时将周期性误差转化为高频噪声 (**Noise Shaping**)，最后由 PLL 的低通环路滤波器滤除。
        *   **1. 一阶 SDM (Accumulator)**:
            *   **结构**: 一个简单的累加器。输入为小数控制字 $K$ (假设满量程为 $M$)。
            *   **逻辑**: 每时钟周期 `sum = sum + K`。
                *   如果 `sum >= M` (溢出)，输出 Carry=1，分频比设为 $N+1$，`sum = sum - M`。
                *   否则，输出 Carry=0，分频比设为 $N$。
            *   **序列特征**: 只有两个值 {N, N+1}。
        *   **2. 三阶 SDM (MASH 1-1-1)**:
            *   **结构**: 级联三个一阶累加器。
            *   **逻辑**: 组合三个累加器的溢出信号。输出范围通常覆盖 8 个整数值 (如 $N-3$ 到 $N+4$)。
                *   公式: $DIV[n] = N + c_1[n] + (c_2[n] - c_2[n-1]) + (c_3[n] - 2c_3[n-1] + c_3[n-2])$。
            *   **序列特征**: 序列看起来更加随机，使用了多个整数电平。
            *   **优势**: 噪声整形效果更好 (噪声被推得更远)，低频杂散更小。

### 3.4 全数字锁相环 (ADPLL) 与 CDR
> **Focus**: 数字化带来的新架构与高速接口。

*   **ADPLL 架构**:
    *   **TDC (Time-to-Digital Converter)**: 替代 PFD+CP，将相位差量化为数字码。分辨率受限于反相器延迟 (Inverter delay)。
    *   **DCO (Digitally Controlled Oscillator)**: 替代 VCO，使用开关电容阵列调谐频率。
    *   **数字环路滤波器**: 面积小，参数可配置，无漏电问题，易于移植。
*   **CDR (Clock and Data Recovery)**:
    *   *任务*: 从高速串行数据流中提取时钟，并恢复数据。
    *   *Bang-Bang PD (Alexander PD)*: 仅检测相位超前/滞后 (Binary)，非线性，具有高增益。
    *   *Jitter Tolerance (抖动容限)*: CDR 能够跟踪多大频率和幅度的输入抖动而不产生误码？

### 3.5 实验与思考 (Lab 3 Record)
*   **Lab 3A: Verilog-A PLL Modeling**:
    *   *锁定过程观察*: 控制电压 $V_{ctrl}$ 的建立过程。
    *   *Jitter 测量*:
*   **Lab 3B: ADPLL SystemVerilog Modeling**:
    *   *TDC 建模*: 如何用 Real Number Modeling 模拟延迟链？
    *   *遇到的问题*:

### 3.6 深度思考题 (Q&A)
1.  **Q**: 如果 PLL 锁不住 (Lock detect fail)，通常排查步骤是什么？
    *   **A**: (待补充... 检查 VCO 范围？检查分频比？检查极性？)
2.  **Q**: 为什么高带宽 PLL 能够更好地抑制 VCO 噪声，却会放大输入参考噪声？
    *   **A**: (待补充...)
3.  **Q**: 为什么说 PLL 本质上是一个负反馈系统？
    *   **A**:
        *   **定义**: 负反馈的核心在于**“检测误差 -> 产生动作 -> 减小误差”**。
        *   **PLL 的机制**:
            1.  **检测**: 鉴相器 (PFD) 计算输入参考相位与反馈相位的差值：$\Delta\phi = \phi_{ref} - \phi_{fb}$。这个**减法**操作就是负反馈的数学体现。
            2.  **动作**:
                *   如果 $\phi_{fb}$ 落后 ($\Delta\phi > 0$) -> PFD 输出 UP 脉冲 -> $V_{ctrl}$ 升高 -> VCO 频率增加 -> $\phi_{fb}$ 跑得更快，去追赶 $\phi_{ref}$。
                *   如果 $\phi_{fb}$ 超前 ($\Delta\phi < 0$) -> PFD 输出 DOWN 脉冲 -> $V_{ctrl}$ 降低 -> VCO 频率减小 -> $\phi_{fb}$ 慢下来，等待 $\phi_{ref}$。
            3.  **结果**: 环路总是试图让 $\Delta\phi$ 趋向于 0。如果接反了 (比如把 UP/DOWN 信号对调)，误差会被不断放大，那就是正反馈，VCO 会直接跑飞到最高或最低频率。

---

## Module 4: 混合信号建模与验证 (Mixed-Signal Modeling & Verification)

### 4.1 建模策略 (Modeling Strategy)
*   **Verilog-A vs Verilog-AMS vs SystemVerilog (RNM)**:
    *   *Verilog-A*: 纯模拟行为描述 (Kirchhoff 定律)，求解器慢，精度高。适合 VCO、运放核心。
    *   *Verilog-AMS*: 混合信号，支持模拟/数字交互。
    *   *SystemVerilog RNM (Real Number Modeling)*: 纯数字仿真器 (Event-driven)，用 `real` 类型传递电压/电流。速度极快，适合顶层验证。
    *   *选择指南*: 顶层连接性检查用 RNM；模块级性能验证用 Verilog-A/AMS。

### 4.2 混合仿真流程 (Co-Simulation)
*   **Connect Modules (Interface Elements)**:
    *   *A2D / D2A*: 模拟电压与数字逻辑电平的转换阈值设置。
    *   *时间步长*: 模拟求解器与数字事件队列的同步。

### 4.3 验证方法学 (Verification Methodology)
*   **Analog Coverage**: 如何定义模拟电路的“覆盖率”？(例如：VCO 增益曲线覆盖范围)。
*   **Checker / Assertion**: 编写 SVA 检查模拟信号是否越界。

### 4.4 实验记录 (Lab 4)
*   **Lab 4A (AMS Simulation)**:
    *   *仿真速度对比*: 晶体管级 vs 行为级模型。
*   **Lab 4B (UVM Integration)**:
    *   *笔记*: 如何将模拟信号通过 Analysis Port 传给 Scoreboard？
