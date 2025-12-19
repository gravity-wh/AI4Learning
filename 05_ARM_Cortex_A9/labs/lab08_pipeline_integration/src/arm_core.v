// ============================================================================
// File: arm_core.v
// Description: Integrated ARM Cortex-A9 Core with 5-Stage Pipeline
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module arm_core #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 4
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     clk,
    input  wire                     rst_n,
    
    // ========================================================================
    // 指令存储器接口
    // ========================================================================
    output wire                     imem_req,
    output wire [ADDR_WIDTH-1:0]    imem_addr,
    input  wire [DATA_WIDTH-1:0]    imem_rdata,
    input  wire                     imem_valid,
    
    // ========================================================================
    // 数据存储器接口
    // ========================================================================
    output wire                     dmem_req,
    output wire                     dmem_we,
    output wire [ADDR_WIDTH-1:0]    dmem_addr,
    output wire [DATA_WIDTH-1:0]    dmem_wdata,
    output wire [3:0]               dmem_byte_en,
    input  wire [DATA_WIDTH-1:0]    dmem_rdata,
    input  wire                     dmem_valid
);

    // ========================================================================
    // 流水线寄存器信号
    // ========================================================================
    
    // IF/ID
    reg  [ADDR_WIDTH-1:0]           if_id_pc;
    reg  [DATA_WIDTH-1:0]           if_id_instr;
    reg                             if_id_valid;
    
    // ID/EX
    reg  [ADDR_WIDTH-1:0]           id_ex_pc;
    reg  [DATA_WIDTH-1:0]           id_ex_rn_data;
    reg  [DATA_WIDTH-1:0]           id_ex_rm_data;
    reg  [DATA_WIDTH-1:0]           id_ex_imm;
    reg  [REG_ADDR_WIDTH-1:0]       id_ex_rn;
    reg  [REG_ADDR_WIDTH-1:0]       id_ex_rm;
    reg  [REG_ADDR_WIDTH-1:0]       id_ex_rd;
    reg  [3:0]                      id_ex_alu_op;
    reg                             id_ex_alu_src;
    reg                             id_ex_reg_write;
    reg                             id_ex_mem_read;
    reg                             id_ex_mem_write;
    reg                             id_ex_branch;
    reg  [1:0]                      id_ex_shift_type;
    reg  [4:0]                      id_ex_shift_amount;
    reg  [3:0]                      id_ex_cond;
    reg                             id_ex_s_bit;
    reg                             id_ex_valid;
    
    // EX/MEM
    reg  [ADDR_WIDTH-1:0]           ex_mem_pc;
    reg  [DATA_WIDTH-1:0]           ex_mem_alu_result;
    reg  [DATA_WIDTH-1:0]           ex_mem_write_data;
    reg  [REG_ADDR_WIDTH-1:0]       ex_mem_rd;
    reg                             ex_mem_reg_write;
    reg                             ex_mem_mem_read;
    reg                             ex_mem_mem_write;
    reg  [3:0]                      ex_mem_byte_en;
    reg                             ex_mem_valid;
    
    // MEM/WB
    reg  [DATA_WIDTH-1:0]           mem_wb_result;
    reg  [REG_ADDR_WIDTH-1:0]       mem_wb_rd;
    reg                             mem_wb_reg_write;
    reg                             mem_wb_valid;
    
    // ========================================================================
    // CPSR
    // ========================================================================
    reg  [3:0]                      cpsr_flags;  // NZCV
    
    // ========================================================================
    // 控制信号
    // ========================================================================
    wire                            stall_if, stall_id;
    wire                            flush_if, flush_id, flush_ex;
    wire [1:0]                      forward_a, forward_b;
    wire                            branch_taken;
    wire [ADDR_WIDTH-1:0]           branch_target;
    
    // ========================================================================
    // IF Stage - Instruction Fetch
    // ========================================================================
    reg  [ADDR_WIDTH-1:0]           pc;
    wire [ADDR_WIDTH-1:0]           next_pc;
    
    assign next_pc = branch_taken ? branch_target : (pc + 4);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'h0000_0000;
        else if (!stall_if)
            pc <= next_pc;
    end
    
    assign imem_req = 1'b1;
    assign imem_addr = pc;
    
    // IF/ID Pipeline Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            if_id_pc <= 0;
            if_id_instr <= 32'hE1A00000;  // NOP (MOV R0, R0)
            if_id_valid <= 0;
        end else if (flush_if || flush_id) begin
            if_id_instr <= 32'hE1A00000;
            if_id_valid <= 0;
        end else if (!stall_id) begin
            if_id_pc <= pc;
            if_id_instr <= imem_rdata;
            if_id_valid <= imem_valid;
        end
    end
    
    // ========================================================================
    // ID Stage - Instruction Decode
    // ========================================================================
    
    // 指令解码
    wire [3:0]  id_cond     = if_id_instr[31:28];
    wire [1:0]  id_op       = if_id_instr[27:26];
    wire        id_imm_flag = if_id_instr[25];
    wire [3:0]  id_opcode   = if_id_instr[24:21];
    wire        id_s_bit    = if_id_instr[20];
    wire [3:0]  id_rn       = if_id_instr[19:16];
    wire [3:0]  id_rd       = if_id_instr[15:12];
    wire [3:0]  id_rs       = if_id_instr[11:8];
    wire [3:0]  id_rm       = if_id_instr[3:0];
    wire [11:0] id_imm12    = if_id_instr[11:0];
    wire [23:0] id_imm24    = if_id_instr[23:0];
    
    // 立即数扩展
    wire [31:0] id_imm_value;
    wire [4:0]  id_rotate = {id_imm12[11:8], 1'b0};
    wire [31:0] id_imm8_ext = {24'b0, id_imm12[7:0]};
    
    // 旋转立即数
    assign id_imm_value = (id_imm8_ext >> id_rotate) | 
                          (id_imm8_ext << (32 - id_rotate));
    
    // 控制信号生成
    wire id_is_dp   = (id_op == 2'b00);  // 数据处理
    wire id_is_mem  = (id_op == 2'b01);  // Load/Store
    wire id_is_br   = (id_op == 2'b10);  // 分支
    
    wire id_reg_write = (id_is_dp && id_opcode != 4'b1010 && id_opcode != 4'b1011 &&
                         id_opcode != 4'b1000 && id_opcode != 4'b1001) ||  // 非 TST/TEQ/CMP/CMN
                        (id_is_mem && if_id_instr[20]);  // LDR
    
    wire id_mem_read  = id_is_mem && if_id_instr[20];  // LDR
    wire id_mem_write = id_is_mem && !if_id_instr[20]; // STR
    wire id_branch    = id_is_br;
    wire id_alu_src   = id_imm_flag;
    
    // 寄存器文件
    wire [31:0] rf_rdata1, rf_rdata2, rf_rdata3;
    wire        rf_we;
    wire [3:0]  rf_waddr;
    wire [31:0] rf_wdata;
    
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(REG_ADDR_WIDTH)
    ) u_regfile (
        .clk        (clk),
        .rst_n      (rst_n),
        .raddr1     (id_rn),
        .raddr2     (id_rm),
        .raddr3     (id_rs),
        .rdata1     (rf_rdata1),
        .rdata2     (rf_rdata2),
        .rdata3     (rf_rdata3),
        .we         (rf_we),
        .waddr      (rf_waddr),
        .wdata      (rf_wdata),
        .pc_in      (pc + 8)
    );
    
    // ID/EX Pipeline Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush_ex) begin
            id_ex_pc <= 0;
            id_ex_rn_data <= 0;
            id_ex_rm_data <= 0;
            id_ex_imm <= 0;
            id_ex_rn <= 0;
            id_ex_rm <= 0;
            id_ex_rd <= 0;
            id_ex_alu_op <= `ALU_MOV;
            id_ex_alu_src <= 0;
            id_ex_reg_write <= 0;
            id_ex_mem_read <= 0;
            id_ex_mem_write <= 0;
            id_ex_branch <= 0;
            id_ex_shift_type <= 0;
            id_ex_shift_amount <= 0;
            id_ex_cond <= `COND_AL;
            id_ex_s_bit <= 0;
            id_ex_valid <= 0;
        end else if (!stall_id) begin
            id_ex_pc <= if_id_pc;
            id_ex_rn_data <= rf_rdata1;
            id_ex_rm_data <= rf_rdata2;
            id_ex_imm <= id_imm_flag ? id_imm_value : {{20{id_imm24[23]}}, id_imm24};
            id_ex_rn <= id_rn;
            id_ex_rm <= id_rm;
            id_ex_rd <= id_rd;
            id_ex_alu_op <= id_opcode;
            id_ex_alu_src <= id_alu_src;
            id_ex_reg_write <= id_reg_write;
            id_ex_mem_read <= id_mem_read;
            id_ex_mem_write <= id_mem_write;
            id_ex_branch <= id_branch;
            id_ex_shift_type <= if_id_instr[6:5];
            id_ex_shift_amount <= if_id_instr[11:7];
            id_ex_cond <= id_cond;
            id_ex_s_bit <= id_s_bit;
            id_ex_valid <= if_id_valid;
        end
    end
    
    // ========================================================================
    // EX Stage - Execute
    // ========================================================================
    
    wire [31:0] ex_result;
    wire [31:0] ex_shifted_op;
    wire        ex_n, ex_z, ex_c, ex_v;
    wire        ex_cond_pass;
    
    execute_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_exu (
        .clk            (clk),
        .rst_n          (rst_n),
        .rn_data        (id_ex_rn_data),
        .rm_data        (id_ex_rm_data),
        .rs_data        (32'b0),
        .imm_data       (id_ex_imm),
        .pc             (id_ex_pc),
        .alu_op         (id_ex_alu_op),
        .alu_src        (id_ex_alu_src),
        .shift_type     (id_ex_shift_type),
        .shift_amount   (id_ex_shift_amount),
        .carry_in       (cpsr_flags[1]),
        .cond           (id_ex_cond),
        .cpsr_flags     (cpsr_flags),
        .branch         (id_ex_branch),
        .branch_link    (1'b0),
        .forward_a      (forward_a),
        .forward_b      (forward_b),
        .mem_fwd_data   (ex_mem_alu_result),
        .wb_fwd_data    (mem_wb_result),
        .alu_result     (ex_result),
        .shifted_op     (ex_shifted_op),
        .alu_n          (ex_n),
        .alu_z          (ex_z),
        .alu_c          (ex_c),
        .alu_v          (ex_v),
        .cond_pass      (ex_cond_pass),
        .branch_taken   (branch_taken),
        .branch_target  (branch_target)
    );
    
    // CPSR 更新
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cpsr_flags <= 4'b0000;
        end else if (id_ex_valid && id_ex_s_bit && ex_cond_pass) begin
            cpsr_flags <= {ex_n, ex_z, ex_c, ex_v};
        end
    end
    
    // EX/MEM Pipeline Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem_pc <= 0;
            ex_mem_alu_result <= 0;
            ex_mem_write_data <= 0;
            ex_mem_rd <= 0;
            ex_mem_reg_write <= 0;
            ex_mem_mem_read <= 0;
            ex_mem_mem_write <= 0;
            ex_mem_byte_en <= 4'b0000;
            ex_mem_valid <= 0;
        end else begin
            ex_mem_pc <= id_ex_pc;
            ex_mem_alu_result <= ex_result;
            ex_mem_write_data <= ex_shifted_op;
            ex_mem_rd <= id_ex_rd;
            ex_mem_reg_write <= id_ex_reg_write && ex_cond_pass;
            ex_mem_mem_read <= id_ex_mem_read && ex_cond_pass;
            ex_mem_mem_write <= id_ex_mem_write && ex_cond_pass;
            ex_mem_byte_en <= 4'b1111;  // 简化：总是字访问
            ex_mem_valid <= id_ex_valid;
        end
    end
    
    // ========================================================================
    // MEM Stage - Memory Access
    // ========================================================================
    
    assign dmem_req = ex_mem_mem_read || ex_mem_mem_write;
    assign dmem_we = ex_mem_mem_write;
    assign dmem_addr = ex_mem_alu_result;
    assign dmem_wdata = ex_mem_write_data;
    assign dmem_byte_en = ex_mem_byte_en;
    
    wire [31:0] mem_result;
    assign mem_result = ex_mem_mem_read ? dmem_rdata : ex_mem_alu_result;
    
    // MEM/WB Pipeline Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb_result <= 0;
            mem_wb_rd <= 0;
            mem_wb_reg_write <= 0;
            mem_wb_valid <= 0;
        end else begin
            mem_wb_result <= mem_result;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
            mem_wb_valid <= ex_mem_valid;
        end
    end
    
    // ========================================================================
    // WB Stage - Write Back
    // ========================================================================
    
    assign rf_we = mem_wb_reg_write && mem_wb_valid;
    assign rf_waddr = mem_wb_rd;
    assign rf_wdata = mem_wb_result;
    
    // ========================================================================
    // Hazard Unit
    // ========================================================================
    
    hazard_unit u_hazard (
        .clk            (clk),
        .rst_n          (rst_n),
        .id_rn          (id_rn),
        .id_rm          (id_rm),
        .id_rs          (id_rs),
        .id_branch      (id_branch),
        .ex_rd          (id_ex_rd),
        .ex_mem_read    (id_ex_mem_read),
        .ex_reg_write   (id_ex_reg_write),
        .mem_rd         (ex_mem_rd),
        .mem_reg_write  (ex_mem_reg_write),
        .branch_taken   (branch_taken),
        .stall_if       (stall_if),
        .stall_id       (stall_id),
        .flush_if       (flush_if),
        .flush_id       (flush_id),
        .flush_ex       (flush_ex)
    );
    
    // ========================================================================
    // Forwarding Unit
    // ========================================================================
    
    forwarding_unit u_forward (
        .ex_rn          (id_ex_rn),
        .ex_rm          (id_ex_rm),
        .mem_rd         (ex_mem_rd),
        .mem_reg_write  (ex_mem_reg_write),
        .wb_rd          (mem_wb_rd),
        .wb_reg_write   (mem_wb_reg_write),
        .forward_a      (forward_a),
        .forward_b      (forward_b)
    );

endmodule
