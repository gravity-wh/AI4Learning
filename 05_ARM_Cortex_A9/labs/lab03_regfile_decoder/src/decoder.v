// ============================================================================
// File: decoder.v
// Description: Instruction Decoder for ARM Cortex-A9
//              Decodes ARM instructions and generates control signals
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module decoder (
    // ========================================================================
    // 指令输入
    // ========================================================================
    input  wire [31:0]              instruction,
    
    // ========================================================================
    // 指令字段输出
    // ========================================================================
    output wire [3:0]               cond,           // 条件码 [31:28]
    output wire [1:0]               op,             // 操作类型 [27:26]
    output wire [3:0]               opcode,         // ALU 操作码 [24:21]
    output wire                     imm_flag,       // 立即数标志 [25]
    output wire                     s_flag,         // 更新标志位 [20]
    output wire [3:0]               rn,             // 源寄存器 1 [19:16]
    output wire [3:0]               rd,             // 目的寄存器 [15:12]
    output wire [3:0]               rs,             // 移位寄存器 [11:8]
    output wire [3:0]               rm,             // 源寄存器 2 [3:0]
    output wire [11:0]              imm12,          // 12位立即数/偏移 [11:0]
    output wire [23:0]              offset24,       // 分支偏移 [23:0]
    
    // ========================================================================
    // 控制信号输出 (匹配 cortex_a9_top.v 接口)
    // ========================================================================
    output reg                      reg_write,      // 寄存器写使能
    output reg                      mem_read,       // 内存读
    output reg                      mem_write,      // 内存写
    output reg                      branch,         // 分支指令
    output reg                      branch_link,    // 带链接分支
    output reg                      alu_src,        // ALU 源选择 (0=Rm, 1=Imm)
    output reg                      mem_to_reg,     // 内存数据写回寄存器
    output reg  [3:0]               alu_op,         // ALU 操作
    output reg  [1:0]               shift_type,     // 移位类型
    output reg  [4:0]               shift_amount    // 移位量
);

    // ========================================================================
    // 指令字段提取
    // ========================================================================
    assign cond     = instruction[31:28];
    assign op       = instruction[27:26];
    assign imm_flag = instruction[25];
    assign opcode   = instruction[24:21];
    assign s_flag   = instruction[20];
    assign rn       = instruction[19:16];
    assign rd       = instruction[15:12];
    assign rs       = instruction[11:8];
    assign rm       = instruction[3:0];
    assign imm12    = instruction[11:0];
    assign offset24 = instruction[23:0];
    
    // ========================================================================
    // 内部信号
    // ========================================================================
    wire is_data_processing;
    wire is_multiply;
    wire is_load_store;
    wire is_branch;
    wire is_block_transfer;
    
    // 指令类型检测
    assign is_data_processing = (op == 2'b00) && 
                                 !((instruction[7:4] == 4'b1001) && !imm_flag);
    assign is_multiply        = (op == 2'b00) && 
                                 (instruction[7:4] == 4'b1001) && !imm_flag;
    assign is_load_store      = (op == 2'b01);
    assign is_branch          = (op == 2'b10);
    assign is_block_transfer  = (op == 2'b10) && !instruction[25];
    
    // Load/Store 控制位
    wire ls_load    = instruction[20];
    wire ls_byte    = instruction[22];
    wire ls_pre     = instruction[24];
    wire ls_up      = instruction[23];
    wire ls_wb      = instruction[21];
    
    // 分支控制位
    wire br_link    = instruction[24];
    
    // ========================================================================
    // 控制信号生成
    // ========================================================================
    always @(*) begin
        // 默认值
        reg_write    = 1'b0;
        mem_read     = 1'b0;
        mem_write    = 1'b0;
        branch       = 1'b0;
        branch_link  = 1'b0;
        alu_src      = 1'b0;
        mem_to_reg   = 1'b0;
        alu_op       = `ALU_ADD;
        shift_type   = `SHIFT_LSL;
        shift_amount = 5'd0;
        
        // --------------------------------------------------------------------
        // 数据处理指令
        // --------------------------------------------------------------------
        if (is_data_processing) begin
            alu_op   = opcode;
            alu_src  = imm_flag;
            
            // 移位控制
            if (!imm_flag) begin
                // 寄存器操作数带移位
                shift_type   = instruction[6:5];
                shift_amount = instruction[4] ? 5'd0 :  // 寄存器移位
                                                instruction[11:7];  // 立即数移位
            end else begin
                // 立即数旋转
                shift_type   = `SHIFT_ROR;
                shift_amount = {instruction[11:8], 1'b0};  // rotate * 2
            end
            
            // 寄存器写使能 (TST/TEQ/CMP/CMN 不写回)
            case (opcode)
                `ALU_TST, `ALU_TEQ, `ALU_CMP, `ALU_CMN: 
                    reg_write = 1'b0;
                default: 
                    reg_write = 1'b1;
            endcase
        end
        
        // --------------------------------------------------------------------
        // 乘法指令
        // --------------------------------------------------------------------
        else if (is_multiply) begin
            reg_write = 1'b1;
            alu_op    = `ALU_ADD;  // 使用 ADD，乘法单独处理
        end
        
        // --------------------------------------------------------------------
        // Load/Store 指令
        // --------------------------------------------------------------------
        else if (is_load_store) begin
            alu_op   = ls_up ? `ALU_ADD : `ALU_SUB;  // 地址计算方向
            alu_src  = !imm_flag;  // 注意：Load/Store 的 I 位含义相反
            
            if (!imm_flag) begin
                // 12位立即数偏移
                shift_amount = 5'd0;
            end else begin
                // 寄存器偏移带移位
                shift_type   = instruction[6:5];
                shift_amount = instruction[11:7];
            end
            
            if (ls_load) begin
                // LDR
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                reg_write  = 1'b1;
            end else begin
                // STR
                mem_write  = 1'b1;
            end
            
            // 写回基址寄存器
            if (ls_wb || !ls_pre) begin
                // 需要额外处理写回
            end
        end
        
        // --------------------------------------------------------------------
        // 分支指令
        // --------------------------------------------------------------------
        else if (is_branch && instruction[25]) begin
            branch      = 1'b1;
            branch_link = br_link;
            
            if (br_link) begin
                // BL: 保存返回地址到 LR
                reg_write = 1'b1;
            end
        end
    end

endmodule
