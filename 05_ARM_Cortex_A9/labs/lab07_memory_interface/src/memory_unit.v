// ============================================================================
// File: memory_unit.v
// Description: Memory Access Unit for ARM Cortex-A9
//              Handles Load/Store operations, interfaces with D-Cache/AXI
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// Reference: ARM Cortex-A9 Technical Reference Manual
// ============================================================================

`include "defines.vh"

module memory_unit #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     clk,
    input  wire                     rst_n,
    
    // ========================================================================
    // 流水线控制信号
    // ========================================================================
    input  wire                     mem_read,       // 内存读使能 (LDR)
    input  wire                     mem_write,      // 内存写使能 (STR)
    input  wire [1:0]               mem_size,       // 访问大小 (00=Byte, 01=Half, 10=Word)
    input  wire                     mem_signed,     // 有符号扩展标志
    
    // ========================================================================
    // 数据输入
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]    addr,           // 访问地址 (来自 ALU)
    input  wire [DATA_WIDTH-1:0]    write_data,     // 写数据 (来自 Rm)
    
    // ========================================================================
    // 数据输出
    // ========================================================================
    output reg  [DATA_WIDTH-1:0]    read_data,      // 读取的数据
    output wire                     mem_stall,      // 内存访问暂停
    
    // ========================================================================
    // 外部数据存储器接口 (D-Cache / AXI)
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]    dmem_addr,      // 数据地址
    output wire [DATA_WIDTH-1:0]    dmem_wr_data,   // 写数据
    output wire                     dmem_wr_en,     // 写使能
    output wire                     dmem_rd_en,     // 读使能
    output wire [3:0]               dmem_byte_en,   // 字节使能
    input  wire [DATA_WIDTH-1:0]    dmem_rd_data,   // 读数据
    input  wire                     dmem_rd_valid   // 读数据有效
);

    // ========================================================================
    // 内部信号
    // ========================================================================
    wire [1:0] byte_offset;
    reg  [3:0] byte_enable;
    reg  [DATA_WIDTH-1:0] aligned_write_data;
    wire [DATA_WIDTH-1:0] raw_read_data;
    
    // ========================================================================
    // 地址对齐
    // ========================================================================
    assign byte_offset = addr[1:0];
    
    // ========================================================================
    // 字节使能生成
    // ========================================================================
    always @(*) begin
        case (mem_size)
            `LS_BYTE: begin
                // 字节访问
                case (byte_offset)
                    2'b00: byte_enable = 4'b0001;
                    2'b01: byte_enable = 4'b0010;
                    2'b10: byte_enable = 4'b0100;
                    2'b11: byte_enable = 4'b1000;
                endcase
            end
            
            `LS_HALF: begin
                // 半字访问 (必须半字对齐)
                case (byte_offset[1])
                    1'b0: byte_enable = 4'b0011;
                    1'b1: byte_enable = 4'b1100;
                endcase
            end
            
            default: begin
                // 字访问 (必须字对齐)
                byte_enable = 4'b1111;
            end
        endcase
    end
    
    // ========================================================================
    // 写数据对齐
    // ========================================================================
    always @(*) begin
        case (mem_size)
            `LS_BYTE: begin
                // 字节数据复制到对应位置
                case (byte_offset)
                    2'b00: aligned_write_data = {24'b0, write_data[7:0]};
                    2'b01: aligned_write_data = {16'b0, write_data[7:0], 8'b0};
                    2'b10: aligned_write_data = {8'b0, write_data[7:0], 16'b0};
                    2'b11: aligned_write_data = {write_data[7:0], 24'b0};
                endcase
            end
            
            `LS_HALF: begin
                // 半字数据复制到对应位置
                case (byte_offset[1])
                    1'b0: aligned_write_data = {16'b0, write_data[15:0]};
                    1'b1: aligned_write_data = {write_data[15:0], 16'b0};
                endcase
            end
            
            default: begin
                // 字数据直接传递
                aligned_write_data = write_data;
            end
        endcase
    end
    
    // ========================================================================
    // 读数据处理
    // ========================================================================
    assign raw_read_data = dmem_rd_data;
    
    always @(*) begin
        case (mem_size)
            `LS_BYTE: begin
                // 字节读取并扩展
                case (byte_offset)
                    2'b00: read_data = mem_signed ? {{24{raw_read_data[7]}}, raw_read_data[7:0]} :
                                                    {24'b0, raw_read_data[7:0]};
                    2'b01: read_data = mem_signed ? {{24{raw_read_data[15]}}, raw_read_data[15:8]} :
                                                    {24'b0, raw_read_data[15:8]};
                    2'b10: read_data = mem_signed ? {{24{raw_read_data[23]}}, raw_read_data[23:16]} :
                                                    {24'b0, raw_read_data[23:16]};
                    2'b11: read_data = mem_signed ? {{24{raw_read_data[31]}}, raw_read_data[31:24]} :
                                                    {24'b0, raw_read_data[31:24]};
                endcase
            end
            
            `LS_HALF: begin
                // 半字读取并扩展
                case (byte_offset[1])
                    1'b0: read_data = mem_signed ? {{16{raw_read_data[15]}}, raw_read_data[15:0]} :
                                                   {16'b0, raw_read_data[15:0]};
                    1'b1: read_data = mem_signed ? {{16{raw_read_data[31]}}, raw_read_data[31:16]} :
                                                   {16'b0, raw_read_data[31:16]};
                endcase
            end
            
            default: begin
                // 字读取直接传递
                read_data = raw_read_data;
            end
        endcase
    end
    
    // ========================================================================
    // 外部存储器接口
    // ========================================================================
    
    // 地址输出 (字对齐)
    assign dmem_addr = {addr[ADDR_WIDTH-1:2], 2'b00};
    
    // 写数据和控制
    assign dmem_wr_data = aligned_write_data;
    assign dmem_wr_en   = mem_write;
    assign dmem_rd_en   = mem_read;
    assign dmem_byte_en = byte_enable;
    
    // ========================================================================
    // 暂停信号
    // ========================================================================
    // 当请求读取但数据尚未有效时暂停
    assign mem_stall = mem_read && !dmem_rd_valid;

endmodule
