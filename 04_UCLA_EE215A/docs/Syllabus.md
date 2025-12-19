# Course 4: UCLA EE215A - Introduction to Digital Integrated Circuits (数字集成电路导论)

## 课程愿景 (Course Vision)
本课程对标 **UCLA EE215A**，作为数字集成电路设计的入门课程，重点培养学生对 CMOS 电路基础、逻辑门设计和基本时序分析的理解。课程采用从晶体管到逻辑门的系统方法，为后续高级数字 IC 设计打下坚实基础。

> **核心哲学**: "Understanding begins at the transistor level." —— 真正的数字设计始于对晶体管行为的深刻理解。

---

## 课程大纲 (Syllabus)

### Module 1: CMOS 基础与制造工艺 (Weeks 1-3)
**关键词**: *MOSFET Physics, CMOS Process, Layout*
*   **核心内容**:
    *   **MOSFET 物理基础**: 增强型 vs 耗尽型 MOSFET，阈值电压，沟道形成。
    *   **CMOS 制造工艺**: 光刻、刻蚀、掺杂、金属化等基本步骤。
    *   **版图设计基础**: 晶体管、接触孔、金属线的物理实现。
    *   **SPICE 仿真入门**: 使用 SPICE 验证简单 CMOS 电路。
*   **💡 思考引导**:
    *   为什么 CMOS 技术能够成为现代数字电路的主流？
    *   晶体管尺寸缩小的物理极限是什么？

### Module 2: CMOS 反相器与基本逻辑门 (Weeks 4-6)
**关键词**: *CMOS Inverter, NAND, NOR, Transmission Gate*
*   **核心内容**:
    *   **CMOS 反相器**: 电压传输特性 (VTC)，噪声容限，开关阈值。
    *   **组合逻辑门**: CMOS NAND、NOR 门的结构与工作原理。
    *   **传输门 (Transmission Gate)**: 双向开关特性及其在逻辑设计中的应用。
    *   **复合门设计**: AOI (AND-OR-INVERT) 和 OAI (OR-AND-INVERT) 结构。
*   **💡 思考引导**:
    *   为什么 CMOS 反相器在静态功耗方面优于其他逻辑系列？
    *   传输门相比单个 NMOS 传输管的优势是什么？

### Module 3: 时序电路与寄存器 (Weeks 7-9)
**关键词**: *Sequential Circuits, Latches, Flip-Flops, Timing*
*   **核心内容**:
    *   **锁存器 (Latches)**: SR 锁存器、D 锁存器的 CMOS 实现。
    *   **触发器 (Flip-Flops)**: 主从 D 触发器、边沿触发器的设计。
    *   **时序参数**: 建立时间 (Setup Time)、保持时间 (Hold Time)、时钟到输出延迟。
    *   **时序约束**: 最大时钟频率的计算与分析。
*   **💡 思考引导**:
    *   为什么现代设计普遍使用边沿触发器而不是电平敏感锁存器？
    *   建立时间和保持时间违例分别会导致什么问题？

### Module 4: 互连线与延迟建模 (Weeks 10-11)
**关键词**: *Interconnect, RC Delay, Elmore Delay, Wire Engineering*
*   **核心内容**:
    *   **互连线寄生**: 电阻、电容、电感对信号传输的影响。
    *   **延迟建模**: 集总 RC 模型、分布 RC 模型、Elmore 延迟计算。
    *   **连线优化**: 缓冲器插入、线宽优化、屏蔽技术。
    *   **串扰 (Crosstalk)**: 相邻信号线之间的电容耦合效应。
*   **💡 思考引导**:
    *   在深亚微米工艺下，为什么连线延迟开始主导门延迟？
    *   如何通过缓冲器插入来优化长连线的延迟？

### Module 5: 功耗分析与低功耗技术 (Weeks 12-13)
**关键词**: *Power Dissipation, Dynamic Power, Static Power, Low-Power*
*   **核心内容**:
    *   **功耗组成**: 动态功耗 ($P_{dynamic} = αCV^2f$)、短路功耗、静态功耗。
    *   **低功耗技术**: 时钟门控、电源门控、多阈值电压技术。
    *   **功耗优化**: 电压缩放、频率缩放、活动因子优化。
    *   **热管理**: 功耗密度与芯片散热的关系。
*   **💡 思考引导**:
    *   为什么降低供电电压是减少动态功耗最有效的方法？
    *   时钟门控如何在不影响功能的前提下降低功耗？

---

## 推荐实验项目 (Labs)

1.  **Lab 1: CMOS 反相器特性分析** - 使用 SPICE 仿真 CMOS 反相器的电压传输特性和瞬态响应。
2.  **Lab 2: 基本逻辑门设计** - 设计并仿真 CMOS NAND、NOR 门，验证其逻辑功能。
3.  **Lab 3: D 触发器设计** - 实现主从 D 触发器，分析其时序参数。
4.  **Lab 4: 简单数字电路综合** - 设计一个小型组合逻辑电路，进行版图设计和后仿真。

---

## 顶级学习资源 (Top-Tier Resources)

### 1. 经典教材 (The Bibles)
*   **CMOS Digital Integrated Circuits: Analysis and Design** (Sung-Mo Kang & Yusuf Leblebici) - *UCLA EE215A 推荐教材，理论与实践结合。*
*   **Digital Integrated Circuits: A Design Perspective** (Jan Rabaey) - *Berkeley 经典，物理直觉培养。*

### 2. 公开课 (Open Courseware)
*   **UCLA EE215A (Introduction to Digital ICs)**:
    *   *特点*: 系统性的入门课程，强调从晶体管到系统的完整设计流程。
    *   *资源*: 关注 UCLA ECE 部门的公开教学资源。
*   **MIT 6.002 (Circuits and Electronics)**:
    *   *特点*: 电路基础扎实，为数字 IC 设计提供坚实的模拟基础。

### 3. 仿真工具 (Simulation Tools)
*   **LTspice**: 免费的 SPICE 仿真工具，适合入门学习。
*   **Cadence Virtuoso**: 工业级 IC 设计工具套件。

---

## 考核方式 (Grading)

*   **作业 (30%)**: 每周电路设计与分析练习
*   **实验 (30%)**: 4个动手实验项目
*   **期中考试 (20%)**: 覆盖 Module 1-3
*   **期末考试 (20%)**: 综合考核

---

*本课程材料基于 UCLA EE215A 课程框架创建，遵循从基础到应用的系统性学习方法。*