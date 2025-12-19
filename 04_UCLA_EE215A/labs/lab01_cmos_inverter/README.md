# Lab 1: CMOS 反相器特性分析 (CMOS Inverter Characterization)

## 实验目标 (Lab Objectives)

*   **理解 CMOS 反相器的基本工作原理**
*   **掌握 SPICE 仿真的基本操作**
*   **分析 CMOS 反相器的直流特性和瞬态响应**
*   **测量关键性能参数如延迟、功耗和噪声容限**

---

## 实验设备与环境 (Equipment & Environment)

*   **仿真工具**: LTspice / Cadence Virtuoso
*   **工艺库**: 180nm CMOS 工艺参数
*   **测试设备**: 无 (纯仿真实验)

---

## 实验步骤 (Lab Procedure)

### 步骤 1: 电路设计与网表编写

创建 CMOS 反相器的 SPICE 网表文件 `inverter.sp`:

```spice
* CMOS Inverter Characterization
* EE215A Lab 1

.include "cmos180nm.lib"

* Power Supply
VDD VDD 0 DC 1.8V
VIN IN 0 PULSE(0 1.8 1n 0.1n 0.1n 10n 20n)

* CMOS Inverter
M1 OUT IN VDD VDD PMOS W=2u L=180n
M2 OUT IN 0 0 NMOS W=1u L=180n

* Load Capacitance
CL OUT 0 100fF

* Analysis Commands
.tran 0.1n 40n
.dc VIN 0 1.8 0.01

.control
run
plot V(OUT) vs V(IN)    ; DC Transfer Characteristic
plot V(OUT) V(IN)       ; Transient Response
.endc

.end
```

### 步骤 2: 直流特性分析 (DC Analysis)

运行直流分析，绘制电压传输特性曲线 (VTC):

1.  **开关阈值 ($V_M$)**: 测量 $V_{in} = V_{out}$ 时的电压值
2.  **噪声容限**:
    *   $NM_H = V_{OH} - V_{IH}$
    *   $NM_L = V_{IL} - V_{OL}$
3.  **增益**: 测量 VTC 曲线最陡峭处的斜率

### 步骤 3: 瞬态响应分析 (Transient Analysis)

输入方波信号，分析瞬态响应:

1.  **传播延迟**:
    *   $t_{PHL}$: 输出从高到低的延迟
    *   $t_{PLH}$: 输出从低到高的延迟
    *   $t_{PD} = (t_{PHL} + t_{PLH})/2$
2.  **上升/下降时间**: 测量输出信号从 10% 到 90% 的时间
3.  **功耗测量**: 计算平均动态功耗

### 步骤 4: 参数扫描分析 (Parameter Sweep)

改变以下参数，观察性能变化:

1.  **负载电容**: $C_L = 10fF, 100fF, 1pF$
2.  **电源电压**: $V_{DD} = 1.2V, 1.8V, 2.5V$
3.  **晶体管尺寸比**: $W_P/W_N = 1, 2, 3$

---

## 实验结果与分析 (Results & Analysis)

### 表格 1: 直流特性参数
| 参数 | 测量值 | 理论值 | 误差分析 |
|------|--------|--------|----------|
| $V_M$ (开关阈值) | | $V_{DD}/2$ | |
| $NM_H$ (高电平噪声容限) | | | |
| $NM_L$ (低电平噪声容限) | | | |
| 最大增益 | | | |

### 表格 2: 瞬态性能参数 ($C_L = 100fF$)
| 参数 | 测量值 | 单位 | 分析 |
|------|--------|------|------|
| $t_{PHL}$ | | ps | |
| $t_{PLH}$ | | ps | |
| $t_{PD}$ (平均延迟) | | ps | |
| 上升时间 | | ps | |
| 下降时间 | | ps | |
| 动态功耗 | | μW | |

### 关键观察与思考

1.  **尺寸比的影响**:
    *   当 $W_P/W_N = 1$ 时，$V_M$ 偏离 $V_{DD}/2$ 的原因？
    *   最优尺寸比是多少？为什么？

2.  **负载电容的影响**:
    *   延迟与负载电容的关系是否线性？
    *   如何通过缓冲器链驱动大电容负载？

3.  **电源电压的影响**:
    *   降低 $V_{DD}$ 对延迟和功耗的影响？
    *   是否存在最优工作电压？

---

## 实验扩展 (Extensions)

### 进阶任务 1: 工艺角分析
在不同工艺角下重复实验:
*   TT (Typical-Typical)
*   FF (Fast-Fast)
*   SS (Slow-Slow)
*   分析工艺变化对性能的影响

### 进阶任务 2: 温度影响分析
在不同温度下仿真:
*   -40°C, 25°C, 85°C, 125°C
*   分析温度对阈值电压和延迟的影响

### 进阶任务 3: 版图设计
使用 Virtuoso 绘制 CMOS 反相器的版图:
*   遵循设计规则检查 (DRC)
*   提取寄生参数进行后仿真
*   对比前仿真和后仿真的结果差异

---

## 实验报告要求 (Report Requirements)

1.  **实验数据**: 完整的测量表格和曲线图
2.  **结果分析**: 对观察到的现象进行物理解释
3.  **误差分析**: 讨论测量值与理论值的差异原因
4.  **结论总结**: 总结 CMOS 反相器的关键特性和设计考虑
5.  **思考题回答**: 回答实验中的思考引导问题

---

## 参考资料 (References)

1.  Kang & Leblebici, "CMOS Digital Integrated Circuits"
2.  Rabaey et al., "Digital Integrated Circuits"
3.  LTspice User Guide
4.  Cadence Virtuoso Tutorial

---

*实验完成时间估计: 4-6 小时*
*难度等级: ★★☆☆☆ (入门级)*