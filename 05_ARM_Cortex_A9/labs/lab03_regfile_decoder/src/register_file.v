// ============================================================================
// File: register_file.v
// Description: 16x32-bit Register File for ARM Cortex-A9
//              3 Read Ports + 1 Write Port
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module register_file #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4,
    parameter NUM_REGS   = 16
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     clk,
    input  wire                     rst_n,
    
    // ========================================================================
    // 读端口 1 (Rn)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]    rd_addr_1,
    output wire [DATA_WIDTH-1:0]    rd_data_1,
    
    // ========================================================================
    // 读端口 2 (Rm)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]    rd_addr_2,
    output wire [DATA_WIDTH-1:0]    rd_data_2,
    
    // ========================================================================
    // 读端口 3 (Rs - 用于移位量)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]    rd_addr_3,
    output wire [DATA_WIDTH-1:0]    rd_data_3,
    
    // ========================================================================
    // 写端口
    // ========================================================================
    input  wire                     wr_en,
    input  wire [ADDR_WIDTH-1:0]    wr_addr,
    input  wire [DATA_WIDTH-1:0]    wr_data,
    
    // ========================================================================
    // PC 接口 (R15)
    // ========================================================================
    input  wire [DATA_WIDTH-1:0]    pc              // 当前 PC 值
);

    // ========================================================================
    // 寄存器数组
    // ========================================================================
    reg [DATA_WIDTH-1:0] registers [0:NUM_REGS-2];  // R0-R14
    
    // ========================================================================
    // 写操作 (时钟上升沿)
    // ========================================================================
    integer i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位所有寄存器
            for (i = 0; i < NUM_REGS-1; i = i + 1) begin
                registers[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (wr_en && (wr_addr != 4'd15)) begin
            // 写入非 PC 寄存器
            registers[wr_addr] <= wr_data;
        end
    end
    
    // ========================================================================
    // 读操作 (组合逻辑，带写后读旁路)
    // ========================================================================
    
    // 读端口 1
    wire [DATA_WIDTH-1:0] rd_data_1_raw;
    assign rd_data_1_raw = (rd_addr_1 == 4'd15) ? (pc + 32'd8) :  // R15 = PC + 8
                                                  registers[rd_addr_1];
    // 写后读旁路
    assign rd_data_1 = (wr_en && (wr_addr == rd_addr_1) && (rd_addr_1 != 4'd15)) ? 
                       wr_data : rd_data_1_raw;
    
    // 读端口 2
    wire [DATA_WIDTH-1:0] rd_data_2_raw;
    assign rd_data_2_raw = (rd_addr_2 == 4'd15) ? (pc + 32'd8) :
                                                  registers[rd_addr_2];
    assign rd_data_2 = (wr_en && (wr_addr == rd_addr_2) && (rd_addr_2 != 4'd15)) ? 
                       wr_data : rd_data_2_raw;
    
    // 读端口 3
    wire [DATA_WIDTH-1:0] rd_data_3_raw;
    assign rd_data_3_raw = (rd_addr_3 == 4'd15) ? (pc + 32'd8) :
                                                  registers[rd_addr_3];
    assign rd_data_3 = (wr_en && (wr_addr == rd_addr_3) && (rd_addr_3 != 4'd15)) ? 
                       wr_data : rd_data_3_raw;

endmodule
