// ============================================================================
// File: dcache.v
// Description: Data Cache - 2-Way Set Associative, Write-Back, 4KB
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module dcache #(
    parameter CACHE_SIZE    = 4096,     // 4KB (每路 2KB)
    parameter LINE_SIZE     = 32,       // 32 bytes (8 words)
    parameter NUM_WAYS      = 2,        // 2路组相联
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
    input  wire                     req,            // 请求
    input  wire                     we,             // 写使能
    input  wire [ADDR_WIDTH-1:0]    addr,           // 地址
    input  wire [DATA_WIDTH-1:0]    wdata,          // 写数据
    input  wire [3:0]               byte_en,        // 字节使能
    output wire [DATA_WIDTH-1:0]    rdata,          // 读数据
    output wire                     hit,            // 命中
    output wire                     ready,          // 就绪
    
    // ========================================================================
    // 内存接口
    // ========================================================================
    output reg                      mem_req,        // 内存请求
    output reg                      mem_we,         // 内存写使能
    output wire [ADDR_WIDTH-1:0]    mem_addr,       // 内存地址
    output wire [DATA_WIDTH-1:0]    mem_wdata,      // 内存写数据
    input  wire [DATA_WIDTH-1:0]    mem_rdata,      // 内存读数据
    input  wire                     mem_valid       // 内存响应有效
);

    // ========================================================================
    // 参数计算
    // ========================================================================
    localparam NUM_SETS     = (CACHE_SIZE / NUM_WAYS) / LINE_SIZE;  // 64 sets
    localparam WORDS_PER_LINE = LINE_SIZE / 4;                       // 8 words
    localparam INDEX_WIDTH  = $clog2(NUM_SETS);                      // 6 bits
    localparam OFFSET_WIDTH = $clog2(LINE_SIZE);                     // 5 bits
    localparam TAG_WIDTH    = ADDR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH; // 21 bits
    localparam WORD_OFFSET_WIDTH = $clog2(WORDS_PER_LINE);           // 3 bits
    
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
    reg                     valid_array [0:NUM_WAYS-1][0:NUM_SETS-1];
    reg                     dirty_array [0:NUM_WAYS-1][0:NUM_SETS-1];
    reg [TAG_WIDTH-1:0]     tag_array   [0:NUM_WAYS-1][0:NUM_SETS-1];
    reg [DATA_WIDTH-1:0]    data_array  [0:NUM_WAYS-1][0:NUM_SETS-1][0:WORDS_PER_LINE-1];
    
    // LRU 位 (0 = 替换 Way0, 1 = 替换 Way1)
    reg                     lru_array   [0:NUM_SETS-1];
    
    // ========================================================================
    // 状态机
    // ========================================================================
    localparam S_IDLE       = 3'b000;
    localparam S_COMPARE    = 3'b001;
    localparam S_WRITEBACK  = 3'b010;
    localparam S_ALLOCATE   = 3'b011;
    localparam S_FILL       = 3'b100;
    localparam S_UPDATE     = 3'b101;
    
    reg [2:0] state, next_state;
    reg [WORD_OFFSET_WIDTH-1:0] word_count;
    
    // ========================================================================
    // 命中检测
    // ========================================================================
    wire tag_match_way0, tag_match_way1;
    wire hit_way0, hit_way1;
    wire cache_hit;
    wire hit_way;
    
    assign tag_match_way0 = (tag_array[0][addr_index] == addr_tag);
    assign tag_match_way1 = (tag_array[1][addr_index] == addr_tag);
    
    assign hit_way0 = valid_array[0][addr_index] && tag_match_way0;
    assign hit_way1 = valid_array[1][addr_index] && tag_match_way1;
    
    assign cache_hit = hit_way0 || hit_way1;
    assign hit_way = hit_way1;  // 0 = Way0 hit, 1 = Way1 hit
    
    assign hit = cache_hit && (state == S_IDLE || state == S_COMPARE);
    
    // ========================================================================
    // 替换路选择
    // ========================================================================
    wire replace_way;
    wire need_writeback;
    
    assign replace_way = lru_array[addr_index];
    assign need_writeback = valid_array[replace_way][addr_index] && 
                            dirty_array[replace_way][addr_index];
    
    // 被替换行的 Tag
    wire [TAG_WIDTH-1:0] evict_tag;
    assign evict_tag = tag_array[replace_way][addr_index];
    
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
                if (cache_hit) begin
                    next_state = S_UPDATE;
                end else if (need_writeback) begin
                    next_state = S_WRITEBACK;
                end else begin
                    next_state = S_ALLOCATE;
                end
            end
            
            S_WRITEBACK: begin
                if (mem_valid && (word_count == WORDS_PER_LINE - 1))
                    next_state = S_ALLOCATE;
            end
            
            S_ALLOCATE: begin
                next_state = S_FILL;
            end
            
            S_FILL: begin
                if (mem_valid && (word_count == WORDS_PER_LINE - 1))
                    next_state = S_UPDATE;
            end
            
            S_UPDATE: begin
                next_state = S_IDLE;
            end
        endcase
    end
    
    // ========================================================================
    // Word 计数器
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            word_count <= 0;
        end else if ((state == S_WRITEBACK || state == S_FILL) && mem_valid) begin
            word_count <= word_count + 1;
        end else if (state == S_IDLE || state == S_COMPARE) begin
            word_count <= 0;
        end
    end
    
    // ========================================================================
    // Cache 操作
    // ========================================================================
    integer i, j;
    reg active_way;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < NUM_WAYS; i = i + 1) begin
                for (j = 0; j < NUM_SETS; j = j + 1) begin
                    valid_array[i][j] <= 1'b0;
                    dirty_array[i][j] <= 1'b0;
                end
            end
        end else begin
            case (state)
                S_FILL: begin
                    if (mem_valid) begin
                        data_array[replace_way][addr_index][word_count] <= mem_rdata;
                        if (word_count == WORDS_PER_LINE - 1) begin
                            valid_array[replace_way][addr_index] <= 1'b1;
                            dirty_array[replace_way][addr_index] <= 1'b0;
                            tag_array[replace_way][addr_index] <= addr_tag;
                        end
                    end
                end
                
                S_UPDATE: begin
                    if (we) begin
                        // 写操作
                        active_way = cache_hit ? hit_way : replace_way;
                        
                        // 字节使能写入
                        if (byte_en[0])
                            data_array[active_way][addr_index][word_offset][7:0] <= wdata[7:0];
                        if (byte_en[1])
                            data_array[active_way][addr_index][word_offset][15:8] <= wdata[15:8];
                        if (byte_en[2])
                            data_array[active_way][addr_index][word_offset][23:16] <= wdata[23:16];
                        if (byte_en[3])
                            data_array[active_way][addr_index][word_offset][31:24] <= wdata[31:24];
                        
                        dirty_array[active_way][addr_index] <= 1'b1;
                    end
                    
                    // 更新 LRU
                    lru_array[addr_index] <= cache_hit ? ~hit_way : ~replace_way;
                end
            endcase
        end
    end
    
    // ========================================================================
    // 内存接口
    // ========================================================================
    reg [ADDR_WIDTH-1:0] mem_addr_reg;
    
    always @(*) begin
        mem_req = 1'b0;
        mem_we = 1'b0;
        mem_addr_reg = 0;
        
        case (state)
            S_WRITEBACK: begin
                mem_req = 1'b1;
                mem_we = 1'b1;
                mem_addr_reg = {evict_tag, addr_index, word_count, 2'b00};
            end
            
            S_FILL: begin
                mem_req = 1'b1;
                mem_we = 1'b0;
                mem_addr_reg = {addr_tag, addr_index, word_count, 2'b00};
            end
        endcase
    end
    
    assign mem_addr = mem_addr_reg;
    assign mem_wdata = data_array[replace_way][addr_index][word_count];
    
    // ========================================================================
    // 输出
    // ========================================================================
    wire [DATA_WIDTH-1:0] hit_data;
    assign hit_data = hit_way0 ? data_array[0][addr_index][word_offset] :
                                 data_array[1][addr_index][word_offset];
    
    assign rdata = cache_hit ? hit_data : 
                   data_array[replace_way][addr_index][word_offset];
    
    assign ready = (state == S_IDLE) || 
                   (state == S_COMPARE && cache_hit && !we) ||
                   (state == S_UPDATE);

endmodule
