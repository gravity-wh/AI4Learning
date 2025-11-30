# Type-II PLL 稳定性推导：从振荡到稳定

## 1. 为什么不加电阻会振荡？(The Unstable Case)

我们考察 PLL 的开环传递函数 (Open Loop Transfer Function) $H_{open}(s)$。
一个典型的 Charge-Pump PLL 环路由以下部分串联组成：

1.  **PFD/CP (鉴频鉴相器/电荷泵)**:
    *   增益 $K_{pfd} = \frac{I_{cp}}{2\pi}$ (单位: A/rad)
2.  **Loop Filter (环路滤波器 - 仅电容 $C_1$)**:
    *   阻抗 $Z(s) = \frac{1}{s C_1}$ (单位: V/A)
3.  **VCO (压控振荡器)**:
    *   传递函数 $\frac{K_{vco}}{s}$ (单位: rad/V/s)
    *   *注*: 这里除以 $s$ 是因为输入是电压，输出是相位 (频率的积分)。

**开环传递函数**:
$$ H_{open}(s) = K_{pfd} \cdot Z(s) \cdot \frac{K_{vco}}{s} = \frac{I_{cp}}{2\pi} \cdot \frac{1}{s C_1} \cdot \frac{K_{vco}}{s} $$

整理得到：
$$ H_{open}(s) = \frac{I_{cp} K_{vco}}{2\pi C_1} \cdot \frac{1}{s^2} $$

**频域分析 (Bode Plot)**:
令 $s = j\omega$，考察其幅度和相位：
*   **幅度**: $|H_{open}(j\omega)| = \frac{K}{\omega^2}$ (斜率 -40dB/dec)
*   **相位**: $\angle H_{open}(j\omega) = \angle \frac{1}{(j\omega)^2} = \angle \frac{1}{-\omega^2} = -180^\circ$

**结论**:
无论频率 $\omega$ 是多少，相位**恒定为 $-180^\circ$**。
这意味着 **相位裕度 (Phase Margin, PM) = $180^\circ + (-180^\circ) = 0^\circ$**。
根据巴克豪森判据，PM=0 的反馈系统处于临界稳定或不稳定状态，实际电路中必然存在寄生极点导致相位进一步滞后 (比如 -185度)，系统将发生**剧烈振荡**。

---

## 2. 引入电阻 R 后的变化 (The Stabilized Case)

为了拯救系统，我们在电容 $C_1$ 上串联一个电阻 $R$。

**新的环路滤波器阻抗**:
$$ Z(s) = R + \frac{1}{s C_1} = \frac{s R C_1 + 1}{s C_1} $$

**新的开环传递函数**:
$$ H_{open}(s) = \frac{I_{cp} K_{vco}}{2\pi} \cdot \frac{s R C_1 + 1}{s C_1} \cdot \frac{1}{s} $$

整理得到：
$$ H_{open}(s) = \frac{I_{cp} K_{vco}}{2\pi C_1} \cdot \frac{1 + s/\omega_z}{s^2} $$

其中，我们引入了一个**零点 (Zero)**：
$$ \omega_z = \frac{1}{R C_1} $$

**新的频域分析**:
令 $s = j\omega$：
*   **相位表达式**:
    $$ \angle H_{open}(j\omega) = \angle \frac{1}{(j\omega)^2} + \angle (1 + j\frac{\omega}{\omega_z}) $$
    $$ \angle H_{open}(j\omega) = -180^\circ + \arctan\left(\frac{\omega}{\omega_z}\right) $$

**关键变化**:
1.  **低频时 ($\omega \ll \omega_z$)**: $\arctan \approx 0$，相位接近 $-180^\circ$。
2.  **高频时 ($\omega \gg \omega_z$)**: $\arctan \approx 90^\circ$，相位接近 $-90^\circ$。
3.  **穿越频率处 ($\omega_c$)**:
    只要我们将零点 $\omega_z$ 设计得比单位增益带宽 $\omega_c$ 低 (通常 $\omega_z \approx \omega_c / 4$)，在 $\omega_c$ 处就能获得显著的相位提升。

    例如，若 $\omega_c = 4\omega_z$：
    $$ \angle H_{open}(j\omega_c) = -180^\circ + \arctan(4) \approx -180^\circ + 76^\circ = -104^\circ $$

    **相位裕度 (PM)**:
    $$ PM = 180^\circ + (-104^\circ) = 76^\circ $$

**结论**:
电阻 $R$ 引入的零点提供了一个正的相位“推力”，将相位曲线从 $-180^\circ$ 的悬崖边拉了回来，使系统变得稳定。

---

## 3. 总结图示 (Mental Model)

*   **无电阻**: $1/s^2$ -> 相位死死趴在 -180度 -> **必挂**。
*   **有电阻**: $(1 + s/\omega_z) / s^2$ -> 相位从 -180度 开始慢慢抬升，最终指向 -90度 -> **稳定**。

---

## 4. 深度解析：$s=j\omega$ 与 巴克豪森判据

### 4.1 令 $s=j\omega$ 的本质是什么？

在拉普拉斯变换中，复频率变量 $s = \sigma + j\omega$。
当我们令 $s = j\omega$ (即令实部 $\sigma=0$) 时，我们实际上是在**将系统限制在稳态正弦激励下进行分析**。

*   **物理意义**: 我们假设输入信号是一个**纯粹的正弦波** $e^{j\omega t}$ (没有衰减也没有增长)，然后观察系统对这个特定频率正弦波的**幅度响应**和**相位响应**。
*   **为什么这么做**: 任何复杂的信号都可以通过傅里叶变换分解为无数个不同频率的正弦波的叠加。如果我们知道了系统对所有频率 $\omega$ 的正弦波的响应 (即频率响应)，我们就知道了系统对任意信号的响应。
*   **直观理解**: 这就像是用一个扫频仪，从低频到高频给系统输入正弦波，看输出变成了什么样。

### 4.2 巴克豪森判据 (Barkhausen Stability Criterion)

巴克豪森判据是判断一个反馈系统是否会**持续振荡**的必要条件。

对于一个环路增益为 $L(j\omega) = H(j\omega) \cdot \beta$ 的负反馈系统，如果存在某个频率 $\omega_{osc}$ 满足以下两个条件，系统就可能发生振荡：

1.  **相位条件**: 环路相移为 $360^\circ$ 的整数倍 (或在负反馈系统中，附加相移为 $-180^\circ$)。
    $$ \angle L(j\omega_{osc}) = -180^\circ $$
    *(注: 负反馈本身已经带了一个 $-180^\circ$ (即反相)，如果环路内部再滞后 $-180^\circ$，总相移就是 $-360^\circ$ (即 $0^\circ$)，变成了**正反馈**。)*

2.  **幅度条件**: 环路增益大于或等于 1 (0dB)。
    $$ |L(j\omega_{osc})| \ge 1 $$

### 4.3 为什么满足条件就会振荡？(直观解释)

想象一个信号在环路里跑圈：

1.  **正反馈 (相位 -180)**:
    *   假设输入一个微小的正弦波噪声。
    *   经过负反馈节点 ($-180^\circ$) 变成反相。
    *   再经过环路滤波器和 VCO (内部滞后 $-180^\circ$)，相位又转了半圈。
    *   **结果**: 信号转了一圈回到起点时，相位刚好转了 $360^\circ$，与原始信号**完全同相**。这意味着它会叠加在原始信号上，使信号增强。

2.  **增益 >= 1**:
    *   如果转一圈回来，信号不仅同相，而且幅度没有变小 (甚至变大了)，那么这个信号就会在环路里**无限循环、自我增强**。
    *   这就好比麦克风对着音箱产生的啸叫：声音进去 -> 放大 -> 出来 -> 再进去 -> 再放大... 最终导致系统饱和，形成稳定的振荡。

**对应到 Type-II PLL**:
*   如果没有电阻，相位恒定 $-180^\circ$。
*   只要环路增益 $|H(j\omega)| > 1$ (在低频时肯定满足，因为有 $1/s^2$ 积分环节，低频增益无穷大)，系统就满足振荡条件。
*   实际上，任何微小的噪声都会被无限放大，导致 VCO 控制电压剧烈波动，PLL 根本锁不住。

---

## 5. 波特图可视化 (Bode Plot Visualization)

为了更直观地理解，我们用 ASCII 图来对比加电阻前后的频率响应。

### 5.1 幅度响应 (Magnitude)

*   **无电阻**: 纯粹的双重积分 ($1/s^2$)，增益以 **-40dB/dec** 的速度直线下降。
*   **有电阻**: 在零点 $\omega_z$ 之后，分子上的 $s$ 开始起作用，抵消了一个分母上的 $s$。斜率变缓，变为 **-20dB/dec**。

```text
Gain (dB)
  ^
  |
  |          \  (-40dB/dec)
  |           \
  |            \
  |             \
  |              \   <-- 无电阻 (Unstabilized)
  |               \
  |                \
  |-----------------\-------------------------> log(w)
  |
  |          \
  |           \
  |            \    (-20dB/dec)
  |             \______
  |                    \
  |                     \   <-- 有电阻 (Stabilized)
  |                      \
  |                       \
  |           ^
  |          w_z (零点频率)
```

### 5.2 相位响应 (Phase) - **关键所在！**

*   **无电阻**: 相位恒定为 **-180°**。相位裕度 (PM) = 0。
*   **有电阻**: 相位从 -180° 开始，在零点 $\omega_z$ 附近开始**抬升**，最高冲向 -90°。
*   **设计目标**: 我们通常把穿越频率 $\omega_c$ (增益为0dB的频率) 选在相位抬升的最高点附近，从而获得最大的相位裕度。

```text
Phase (deg)
  ^
  |
 -90| . . . . . . . . . . . . . . . . . . . . . . . . . . . .
  |
  |                          /--------\
  |                         /          \
-135| . . . . . . . . . . ./            \ . . . . . . . . . .
  |                       /              \
  |                      /                \
  |                     /                  \
-180|__________________/____________________\________________
  |   (无电阻: 恒定 -180) ^        ^
  |                      w_z      w_c (穿越频率)
  |
  |
  |           [ 危险区: 只要再多一点点延迟就会振荡 ]
```

**图解说明**:
1.  **$\omega_z$ (零点)**: 电阻 $R$ 开始起作用的地方。相位开始“起飞”。
2.  **$\omega_c$ (穿越频率)**: 此时增益降为 1 (0dB)。我们需要在这里检查相位。
3.  **相位裕度 (PM)**: 在 $\omega_c$ 处，相位曲线距离 -180° 的高度。图中可以看到，加了电阻后，我们在 $\omega_c$ 处有了显著的“安全距离”。

---

## 6. 深度解析：逻辑门翻转时间与最小响应时间 (IC Design Perspective)

在 PLL 的死区问题中，我们提到了“逻辑门翻转需要时间”。从 IC 设计与制造的微观角度来看，这不仅仅是一个延迟参数，而是物理实现的根本限制。

### 6.1 为什么逻辑门翻转需要时间？(The Physics)

在 CMOS 工艺中，逻辑门（如反相器、与非门）的输出端本质上连接着下一级门的栅极电容 ($C_{gate}$) 和互连线电容 ($C_{wire}$)。

*   **充放电过程**: 逻辑状态的改变 (0->1 或 1->0) 实际上就是通过 PMOS/NMOS 对负载电容 $C_{load}$ 进行充电或放电的过程。
*   **有限电流**: 晶体管不是理想开关，它们有导通电阻 ($R_{on}$)，或者更准确地说是有限的驱动电流 ($I_{ds}$).
*   **延迟公式**: 简单的延时估算可以表示为 $\tau \approx R_{on} \cdot C_{load}$ 或 $t_{delay} \approx \frac{C_{load} \cdot \Delta V}{I_{avg}}$。

**结论**: 只要有电容（物理必然）和有限的驱动能力（物理必然），电压就不可能瞬间跳变。这就产生了 **Rise Time (上升时间)**, **Fall Time (下降时间)** 和 **Propagation Delay (传播延迟)**。

### 6.2 什么是“最小响应时间”？(Minimum Response Time)

在 PFD/CP 电路中，"最小响应时间" 指的是**能够让后级电路（电荷泵开关）完全导通并产生有效输出所需的最小脉冲宽度**。

它由两部分组成：
1.  **开启时间 ($t_{turn-on}$)**: 信号从 PFD 输出到达电荷泵开关栅极，并使栅电压超过阈值电压 ($V_{th}$) 所需的时间。
2.  **建立时间 ($t_{settling}$)**: 电荷泵电流源从 0 建立到标称值 ($I_{cp}$) 所需的时间。

如果 PFD 输出的脉冲宽度 $t_{pulse} < t_{turn-on} + t_{settling}$：
*   开关可能只打开了一半（工作在亚阈值区或线性区）。
*   电流源还没来得及建立完全。
*   **结果**: 输送到滤波器的电荷量 $Q = \int I(t) dt$ 远小于预期值，甚至接近于 0。这就是**死区**的物理成因。

### 6.3 设计者视角：哪些场景需要考虑这个因素？

作为 IC 设计者，除了 PLL 的死区消除，我们在以下场景中也必须时刻警惕这个物理限制：

#### A. 脉冲发生器与毛刺滤除 (Pulse Generation & Glitch Filtering)
*   **场景**: 设计复位电路或边缘检测电路时，我们常利用延迟链产生短脉冲。
*   **风险**: 如果产生的脉冲太窄（小于后续触发器的 $t_{min\_pulse\_width}$），触发器可能无法采样，或者进入亚稳态 (Metastability)。
*   **对策**: 必须保证脉冲宽度覆盖 PVT (Process, Voltage, Temperature) 的最差情况 (Worst Case)。

#### B. 存储器读写时序 (SRAM Read/Write Margin)
*   **场景**: SRAM 的字线 (Wordline) 开启时间。
*   **风险**: 如果 Wordline 开启脉冲太短，位线 (Bitline) 压差还没拉开，灵敏放大器 (Sense Amp) 就启动了，导致读出错误数据。
*   **对策**: 精确的 Replica Path (复制路径) 时序控制，确保脉冲足够宽。

#### C. 跨时钟域同步 (CDC - Pulse Synchronizer)
*   **场景**: 将一个单周期脉冲从快时钟域传到慢时钟域。
*   **风险**: 如果快时钟域的脉冲宽度小于慢时钟周期的 1.5 倍，慢时钟可能根本采不到这个脉冲（漏采）。
*   **对策**: 使用握手协议或将脉冲展宽 (Pulse Stretcher)。

#### D. 动态逻辑与预充电路 (Dynamic Logic)
*   **场景**: 高速处理器中的 Domino Logic。
*   **风险**: 预充 (Pre-charge) 和求值 (Evaluation) 阶段的时间窗口必须严格控制。如果求值时间太短，节点电容放电不完全，会导致逻辑错误。

### 6.4 总结

"逻辑门翻转需要时间" 是数字电路与模拟物理世界的接口。
*   在**算法/RTL 层面**，我们往往假设信号是理想跳变的。
*   但在**电路/物理实现层面**，我们必须把信号看作连续变化的电压波形。
*   **死区消除 (Reset Delay)** 本质上就是一种**“以时间换精度”**的策略：故意浪费一点时间（产生重叠脉冲），换取对微小误差的精确响应能力。

---

## 7. 周期性杂散 (Spurs) 的数学推导

在 PLL 中，杂散 (Spurs) 是指在载波频率 $\omega_0$ 附近的非期望离散谱线。最常见的杂散是**参考杂散 (Reference Spurs)**，它通常出现在 $\omega_0 \pm \omega_{ref}$ 处。

### 7.1 物理成因：周期性扰动

理想情况下，VCO 的控制电压 $V_{ctrl}$ 应该是一个完美的直流电压。
但在 Type-II PLL 中，由于电荷泵的非理想性（如漏电流、电流失配、复位脉冲馈通），$V_{ctrl}$ 上会叠加一个**周期性的微小纹波 (Ripple)**。这个纹波的频率通常等于参考时钟频率 $\omega_{ref}$。

假设 $V_{ctrl}(t)$ 由直流分量 $V_{DC}$ 和一个微小的余弦纹波组成：
$$ V_{ctrl}(t) = V_{DC} + V_m \cos(\omega_{ref} t) $$

### 7.2 频率调制 (FM) 效应

VCO 的输出频率 $\omega_{out}(t)$ 与控制电压成正比：
$$ \omega_{out}(t) = \omega_{free} + K_{vco} \cdot V_{ctrl}(t) $$
$$ \omega_{out}(t) = \underbrace{(\omega_{free} + K_{vco} V_{DC})}_{\omega_0 \text{ (载波频率)}} + \underbrace{K_{vco} V_m \cos(\omega_{ref} t)}_{\text{频率偏差 } \Delta\omega(t)} $$

VCO 的输出相位 $\phi_{out}(t)$ 是频率的积分：
$$ \phi_{out}(t) = \int \omega_{out}(t) dt = \omega_0 t + \frac{K_{vco} V_m}{\omega_{ref}} \sin(\omega_{ref} t) $$

我们定义**调制指数 (Modulation Index)** $\beta$：
$$ \beta = \frac{K_{vco} V_m}{\omega_{ref}} $$

于是，VCO 的时域输出波形为：
$$ V_{out}(t) = A \cos(\phi_{out}(t)) = A \cos(\omega_0 t + \beta \sin(\omega_{ref} t)) $$

### 7.3 窄带调频近似 (Narrowband FM Approximation)

利用三角恒等式展开：
$$ \cos(A+B) = \cos A \cos B - \sin A \sin B $$
$$ V_{out}(t) = A [\cos(\omega_0 t)\cos(\beta \sin(\omega_{ref} t)) - \sin(\omega_0 t)\sin(\beta \sin(\omega_{ref} t))] $$

当纹波很小 ($V_m$ 很小) 时，$\beta \ll 1$。我们可以使用小角度近似：
*   $\cos(\beta \sin(\omega_{ref} t)) \approx 1$
*   $\sin(\beta \sin(\omega_{ref} t)) \approx \beta \sin(\omega_{ref} t)$

代入上式：
$$ V_{out}(t) \approx A [\cos(\omega_0 t) - \beta \sin(\omega_{ref} t)\sin(\omega_0 t)] $$

利用积化和差公式 $\sin A \sin B = \frac{1}{2}[\cos(A-B) - \cos(A+B)]$：
$$ V_{out}(t) \approx A \cos(\omega_0 t) - \frac{A\beta}{2} [\cos((\omega_0 - \omega_{ref})t) - \cos((\omega_0 + \omega_{ref})t)] $$
$$ V_{out}(t) \approx \underbrace{A \cos(\omega_0 t)}_{\text{载波}} - \underbrace{\frac{A\beta}{2} \cos((\omega_0 - \omega_{ref})t)}_{\text{下边带杂散}} + \underbrace{\frac{A\beta}{2} \cos((\omega_0 + \omega_{ref})t)}_{\text{上边带杂散}} $$

### 7.4 结论与杂散幅度

1.  **杂散位置**:
    推导表明，频率为 $\omega_{ref}$ 的控制电压纹波，会在载波 $\omega_0$ 的左右两侧产生频率为 $\omega_0 \pm \omega_{ref}$ 的杂散分量。

2.  **杂散幅度 (Spur Level)**:
    杂散功率相对于载波功率的比值 (以 dBc 为单位) 为：
    $$ \text{Spur Level (dBc)} = 20 \log_{10}\left( \frac{\text{杂散幅度}}{\text{载波幅度}} \right) = 20 \log_{10}\left( \frac{A\beta/2}{A} \right) = 20 \log_{10}\left( \frac{\beta}{2} \right) $$

    代入 $\beta = \frac{K_{vco} V_m}{\omega_{ref}}$：
    $$ \text{Spur Level} = 20 \log_{10}\left( \frac{K_{vco} V_m}{2 \omega_{ref}} \right) $$

    **物理意义**:
    *   **$V_m$ (纹波幅度)** 越大，杂散越大。 -> 必须减小电荷泵失配和漏电。
    *   **$K_{vco}$ (VCO 增益)** 越大，杂散越大。 -> VCO 越灵敏，对噪声越敏感。
    *   **$\omega_{ref}$ (参考频率)** 越低，杂散越难滤除且幅度相对影响越大。

### 7.5 扩展：小数分频杂散 (Fractional Spurs)

对于小数分频 PLL，分频比 $N$ 是动态变化的。
*   如果分频比序列呈现周期性 (例如 N, N, N+1, N, N, N+1...)，那么 $V_{ctrl}$ 上就会叠加频率为 $f_{ref} \cdot \text{fractional\_part}$ 的纹波。
*   这会在 $\omega_0 \pm (k \cdot \omega_{ref} \cdot \alpha)$ 处产生**小数杂散**。
*   **SDM 的作用**就是打破这种周期性，将集中的杂散能量“涂抹”成宽带噪声。

---

## 8. Logical Effort 实战推导：为什么 NAND2 的 g=4/3?

为了让 NAND 门的下拉能力（两个 NMOS 串联）和反相器（一个 NMOS）一样强，我们需要对晶体管尺寸进行调整。

### 8.1 目标与约束
*   **目标**: 匹配标准反相器的驱动能力（即等效电阻 $R$）。
*   **标准反相器 (Reference Inverter)**:
    *   NMOS 宽度 = 1 (电阻 $R$)
    *   PMOS 宽度 = 2 (电阻 $R$，假设 $\mu_n \approx 2\mu_p$)
    *   **输入电容 $C_{in,inv} = 1 + 2 = 3$**

### 8.2 NAND2 尺寸调整 (Sizing)
*   **下拉网络 (Pull-down Network)**:
    *   结构: 2 个 NMOS 串联。
    *   电阻要求: 总电阻必须为 $R$。
    *   计算: 两个电阻串联 $R_{total} = R_{n1} + R_{n2} = R$。
    *   推导: 每个 NMOS 的电阻必须是 $R/2$。
    *   尺寸: 电阻减半意味着宽度加倍。所以**每个 NMOS 宽度 = 2**。
*   **上拉网络 (Pull-up Network)**:
    *   结构: 2 个 PMOS 并联。
    *   电阻要求: 最坏情况（只有一个 PMOS 导通）电阻必须为 $R$。
    *   推导: 每个 PMOS 的电阻必须是 $R$。
    *   尺寸: 维持标准 PMOS 尺寸。所以**每个 PMOS 宽度 = 2**。

### 8.3 逻辑努力 (Logical Effort) 计算
*   **NAND2 输入电容**:
    *   每个输入端连接着 1 个 NMOS (宽度 2) 和 1 个 PMOS (宽度 2)。
    *   $C_{in,nand} = 2 + 2 = 4$。
*   **结论**:
    $$ g_{nand2} = \frac{C_{in,nand}}{C_{in,inv}} = \frac{4}{3} $$
    这意味着 NAND 门比反相器“费劲” 33%。或者说，为了提供相同的驱动电流，NAND 门呈现给前级的负载电容是反相器的 1.33 倍。

### 8.4 扩展：NOR2 的逻辑努力
同理可推导 2 输入 NOR 门：
*   **上拉 (串联)**: 2 个 PMOS 串联。为了总电阻为 $R$ (单个 PMOS 电阻 $R$)，每个 PMOS 必须是 $R/2$ (宽度 $2 \times 2 = 4$)。
*   **下拉 (并联)**: 2 个 NMOS 并联。每个 NMOS 宽度 = 1。
*   **输入电容**: $C_{in,nor} = 4 + 1 = 5$。
*   **结论**:
    $$ g_{nor2} = \frac{5}{3} $$
    NOR 门比 NAND 门更“慢”（逻辑努力更大），因为 PMOS 本来就慢，串联后为了维持驱动能力需要做得非常巨大。这也是为什么在 CMOS 逻辑设计中，我们更倾向于使用 NAND 逻辑。

---

## 9. TI ADC 时间交织误差校准：自适应滤波器方案

Time-Interleaved (TI) ADC 通过并行使用 $M$ 个子 ADC 来提高总采样率，但子 ADC 之间的不匹配（Mismatch）会引入严重的误差。其中，**时间偏斜 (Timing Skew)** 是最难处理的问题之一。

### 9.1 问题本质：Timing Skew vs. Jitter
首先要区分两个概念：
*   **Random Jitter (随机抖动)**: 采样时刻的随机噪声。这是不可校准的噪声底 (Noise Floor)。
*   **Timing Skew (时间偏斜)**: 由于时钟路径长度不同或驱动能力差异，导致第 $m$ 个子 ADC 的采样时刻总是比理想时刻 $t_k$ 偏离一个固定的量 $\Delta t_m$。
    *   *后果*: 这种周期性的采样误差相当于对输入信号进行了相位调制，会在频谱上产生**杂散 (Spurs)**，位置在 $f_{in} \pm k \cdot f_s/M$。

### 9.2 解决思路：泰勒级数展开与重构
我们无法物理上完美消除 $\Delta t_m$，但可以在数字域通过算法“猜”出如果在正确时刻采样，值应该是多少。

利用 **泰勒级数 (Taylor Series)** 展开：
假设理想采样时刻为 $t$，实际采样时刻为 $t + \Delta t$。
$$ y(t + \Delta t) \approx y(t) + y'(t) \cdot \Delta t + \frac{1}{2}y''(t) \cdot (\Delta t)^2 + \dots $$

我们已知的是实际采样值 $y(t + \Delta t)$，想求的是理想值 $y(t)$。忽略高阶项，反向推导：
$$ y(t) \approx y(t + \Delta t) - y'(t) \cdot \Delta t $$

**核心算法**:
1.  **求导 (Derivative)**: 使用数字 FIR 滤波器（微分器）近似计算输入信号的导数 $y'(t)$。
2.  **加权 (Weighting)**: 将导数乘以时间偏斜量 $\Delta t_m$。
3.  **减法 (Subtraction)**: 从实际采样值中减去这个误差项。

### 9.3 自适应滤波器架构 (LMS Algorithm)
由于 $\Delta t_m$ 是未知的，且会随温度电压漂移，我们需要一个自适应算法来实时追踪它。通常使用 **LMS (Least Mean Squares)** 算法。

**系统框图**:
```text
Input x[n] ----+---------------------> (+) -----> Corrected Output y[n]
(with skew)    |                        ^
               |                        |
               +---> [FIR: d/dt] ---> [X] Gain (estimated skew)
                                        ^
                                        |
                                     [LMS Update Engine]
```

**LMS 更新逻辑**:
我们需要定义一个“误差函数”来指导 LMS。常见的策略有：
1.  **参考 ADC 法 (Reference ADC)**: 使用一个慢速但高精度的 ADC 作为“老师”，让 TI ADC 的输出尽可能接近它。
2.  **盲校准 (Blind Calibration)**: 利用信号的统计特性。
    *   *原理*: 如果没有偏斜，相邻采样点的相关性应该是一致的。如果存在偏斜，某些相邻点会靠得更近（相关性强），某些更远（相关性弱）。LMS 算法调整 $\Delta t$ 直到所有通道的相邻相关性一致。

### 9.4 总结
*   **思想**: 用数字信号处理 (DSP) 补偿模拟电路的缺陷。
*   **代价**: 需要额外的数字电路（FIR 滤波器 + LMS 引擎），增加了功耗和面积。
*   **优势**: 使得超高速 ADC (如 10GS/s+) 成为可能，且对 PVT 变化具有鲁棒性。
