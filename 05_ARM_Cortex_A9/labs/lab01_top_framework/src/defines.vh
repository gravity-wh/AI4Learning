// ============================================================================
// File: defines.vh
// Description: Global definitions for ARM Cortex-A9 HDL implementation
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`ifndef _DEFINES_VH_
`define _DEFINES_VH_

// ============================================================================
// 基本参数
// ============================================================================
`define DATA_WIDTH      32
`define ADDR_WIDTH      32
`define REG_ADDR_WIDTH  4       // 16 个通用寄存器 (R0-R15)
`define REG_NUM         16
`define INST_WIDTH      32

// ============================================================================
// 特殊寄存器编号
// ============================================================================
`define REG_SP          4'd13   // Stack Pointer
`define REG_LR          4'd14   // Link Register
`define REG_PC          4'd15   // Program Counter

// ============================================================================
// ALU 操作码 (ARM Data Processing Instructions)
// ============================================================================
`define ALU_AND     4'b0000     // Rd = Rn AND Op2
`define ALU_EOR     4'b0001     // Rd = Rn EOR Op2
`define ALU_SUB     4'b0010     // Rd = Rn - Op2
`define ALU_RSB     4'b0011     // Rd = Op2 - Rn
`define ALU_ADD     4'b0100     // Rd = Rn + Op2
`define ALU_ADC     4'b0101     // Rd = Rn + Op2 + C
`define ALU_SBC     4'b0110     // Rd = Rn - Op2 - NOT(C)
`define ALU_RSC     4'b0111     // Rd = Op2 - Rn - NOT(C)
`define ALU_TST     4'b1000     // Set flags on Rn AND Op2
`define ALU_TEQ     4'b1001     // Set flags on Rn EOR Op2
`define ALU_CMP     4'b1010     // Set flags on Rn - Op2
`define ALU_CMN     4'b1011     // Set flags on Rn + Op2
`define ALU_ORR     4'b1100     // Rd = Rn OR Op2
`define ALU_MOV     4'b1101     // Rd = Op2
`define ALU_BIC     4'b1110     // Rd = Rn AND NOT Op2
`define ALU_MVN     4'b1111     // Rd = NOT Op2

// ============================================================================
// 移位类型
// ============================================================================
`define SHIFT_LSL   2'b00       // Logical Shift Left
`define SHIFT_LSR   2'b01       // Logical Shift Right
`define SHIFT_ASR   2'b10       // Arithmetic Shift Right
`define SHIFT_ROR   2'b11       // Rotate Right

// ============================================================================
// 条件码 (Condition Codes)
// ============================================================================
`define COND_EQ     4'b0000     // Equal (Z=1)
`define COND_NE     4'b0001     // Not Equal (Z=0)
`define COND_CS     4'b0010     // Carry Set / Unsigned Higher or Same (C=1)
`define COND_CC     4'b0011     // Carry Clear / Unsigned Lower (C=0)
`define COND_MI     4'b0100     // Minus / Negative (N=1)
`define COND_PL     4'b0101     // Plus / Positive or Zero (N=0)
`define COND_VS     4'b0110     // Overflow Set (V=1)
`define COND_VC     4'b0111     // Overflow Clear (V=0)
`define COND_HI     4'b1000     // Unsigned Higher (C=1 and Z=0)
`define COND_LS     4'b1001     // Unsigned Lower or Same (C=0 or Z=1)
`define COND_GE     4'b1010     // Signed Greater or Equal (N=V)
`define COND_LT     4'b1011     // Signed Less Than (N!=V)
`define COND_GT     4'b1100     // Signed Greater Than (Z=0 and N=V)
`define COND_LE     4'b1101     // Signed Less or Equal (Z=1 or N!=V)
`define COND_AL     4'b1110     // Always
`define COND_NV     4'b1111     // Never (Reserved in ARMv7)

// ============================================================================
// 指令类型编码
// ============================================================================
`define INST_TYPE_DP    3'b000  // Data Processing
`define INST_TYPE_MUL   3'b001  // Multiply / Multiply-Accumulate
`define INST_TYPE_SDT   3'b010  // Single Data Transfer (LDR/STR)
`define INST_TYPE_BDT   3'b011  // Block Data Transfer (LDM/STM)
`define INST_TYPE_BR    3'b100  // Branch / Branch with Link
`define INST_TYPE_SWI   3'b101  // Software Interrupt
`define INST_TYPE_CDP   3'b110  // Coprocessor Data Processing
`define INST_TYPE_UND   3'b111  // Undefined

// ============================================================================
// Load/Store 控制信号
// ============================================================================
`define LS_BYTE         2'b00   // Byte access
`define LS_HALF         2'b01   // Halfword access
`define LS_WORD         2'b10   // Word access

// ============================================================================
// Cache 参数
// ============================================================================
`define CACHE_SIZE          4096    // 4KB Cache
`define CACHE_LINE_SIZE     16      // 16 bytes per cache line
`define CACHE_NUM_LINES     256     // CACHE_SIZE / CACHE_LINE_SIZE
`define CACHE_WAYS          1       // Direct-mapped
`define CACHE_INDEX_WIDTH   8       // log2(CACHE_NUM_LINES)
`define CACHE_OFFSET_WIDTH  4       // log2(CACHE_LINE_SIZE)
`define CACHE_TAG_WIDTH     20      // 32 - INDEX - OFFSET

// ============================================================================
// AXI-Lite 接口参数
// ============================================================================
`define AXI_RESP_OKAY       2'b00
`define AXI_RESP_EXOKAY     2'b01
`define AXI_RESP_SLVERR     2'b10
`define AXI_RESP_DECERR     2'b11

// ============================================================================
// 前递控制信号编码
// ============================================================================
`define FWD_NONE        2'b00   // No forwarding, use register file
`define FWD_MEM         2'b01   // Forward from MEM stage
`define FWD_WB          2'b10   // Forward from WB stage

// ============================================================================
// 流水线控制
// ============================================================================
`define NOP_INSTRUCTION 32'hE1A00000  // MOV R0, R0 (No operation)

// ============================================================================
// 处理器模式 (CPSR[4:0])
// ============================================================================
`define MODE_USER       5'b10000    // User mode
`define MODE_FIQ        5'b10001    // FIQ mode
`define MODE_IRQ        5'b10010    // IRQ mode
`define MODE_SVC        5'b10011    // Supervisor mode
`define MODE_ABT        5'b10111    // Abort mode
`define MODE_UND        5'b11011    // Undefined mode
`define MODE_SYS        5'b11111    // System mode

// ============================================================================
// CPSR 位域定义
// ============================================================================
`define CPSR_N          31          // Negative flag
`define CPSR_Z          30          // Zero flag
`define CPSR_C          29          // Carry flag
`define CPSR_V          28          // Overflow flag
`define CPSR_Q          27          // Sticky overflow (DSP)
`define CPSR_I          7           // IRQ disable
`define CPSR_F          6           // FIQ disable
`define CPSR_T          5           // Thumb state

// ============================================================================
// 仿真参数
// ============================================================================
`define SIM_DELAY       1           // 仿真延迟 (用于调试)

`endif // _DEFINES_VH_
