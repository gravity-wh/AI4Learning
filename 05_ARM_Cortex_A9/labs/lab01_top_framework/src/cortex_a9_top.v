// ============================================================================
// File: cortex_a9_top.v
// Description: Top-level module for simplified ARM Cortex-A9 processor core
//              5-stage pipeline: IF -> ID -> EX -> MEM -> WB
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// Reference: ARM Cortex-A9 Technical Reference Manual (DDI0388)
// ============================================================================

`include "defines.vh"

module cortex_a9_top #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     clk,            // 系统时钟
    input  wire                     rst_n,          // 异步复位，低有效
    
    // ========================================================================
    // 指令存储器接口 (Instruction Memory / I-Cache)
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]    imem_addr,      // 指令地址
    output wire                     imem_rd_en,     // 读使能
    input  wire [DATA_WIDTH-1:0]    imem_rd_data,   // 读取的指令
    input  wire                     imem_rd_valid,  // 指令有效
    
    // ========================================================================
    // 数据存储器接口 (Data Memory / D-Cache)
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]    dmem_addr,      // 数据地址
    output wire [DATA_WIDTH-1:0]    dmem_wr_data,   // 写数据
    output wire                     dmem_wr_en,     // 写使能
    output wire                     dmem_rd_en,     // 读使能
    output wire [3:0]               dmem_byte_en,   // 字节使能
    input  wire [DATA_WIDTH-1:0]    dmem_rd_data,   // 读数据
    input  wire                     dmem_rd_valid,  // 读数据有效
    
    // ========================================================================
    // 中断接口
    // ========================================================================
    input  wire                     irq_n,          // IRQ 中断请求，低有效
    input  wire                     fiq_n,          // FIQ 快速中断，低有效
    
    // ========================================================================
    // 调试接口
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]    debug_pc,       // 当前 PC 值
    output wire [DATA_WIDTH-1:0]    debug_instr,    // 当前指令
    output wire [3:0]               debug_cpsr_flags, // NZCV 标志
    output wire                     debug_halted    // 处理器暂停标志
);

    // ========================================================================
    // 内部信号声明 - IF Stage
    // ========================================================================
    wire [ADDR_WIDTH-1:0]   if_pc;              // 当前 PC
    wire [ADDR_WIDTH-1:0]   if_pc_next;         // 下一条 PC
    wire [DATA_WIDTH-1:0]   if_instruction;     // 取到的指令
    wire                    if_valid;           // IF 阶段有效
    
    // ========================================================================
    // 内部信号声明 - IF/ID Pipeline Register
    // ========================================================================
    reg  [ADDR_WIDTH-1:0]   id_pc_r;
    reg  [DATA_WIDTH-1:0]   id_instruction_r;
    reg                     id_valid_r;
    
    // ========================================================================
    // 内部信号声明 - ID Stage
    // ========================================================================
    wire [3:0]              id_cond;            // 条件码
    wire [1:0]              id_op;              // 操作类型
    wire [3:0]              id_opcode;          // ALU 操作码
    wire                    id_imm_flag;        // 立即数标志
    wire                    id_s_flag;          // 更新标志位
    wire [3:0]              id_rn;              // 源寄存器 1
    wire [3:0]              id_rd;              // 目的寄存器
    wire [3:0]              id_rs;              // 移位寄存器
    wire [3:0]              id_rm;              // 源寄存器 2
    wire [11:0]             id_imm12;           // 12位立即数
    wire [23:0]             id_offset24;        // 分支偏移量
    
    // ID Stage - Register File Outputs
    wire [DATA_WIDTH-1:0]   id_rn_data;         // Rn 数据
    wire [DATA_WIDTH-1:0]   id_rm_data;         // Rm 数据
    wire [DATA_WIDTH-1:0]   id_rs_data;         // Rs 数据
    
    // ID Stage - Control Signals
    wire                    id_reg_write;       // 寄存器写使能
    wire                    id_mem_read;        // 内存读
    wire                    id_mem_write;       // 内存写
    wire                    id_branch;          // 分支指令
    wire                    id_branch_link;     // 带链接分支
    wire                    id_alu_src;         // ALU 源选择
    wire                    id_mem_to_reg;      // 内存到寄存器
    wire [3:0]              id_alu_op;          // ALU 操作
    wire [1:0]              id_shift_type;      // 移位类型
    wire [4:0]              id_shift_amount;    // 移位量
    
    // ========================================================================
    // 内部信号声明 - ID/EX Pipeline Register
    // ========================================================================
    reg  [ADDR_WIDTH-1:0]   ex_pc_r;
    reg  [DATA_WIDTH-1:0]   ex_rn_data_r;
    reg  [DATA_WIDTH-1:0]   ex_rm_data_r;
    reg  [DATA_WIDTH-1:0]   ex_rs_data_r;
    reg  [DATA_WIDTH-1:0]   ex_imm_ext_r;
    reg  [3:0]              ex_rd_r;
    reg  [3:0]              ex_rn_addr_r;
    reg  [3:0]              ex_rm_addr_r;
    reg                     ex_reg_write_r;
    reg                     ex_mem_read_r;
    reg                     ex_mem_write_r;
    reg                     ex_branch_r;
    reg                     ex_branch_link_r;
    reg                     ex_alu_src_r;
    reg                     ex_mem_to_reg_r;
    reg                     ex_s_flag_r;
    reg  [3:0]              ex_alu_op_r;
    reg  [1:0]              ex_shift_type_r;
    reg  [4:0]              ex_shift_amount_r;
    reg  [3:0]              ex_cond_r;
    reg                     ex_valid_r;
    
    // ========================================================================
    // 内部信号声明 - EX Stage
    // ========================================================================
    wire [DATA_WIDTH-1:0]   ex_alu_operand_a;   // ALU 操作数 A
    wire [DATA_WIDTH-1:0]   ex_alu_operand_b;   // ALU 操作数 B
    wire [DATA_WIDTH-1:0]   ex_shifted_operand; // 移位后的操作数
    wire [DATA_WIDTH-1:0]   ex_alu_result;      // ALU 结果
    wire                    ex_alu_n;           // Negative flag
    wire                    ex_alu_z;           // Zero flag
    wire                    ex_alu_c;           // Carry flag
    wire                    ex_alu_v;           // Overflow flag
    wire                    ex_cond_pass;       // 条件通过
    wire                    ex_branch_taken;    // 分支执行
    wire [ADDR_WIDTH-1:0]   ex_branch_target;   // 分支目标
    
    // ========================================================================
    // 内部信号声明 - EX/MEM Pipeline Register
    // ========================================================================
    reg  [DATA_WIDTH-1:0]   mem_alu_result_r;
    reg  [DATA_WIDTH-1:0]   mem_write_data_r;
    reg  [3:0]              mem_rd_r;
    reg                     mem_reg_write_r;
    reg                     mem_mem_read_r;
    reg                     mem_mem_write_r;
    reg                     mem_mem_to_reg_r;
    reg                     mem_valid_r;
    
    // ========================================================================
    // 内部信号声明 - MEM Stage
    // ========================================================================
    wire [DATA_WIDTH-1:0]   mem_read_data;      // 内存读取数据
    
    // ========================================================================
    // 内部信号声明 - MEM/WB Pipeline Register
    // ========================================================================
    reg  [DATA_WIDTH-1:0]   wb_alu_result_r;
    reg  [DATA_WIDTH-1:0]   wb_mem_data_r;
    reg  [3:0]              wb_rd_r;
    reg                     wb_reg_write_r;
    reg                     wb_mem_to_reg_r;
    reg                     wb_valid_r;
    
    // ========================================================================
    // 内部信号声明 - WB Stage
    // ========================================================================
    wire [DATA_WIDTH-1:0]   wb_write_data;      // 写回数据
    
    // ========================================================================
    // 内部信号声明 - Hazard & Forwarding
    // ========================================================================
    wire                    stall_if;           // IF 阶段暂停
    wire                    stall_id;           // ID 阶段暂停
    wire                    flush_if;           // IF 阶段冲刷
    wire                    flush_id;           // ID 阶段冲刷
    wire                    flush_ex;           // EX 阶段冲刷
    wire [1:0]              forward_a;          // 操作数 A 前递选择
    wire [1:0]              forward_b;          // 操作数 B 前递选择
    
    // ========================================================================
    // 内部信号声明 - CPSR (Current Program Status Register)
    // ========================================================================
    reg  [31:0]             cpsr_r;
    wire                    cpsr_n, cpsr_z, cpsr_c, cpsr_v;
    
    // ========================================================================
    // IF Stage - Fetch Unit
    // ========================================================================
    fetch_unit #(
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH)
    ) u_fetch_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        // Control
        .stall          (stall_if),
        .flush          (flush_if),
        .branch_taken   (ex_branch_taken),
        .branch_target  (ex_branch_target),
        // Outputs
        .pc             (if_pc),
        .pc_next        (if_pc_next),
        // Memory interface
        .imem_addr      (imem_addr),
        .imem_rd_en     (imem_rd_en),
        .imem_rd_data   (imem_rd_data),
        .imem_rd_valid  (imem_rd_valid),
        // Instruction output
        .instruction    (if_instruction),
        .valid          (if_valid)
    );
    
    // ========================================================================
    // IF/ID Pipeline Register
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_pc_r          <= {ADDR_WIDTH{1'b0}};
            id_instruction_r <= `NOP_INSTRUCTION;
            id_valid_r       <= 1'b0;
        end else if (flush_id) begin
            id_pc_r          <= {ADDR_WIDTH{1'b0}};
            id_instruction_r <= `NOP_INSTRUCTION;
            id_valid_r       <= 1'b0;
        end else if (!stall_id) begin
            id_pc_r          <= if_pc;
            id_instruction_r <= if_instruction;
            id_valid_r       <= if_valid;
        end
        // stall_id 时保持不变
    end
    
    // ========================================================================
    // ID Stage - Instruction Decoder
    // ========================================================================
    decoder u_decoder (
        .instruction    (id_instruction_r),
        // Instruction fields
        .cond           (id_cond),
        .op             (id_op),
        .opcode         (id_opcode),
        .imm_flag       (id_imm_flag),
        .s_flag         (id_s_flag),
        .rn             (id_rn),
        .rd             (id_rd),
        .rs             (id_rs),
        .rm             (id_rm),
        .imm12          (id_imm12),
        .offset24       (id_offset24),
        // Control signals
        .reg_write      (id_reg_write),
        .mem_read       (id_mem_read),
        .mem_write      (id_mem_write),
        .branch         (id_branch),
        .branch_link    (id_branch_link),
        .alu_src        (id_alu_src),
        .mem_to_reg     (id_mem_to_reg),
        .alu_op         (id_alu_op),
        .shift_type     (id_shift_type),
        .shift_amount   (id_shift_amount)
    );
    
    // ========================================================================
    // ID Stage - Register File
    // ========================================================================
    register_file #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (4),
        .NUM_REGS       (16)
    ) u_register_file (
        .clk            (clk),
        .rst_n          (rst_n),
        // Read ports
        .rd_addr_1      (id_rn),
        .rd_addr_2      (id_rm),
        .rd_addr_3      (id_rs),
        .rd_data_1      (id_rn_data),
        .rd_data_2      (id_rm_data),
        .rd_data_3      (id_rs_data),
        // Write port
        .wr_en          (wb_reg_write_r & wb_valid_r),
        .wr_addr        (wb_rd_r),
        .wr_data        (wb_write_data),
        // PC (R15) access
        .pc             (if_pc)
    );
    
    // ========================================================================
    // ID/EX Pipeline Register
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_pc_r           <= {ADDR_WIDTH{1'b0}};
            ex_rn_data_r      <= {DATA_WIDTH{1'b0}};
            ex_rm_data_r      <= {DATA_WIDTH{1'b0}};
            ex_rs_data_r      <= {DATA_WIDTH{1'b0}};
            ex_imm_ext_r      <= {DATA_WIDTH{1'b0}};
            ex_rd_r           <= 4'b0;
            ex_rn_addr_r      <= 4'b0;
            ex_rm_addr_r      <= 4'b0;
            ex_reg_write_r    <= 1'b0;
            ex_mem_read_r     <= 1'b0;
            ex_mem_write_r    <= 1'b0;
            ex_branch_r       <= 1'b0;
            ex_branch_link_r  <= 1'b0;
            ex_alu_src_r      <= 1'b0;
            ex_mem_to_reg_r   <= 1'b0;
            ex_s_flag_r       <= 1'b0;
            ex_alu_op_r       <= 4'b0;
            ex_shift_type_r   <= 2'b0;
            ex_shift_amount_r <= 5'b0;
            ex_cond_r         <= `COND_AL;
            ex_valid_r        <= 1'b0;
        end else if (flush_ex) begin
            ex_reg_write_r    <= 1'b0;
            ex_mem_read_r     <= 1'b0;
            ex_mem_write_r    <= 1'b0;
            ex_branch_r       <= 1'b0;
            ex_valid_r        <= 1'b0;
        end else if (!stall_id) begin
            ex_pc_r           <= id_pc_r;
            ex_rn_data_r      <= id_rn_data;
            ex_rm_data_r      <= id_rm_data;
            ex_rs_data_r      <= id_rs_data;
            ex_imm_ext_r      <= {{20{id_imm12[11]}}, id_imm12};  // Sign-extend
            ex_rd_r           <= id_rd;
            ex_rn_addr_r      <= id_rn;
            ex_rm_addr_r      <= id_rm;
            ex_reg_write_r    <= id_reg_write;
            ex_mem_read_r     <= id_mem_read;
            ex_mem_write_r    <= id_mem_write;
            ex_branch_r       <= id_branch;
            ex_branch_link_r  <= id_branch_link;
            ex_alu_src_r      <= id_alu_src;
            ex_mem_to_reg_r   <= id_mem_to_reg;
            ex_s_flag_r       <= id_s_flag;
            ex_alu_op_r       <= id_alu_op;
            ex_shift_type_r   <= id_shift_type;
            ex_shift_amount_r <= id_shift_amount;
            ex_cond_r         <= id_cond;
            ex_valid_r        <= id_valid_r;
        end
    end
    
    // ========================================================================
    // EX Stage - Execute Unit
    // ========================================================================
    execute_unit #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH)
    ) u_execute_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        // Data inputs
        .rn_data        (ex_rn_data_r),
        .rm_data        (ex_rm_data_r),
        .rs_data        (ex_rs_data_r),
        .imm_data       (ex_imm_ext_r),
        .pc             (ex_pc_r),
        // Control inputs
        .alu_op         (ex_alu_op_r),
        .alu_src        (ex_alu_src_r),
        .shift_type     (ex_shift_type_r),
        .shift_amount   (ex_shift_amount_r),
        .carry_in       (cpsr_c),
        .cond           (ex_cond_r),
        .cpsr_flags     ({cpsr_n, cpsr_z, cpsr_c, cpsr_v}),
        .branch         (ex_branch_r),
        .branch_link    (ex_branch_link_r),
        // Forwarding
        .forward_a      (forward_a),
        .forward_b      (forward_b),
        .mem_fwd_data   (mem_alu_result_r),
        .wb_fwd_data    (wb_write_data),
        // Outputs
        .alu_result     (ex_alu_result),
        .shifted_op     (ex_shifted_operand),
        .alu_n          (ex_alu_n),
        .alu_z          (ex_alu_z),
        .alu_c          (ex_alu_c),
        .alu_v          (ex_alu_v),
        .cond_pass      (ex_cond_pass),
        .branch_taken   (ex_branch_taken),
        .branch_target  (ex_branch_target)
    );
    
    // ========================================================================
    // EX/MEM Pipeline Register
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_alu_result_r  <= {DATA_WIDTH{1'b0}};
            mem_write_data_r  <= {DATA_WIDTH{1'b0}};
            mem_rd_r          <= 4'b0;
            mem_reg_write_r   <= 1'b0;
            mem_mem_read_r    <= 1'b0;
            mem_mem_write_r   <= 1'b0;
            mem_mem_to_reg_r  <= 1'b0;
            mem_valid_r       <= 1'b0;
        end else begin
            mem_alu_result_r  <= ex_alu_result;
            mem_write_data_r  <= ex_rm_data_r;  // Store data
            mem_rd_r          <= ex_rd_r;
            mem_reg_write_r   <= ex_reg_write_r & ex_cond_pass;
            mem_mem_read_r    <= ex_mem_read_r & ex_cond_pass;
            mem_mem_write_r   <= ex_mem_write_r & ex_cond_pass;
            mem_mem_to_reg_r  <= ex_mem_to_reg_r;
            mem_valid_r       <= ex_valid_r & ex_cond_pass;
        end
    end
    
    // ========================================================================
    // MEM Stage - Memory Unit
    // ========================================================================
    memory_unit #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH)
    ) u_memory_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        // Control
        .mem_read       (mem_mem_read_r),
        .mem_write      (mem_mem_write_r),
        .mem_size       (2'b10),            // TODO: 连接来自 decoder 的 mem_size
        .mem_signed     (1'b0),             // TODO: 连接来自 decoder 的 mem_signed
        // Data
        .addr           (mem_alu_result_r),
        .write_data     (mem_write_data_r),
        .read_data      (mem_read_data),
        .mem_stall      (),                 // TODO: 连接到 hazard_unit
        // External memory interface
        .dmem_addr      (dmem_addr),
        .dmem_wr_data   (dmem_wr_data),
        .dmem_wr_en     (dmem_wr_en),
        .dmem_rd_en     (dmem_rd_en),
        .dmem_byte_en   (dmem_byte_en),
        .dmem_rd_data   (dmem_rd_data),
        .dmem_rd_valid  (dmem_rd_valid)
    );
    
    // ========================================================================
    // MEM/WB Pipeline Register
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_alu_result_r   <= {DATA_WIDTH{1'b0}};
            wb_mem_data_r     <= {DATA_WIDTH{1'b0}};
            wb_rd_r           <= 4'b0;
            wb_reg_write_r    <= 1'b0;
            wb_mem_to_reg_r   <= 1'b0;
            wb_valid_r        <= 1'b0;
        end else begin
            wb_alu_result_r   <= mem_alu_result_r;
            wb_mem_data_r     <= mem_read_data;
            wb_rd_r           <= mem_rd_r;
            wb_reg_write_r    <= mem_reg_write_r;
            wb_mem_to_reg_r   <= mem_mem_to_reg_r;
            wb_valid_r        <= mem_valid_r;
        end
    end
    
    // ========================================================================
    // WB Stage - Write Back
    // ========================================================================
    assign wb_write_data = wb_mem_to_reg_r ? wb_mem_data_r : wb_alu_result_r;
    
    // ========================================================================
    // Hazard Detection Unit
    // ========================================================================
    hazard_unit u_hazard_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        // ID stage
        .id_rn          (id_rn),
        .id_rm          (id_rm),
        .id_rs          (id_rs),
        .id_branch      (id_branch),
        // EX stage
        .ex_rd          (ex_rd_r),
        .ex_mem_read    (ex_mem_read_r),
        .ex_reg_write   (ex_reg_write_r),
        // MEM stage
        .mem_rd         (mem_rd_r),
        .mem_reg_write  (mem_reg_write_r),
        // Branch
        .branch_taken   (ex_branch_taken),
        // Outputs
        .stall_if       (stall_if),
        .stall_id       (stall_id),
        .flush_if       (flush_if),
        .flush_id       (flush_id),
        .flush_ex       (flush_ex)
    );
    
    // ========================================================================
    // Forwarding Unit
    // ========================================================================
    forwarding_unit u_forwarding_unit (
        // EX stage source registers
        .ex_rn          (ex_rn_addr_r),
        .ex_rm          (ex_rm_addr_r),
        // MEM stage
        .mem_rd         (mem_rd_r),
        .mem_reg_write  (mem_reg_write_r),
        // WB stage
        .wb_rd          (wb_rd_r),
        .wb_reg_write   (wb_reg_write_r),
        // Outputs
        .forward_a      (forward_a),
        .forward_b      (forward_b)
    );
    
    // ========================================================================
    // CPSR Register Management
    // ========================================================================
    assign cpsr_n = cpsr_r[`CPSR_N];
    assign cpsr_z = cpsr_r[`CPSR_Z];
    assign cpsr_c = cpsr_r[`CPSR_C];
    assign cpsr_v = cpsr_r[`CPSR_V];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cpsr_r <= {24'b0, 1'b1, 1'b1, 1'b0, `MODE_SVC};  // SVC mode, I/F disabled
        end else if (ex_valid_r && ex_s_flag_r && ex_cond_pass) begin
            cpsr_r[`CPSR_N] <= ex_alu_n;
            cpsr_r[`CPSR_Z] <= ex_alu_z;
            cpsr_r[`CPSR_C] <= ex_alu_c;
            cpsr_r[`CPSR_V] <= ex_alu_v;
        end
    end
    
    // ========================================================================
    // Debug Outputs
    // ========================================================================
    assign debug_pc         = if_pc;
    assign debug_instr      = id_instruction_r;
    assign debug_cpsr_flags = {cpsr_n, cpsr_z, cpsr_c, cpsr_v};
    assign debug_halted     = 1'b0;  // TODO: Implement halt logic

endmodule
