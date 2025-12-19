# Lab 6: 缓存系统设计

## 快速参考

### 文件结构
```
lab06_cache_system/
├── Guide.md              # 详细实验指导
├── README.md             # 本文件
└── src/
    ├── icache.v          # 指令缓存 (直接映射)
    └── dcache.v          # 数据缓存 (2路组相联)
```

### 模块规格

#### I-Cache (icache.v)
| 参数 | 值 | 描述 |
|------|------|------|
| 容量 | 4KB | 总容量 |
| 行大小 | 32B | 8 个字 |
| 组织 | 直接映射 | 1 路 |
| 行数 | 128 | 4KB / 32B |

#### D-Cache (dcache.v)
| 参数 | 值 | 描述 |
|------|------|------|
| 容量 | 4KB | 总容量 |
| 行大小 | 32B | 8 个字 |
| 组织 | 2路组相联 | 每路 2KB |
| 写策略 | Write-Back | 脏位控制 |
| 替换 | LRU | 最近最少使用 |

### 接口说明

| 端口 | 方向 | 描述 |
|------|------|------|
| req | input | 访问请求 |
| we | input | 写使能 (D-Cache) |
| addr | input | 访问地址 |
| rdata | output | 读数据 |
| hit | output | 命中标志 |
| ready | output | 就绪标志 |
| mem_* | both | 内存接口 |

### 状态机

```
IDLE → COMPARE → [hit] → IDLE
              → [miss] → WRITEBACK* → ALLOCATE → FILL → DONE → IDLE
              
* WRITEBACK 仅当需要写回脏行
```

### 设计要点

1. **地址分解**
   - Tag: 高位
   - Index: 中间位
   - Offset: 低位

2. **Cache Line Fill**
   - 突发传输 8 个字
   - 关键字优先 (可选)

3. **LRU 实现**
   - 2路只需 1 位 LRU
   - 命中时更新 LRU
