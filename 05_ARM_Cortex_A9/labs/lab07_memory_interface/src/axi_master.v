// ============================================================================
// File: axi_master.v
// Description: Simplified AXI4 Master Interface for Cache-Memory Connection
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`include "defines.vh"

module axi_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
)(
    // ========================================================================
    // 时钟与复位
    // ========================================================================
    input  wire                     aclk,
    input  wire                     aresetn,
    
    // ========================================================================
    // Cache 侧接口 (简化)
    // ========================================================================
    input  wire                     cache_req,          // Cache 请求
    input  wire                     cache_we,           // 写使能
    input  wire [ADDR_WIDTH-1:0]    cache_addr,         // 地址
    input  wire [DATA_WIDTH-1:0]    cache_wdata,        // 写数据
    output reg  [DATA_WIDTH-1:0]    cache_rdata,        // 读数据
    output reg                      cache_valid,        // 数据有效
    output wire                     cache_ready,        // 接口就绪
    
    // 突发传输控制
    input  wire [7:0]               burst_len,          // 突发长度 (0-based)
    input  wire                     burst_start,        // 开始突发
    output reg                      burst_done,         // 突发完成
    
    // ========================================================================
    // AXI4 Write Address Channel
    // ========================================================================
    output reg  [ID_WIDTH-1:0]      m_axi_awid,
    output reg  [ADDR_WIDTH-1:0]    m_axi_awaddr,
    output reg  [7:0]               m_axi_awlen,
    output reg  [2:0]               m_axi_awsize,
    output reg  [1:0]               m_axi_awburst,
    output reg                      m_axi_awvalid,
    input  wire                     m_axi_awready,
    
    // ========================================================================
    // AXI4 Write Data Channel
    // ========================================================================
    output reg  [DATA_WIDTH-1:0]    m_axi_wdata,
    output reg  [DATA_WIDTH/8-1:0]  m_axi_wstrb,
    output reg                      m_axi_wlast,
    output reg                      m_axi_wvalid,
    input  wire                     m_axi_wready,
    
    // ========================================================================
    // AXI4 Write Response Channel
    // ========================================================================
    input  wire [ID_WIDTH-1:0]      m_axi_bid,
    input  wire [1:0]               m_axi_bresp,
    input  wire                     m_axi_bvalid,
    output reg                      m_axi_bready,
    
    // ========================================================================
    // AXI4 Read Address Channel
    // ========================================================================
    output reg  [ID_WIDTH-1:0]      m_axi_arid,
    output reg  [ADDR_WIDTH-1:0]    m_axi_araddr,
    output reg  [7:0]               m_axi_arlen,
    output reg  [2:0]               m_axi_arsize,
    output reg  [1:0]               m_axi_arburst,
    output reg                      m_axi_arvalid,
    input  wire                     m_axi_arready,
    
    // ========================================================================
    // AXI4 Read Data Channel
    // ========================================================================
    input  wire [ID_WIDTH-1:0]      m_axi_rid,
    input  wire [DATA_WIDTH-1:0]    m_axi_rdata,
    input  wire [1:0]               m_axi_rresp,
    input  wire                     m_axi_rlast,
    input  wire                     m_axi_rvalid,
    output reg                      m_axi_rready
);

    // ========================================================================
    // 状态机定义
    // ========================================================================
    localparam S_IDLE       = 4'b0000;
    localparam S_AR_VALID   = 4'b0001;
    localparam S_R_DATA     = 4'b0010;
    localparam S_AW_VALID   = 4'b0011;
    localparam S_W_DATA     = 4'b0100;
    localparam S_B_RESP     = 4'b0101;
    localparam S_DONE       = 4'b0110;
    
    reg [3:0] state, next_state;
    
    // ========================================================================
    // 内部寄存器
    // ========================================================================
    reg [ADDR_WIDTH-1:0]    req_addr;
    reg [7:0]               req_len;
    reg                     req_we;
    reg [7:0]               beat_count;
    
    // ========================================================================
    // 状态机转换
    // ========================================================================
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn)
            state <= S_IDLE;
        else
            state <= next_state;
    end
    
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (cache_req && burst_start) begin
                    if (cache_we)
                        next_state = S_AW_VALID;
                    else
                        next_state = S_AR_VALID;
                end
            end
            
            // 读操作
            S_AR_VALID: begin
                if (m_axi_arready)
                    next_state = S_R_DATA;
            end
            
            S_R_DATA: begin
                if (m_axi_rvalid && m_axi_rlast)
                    next_state = S_DONE;
            end
            
            // 写操作
            S_AW_VALID: begin
                if (m_axi_awready)
                    next_state = S_W_DATA;
            end
            
            S_W_DATA: begin
                if (m_axi_wready && m_axi_wlast)
                    next_state = S_B_RESP;
            end
            
            S_B_RESP: begin
                if (m_axi_bvalid)
                    next_state = S_DONE;
            end
            
            S_DONE: begin
                next_state = S_IDLE;
            end
        endcase
    end
    
    // ========================================================================
    // 请求锁存
    // ========================================================================
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            req_addr <= 0;
            req_len <= 0;
            req_we <= 0;
        end else if (state == S_IDLE && cache_req && burst_start) begin
            req_addr <= cache_addr;
            req_len <= burst_len;
            req_we <= cache_we;
        end
    end
    
    // ========================================================================
    // Beat 计数器
    // ========================================================================
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            beat_count <= 0;
        end else if (state == S_IDLE) begin
            beat_count <= 0;
        end else if (state == S_R_DATA && m_axi_rvalid && m_axi_rready) begin
            beat_count <= beat_count + 1;
        end else if (state == S_W_DATA && m_axi_wvalid && m_axi_wready) begin
            beat_count <= beat_count + 1;
        end
    end
    
    // ========================================================================
    // AXI 读地址通道
    // ========================================================================
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            m_axi_arid <= 0;
            m_axi_araddr <= 0;
            m_axi_arlen <= 0;
            m_axi_arsize <= 3'b010;  // 4 bytes
            m_axi_arburst <= 2'b01;  // INCR
            m_axi_arvalid <= 0;
        end else if (state == S_AR_VALID) begin
            m_axi_arvalid <= 1;
            m_axi_araddr <= req_addr;
            m_axi_arlen <= req_len;
            if (m_axi_arready)
                m_axi_arvalid <= 0;
        end else begin
            m_axi_arvalid <= 0;
        end
    end
    
    // ========================================================================
    // AXI 读数据通道
    // ========================================================================
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            m_axi_rready <= 0;
            cache_rdata <= 0;
            cache_valid <= 0;
        end else begin
            m_axi_rready <= (state == S_R_DATA);
            cache_valid <= (state == S_R_DATA && m_axi_rvalid);
            if (state == S_R_DATA && m_axi_rvalid)
                cache_rdata <= m_axi_rdata;
        end
    end
    
    // ========================================================================
    // AXI 写地址通道
    // ========================================================================
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            m_axi_awid <= 0;
            m_axi_awaddr <= 0;
            m_axi_awlen <= 0;
            m_axi_awsize <= 3'b010;  // 4 bytes
            m_axi_awburst <= 2'b01;  // INCR
            m_axi_awvalid <= 0;
        end else if (state == S_AW_VALID) begin
            m_axi_awvalid <= 1;
            m_axi_awaddr <= req_addr;
            m_axi_awlen <= req_len;
            if (m_axi_awready)
                m_axi_awvalid <= 0;
        end else begin
            m_axi_awvalid <= 0;
        end
    end
    
    // ========================================================================
    // AXI 写数据通道
    // ========================================================================
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            m_axi_wdata <= 0;
            m_axi_wstrb <= 4'b1111;
            m_axi_wlast <= 0;
            m_axi_wvalid <= 0;
        end else if (state == S_W_DATA) begin
            m_axi_wvalid <= 1;
            m_axi_wdata <= cache_wdata;
            m_axi_wlast <= (beat_count == req_len);
            if (m_axi_wready && m_axi_wlast)
                m_axi_wvalid <= 0;
        end else begin
            m_axi_wvalid <= 0;
            m_axi_wlast <= 0;
        end
    end
    
    // ========================================================================
    // AXI 写响应通道
    // ========================================================================
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn)
            m_axi_bready <= 0;
        else
            m_axi_bready <= (state == S_B_RESP);
    end
    
    // ========================================================================
    // 输出信号
    // ========================================================================
    assign cache_ready = (state == S_IDLE);
    
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn)
            burst_done <= 0;
        else
            burst_done <= (state == S_DONE);
    end

endmodule
