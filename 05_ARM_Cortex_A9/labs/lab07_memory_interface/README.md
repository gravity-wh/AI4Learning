# Lab 7: 存储器接口设计

## 快速参考

### 文件结构
```
lab07_memory_interface/
├── Guide.md              # 详细实验指导
├── README.md             # 本文件
└── src/
    └── axi_master.v      # AXI4 主接口
```

### AXI4 协议通道

| 通道 | 方向 | 用途 |
|------|------|------|
| AW | M→S | 写地址 |
| W | M→S | 写数据 |
| B | S→M | 写响应 |
| AR | M→S | 读地址 |
| R | S→M | 读数据 |

### 接口信号

#### Write Address Channel
| 信号 | 描述 |
|------|------|
| AWADDR | 写地址 |
| AWLEN | 突发长度 |
| AWSIZE | 传输大小 |
| AWBURST | 突发类型 |
| AWVALID/READY | 握手 |

#### Read Address Channel
| 信号 | 描述 |
|------|------|
| ARADDR | 读地址 |
| ARLEN | 突发长度 |
| ARSIZE | 传输大小 |
| ARBURST | 突发类型 |
| ARVALID/READY | 握手 |

### 突发传输

```
Cache Line Fill 配置:
- ARLEN = 7 (8 次传输)
- ARSIZE = 010 (4 字节)
- ARBURST = 01 (INCR)
```

### 状态机

```
IDLE → AR_VALID → R_DATA → DONE → IDLE (读)
IDLE → AW_VALID → W_DATA → B_RESP → DONE → IDLE (写)
```

### 设计要点

1. **握手协议**
   - VALID 先于 READY
   - 传输发生在 VALID && READY

2. **突发传输**
   - WLAST 标记最后一次写
   - RLAST 标记最后一次读

3. **响应处理**
   - OKAY (00): 成功
   - SLVERR (10): 从错误
