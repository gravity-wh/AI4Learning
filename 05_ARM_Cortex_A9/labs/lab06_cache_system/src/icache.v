// ============================================================================
// File: icache.v
// Description: Instruction Cache - Direct Mapped, 4KB, 32B Line
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module icache #(
    parameter CACHE_SIZE    = 4096,     // 4KB
    parameter LINE_SIZE     = 32,       // 32 bytes (8 words)
    parameter ADDR_WIDTH    = 32,
    parameter DATA_WIDTH    = 32
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     clk,
    input  wire                     rst_n,
    
    // ========================================================================
    // CPU 接口
    // ========================================================================
    input  wire                     req,            // 读请求
    input  wire [ADDR_WIDTH-1:0]    addr,           // 地址
    output wire [DATA_WIDTH-1:0]    rdata,          // 读数据
    output wire                     hit,            // 命中
    output wire                     ready,          // 就绪
    
    // ========================================================================
    // 内存接口
    // ========================================================================
    output reg                      mem_req,        // 内存请求
    output wire [ADDR_WIDTH-1:0]    mem_addr,       // 内存地址
    input  wire [DATA_WIDTH-1:0]    mem_rdata,      // 内存读数据
    input  wire                     mem_valid       // 内存数据有效
);

    // ========================================================================
    // 参数计算
    // ========================================================================
    localparam NUM_LINES    = CACHE_SIZE / LINE_SIZE;       // 128 lines
    localparam WORDS_PER_LINE = LINE_SIZE / 4;              // 8 words
    localparam INDEX_WIDTH  = $clog2(NUM_LINES);            // 7 bits
    localparam OFFSET_WIDTH = $clog2(LINE_SIZE);            // 5 bits
    localparam TAG_WIDTH    = ADDR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH;  // 20 bits
    localparam WORD_OFFSET_WIDTH = $clog2(WORDS_PER_LINE);  // 3 bits
    
    // ========================================================================
    // 地址分解
    // ========================================================================
    wire [TAG_WIDTH-1:0]    addr_tag;
    wire [INDEX_WIDTH-1:0]  addr_index;
    wire [WORD_OFFSET_WIDTH-1:0] word_offset;
    
    assign addr_tag     = addr[ADDR_WIDTH-1 : INDEX_WIDTH + OFFSET_WIDTH];
    assign addr_index   = addr[INDEX_WIDTH + OFFSET_WIDTH - 1 : OFFSET_WIDTH];
    assign word_offset  = addr[OFFSET_WIDTH-1 : 2];
    
    // ========================================================================
    // Cache 存储
    // ========================================================================
    reg                     valid_array [0:NUM_LINES-1];
    reg [TAG_WIDTH-1:0]     tag_array   [0:NUM_LINES-1];
    reg [DATA_WIDTH-1:0]    data_array  [0:NUM_LINES-1][0:WORDS_PER_LINE-1];
    
    // ========================================================================
    // 状态机
    // ========================================================================
    localparam S_IDLE       = 2'b00;
    localparam S_COMPARE    = 2'b01;
    localparam S_FILL       = 2'b10;
    localparam S_DONE       = 2'b11;
    
    reg [1:0] state, next_state;
    reg [WORD_OFFSET_WIDTH-1:0] fill_count;
    
    // ========================================================================
    // 命中检测
    // ========================================================================
    wire tag_match;
    wire cache_hit;
    
    assign tag_match = (tag_array[addr_index] == addr_tag);
    assign cache_hit = valid_array[addr_index] && tag_match;
    assign hit = cache_hit && (state == S_IDLE || state == S_COMPARE);
    
    // ========================================================================
    // 状态机转换
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end
    
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (req)
                    next_state = S_COMPARE;
            end
            
            S_COMPARE: begin
                if (cache_hit)
                    next_state = S_IDLE;
                else
                    next_state = S_FILL;
            end
            
            S_FILL: begin
                if (mem_valid && (fill_count == WORDS_PER_LINE - 1))
                    next_state = S_DONE;
            end
            
            S_DONE: begin
                next_state = S_IDLE;
            end
        endcase
    end
    
    // ========================================================================
    // Fill 计数器
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fill_count <= 0;
        end else if (state == S_FILL && mem_valid) begin
            fill_count <= fill_count + 1;
        end else if (state == S_IDLE) begin
            fill_count <= 0;
        end
    end
    
    // ========================================================================
    // Cache 写入 (Fill)
    // ========================================================================
    integer i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < NUM_LINES; i = i + 1)
                valid_array[i] <= 1'b0;
        end else if (state == S_FILL && mem_valid) begin
            data_array[addr_index][fill_count] <= mem_rdata;
            if (fill_count == WORDS_PER_LINE - 1) begin
                valid_array[addr_index] <= 1'b1;
                tag_array[addr_index] <= addr_tag;
            end
        end
    end
    
    // ========================================================================
    // 输出
    // ========================================================================
    assign rdata = data_array[addr_index][word_offset];
    assign ready = (state == S_IDLE) || (state == S_COMPARE && cache_hit) || 
                   (state == S_DONE);
    
    // 内存请求
    assign mem_addr = {addr_tag, addr_index, fill_count, 2'b00};
    
    always @(*) begin
        mem_req = (state == S_FILL);
    end

endmodule
