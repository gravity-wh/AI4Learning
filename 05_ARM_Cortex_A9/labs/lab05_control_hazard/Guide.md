# Lab 5: 控制单元与冒险处理

## 📋 实验概述

| 项目 | 内容 |
|------|------|
| **实验名称** | 控制单元与冒险处理设计 |
| **预计时长** | 8-10 小时 |
| **难度等级** | ⭐⭐⭐⭐☆ |
| **前置实验** | Lab 1-4 |

## 🎯 实验目标

1. 实现流水线冒险检测单元
2. 设计数据前递单元
3. 实现流水线暂停与冲刷控制
4. 理解控制冒险的处理策略

---

## 📚 理论背景

### 流水线冒险类型

#### 1. 结构冒险 (Structural Hazard)
硬件资源冲突，本设计通过分离 I-Cache 和 D-Cache 避免。

#### 2. 数据冒险 (Data Hazard)

```
RAW (Read After Write) - 最常见
    ADD R1, R2, R3    @ 写 R1
    SUB R4, R1, R5    @ 读 R1 (需要前递)

解决方案:
    ┌─────┐   ┌─────┐   ┌─────┐   ┌─────┐   ┌─────┐
    │ IF  │──▶│ ID  │──▶│ EX  │──▶│ MEM │──▶│ WB  │
    └─────┘   └─────┘   └─────┘   └─────┘   └─────┘
                            │         │
                            └────┬────┘
                                 │ 前递
                                 ▼
                              ┌─────┐
                              │ EX  │
                              └─────┘
```

#### 3. Load-Use 冒险

```
    LDR R1, [R2]      @ 从内存加载 R1
    ADD R3, R1, R4    @ 使用 R1 (必须暂停一周期)
    
解决方案: 插入一个气泡 (bubble)
    
    周期:    1     2     3     4     5     6     7
    LDR:    IF    ID    EX   MEM    WB
    ADD:          IF    ID  stall   EX   MEM    WB
```

#### 4. 控制冒险 (Control Hazard)

```
    BEQ label         @ 分支指令
    ADD R1, R2, R3    @ 可能被冲刷
    SUB R4, R5, R6    @ 可能被冲刷
    
解决方案:
    1. 分支预测
    2. 分支延迟槽
    3. 分支冲刷 (本设计采用)
```

### 前递条件

```verilog
// EX 冒险 (MEM→EX 前递)
if (MEM_RegWrite && 
    (MEM_Rd != 0) && 
    (MEM_Rd == EX_Rn))
    ForwardA = 2'b01;  // 从 MEM 前递

// MEM 冒险 (WB→EX 前递)
if (WB_RegWrite && 
    (WB_Rd != 0) && 
    !(MEM_RegWrite && (MEM_Rd != 0) && (MEM_Rd == EX_Rn)) &&
    (WB_Rd == EX_Rn))
    ForwardA = 2'b10;  // 从 WB 前递
```

### Load-Use 检测

```verilog
// 检测 Load-Use 冒险
stall = EX_MemRead && 
        ((EX_Rd == ID_Rn) || (EX_Rd == ID_Rm));
```

---

## 📝 代码实现

详见 `src/hazard_unit.v` 和 `src/forwarding_unit.v`

---

## ✅ 检查点

- [ ] 数据前递正确工作
- [ ] Load-Use 冒险正确检测
- [ ] 流水线暂停逻辑正确
- [ ] 分支冲刷正确执行
- [ ] 无死锁情况

---

## 🔗 下一步

完成本实验后，继续 **Lab 6: 缓存系统设计**。
