# Lab 5: 控制单元与冒险处理

## 快速参考

### 文件结构
```
lab05_control_hazard/
├── Guide.md              # 详细实验指导
├── README.md             # 本文件
└── src/
    ├── hazard_unit.v     # 冒险检测单元
    └── forwarding_unit.v # 数据前递单元
```

### 模块功能

#### hazard_unit.v
- 检测 Load-Use 冒险
- 生成流水线暂停信号
- 生成分支冲刷信号

#### forwarding_unit.v
- 检测数据相关
- 生成前递选择信号

### 接口说明

#### Hazard Unit
| 端口 | 方向 | 描述 |
|------|------|------|
| id_rn/rm/rs | input | ID 阶段源寄存器 |
| ex_rd | input | EX 阶段目的寄存器 |
| ex_mem_read | input | EX 阶段 Load 指令 |
| branch_taken | input | 分支执行 |
| stall_if/id | output | 暂停控制 |
| flush_if/id/ex | output | 冲刷控制 |

#### Forwarding Unit
| 端口 | 方向 | 描述 |
|------|------|------|
| ex_rn/rm | input | EX 阶段源寄存器 |
| mem_rd | input | MEM 阶段目的寄存器 |
| wb_rd | input | WB 阶段目的寄存器 |
| forward_a/b | output | 前递选择 |

### 设计要点

1. **Load-Use 检测**
   ```
   stall = EX_MemRead && (EX_Rd == ID_Rn || EX_Rd == ID_Rm)
   ```

2. **前递优先级**
   - MEM→EX 优先于 WB→EX
   - 最新的数据优先

3. **分支处理**
   - 分支在 EX 阶段确定
   - 冲刷 IF 和 ID 阶段
