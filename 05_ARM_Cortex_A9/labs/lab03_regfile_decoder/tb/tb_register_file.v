// ============================================================================
// File: tb_register_file.v
// Description: Testbench for ARM Register File
// Course: 05_ARM_Cortex_A9 - AI4ICLearning
// ============================================================================

`timescale 1ns / 1ps

module tb_register_file;

    // ========================================================================
    // 参数
    // ========================================================================
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 4;
    parameter CLK_PERIOD = 10;
    
    // ========================================================================
    // 信号声明
    // ========================================================================
    reg                     clk;
    reg                     rst_n;
    reg  [ADDR_WIDTH-1:0]   raddr1, raddr2, raddr3;
    wire [DATA_WIDTH-1:0]   rdata1, rdata2, rdata3;
    reg                     we;
    reg  [ADDR_WIDTH-1:0]   waddr;
    reg  [DATA_WIDTH-1:0]   wdata;
    reg  [DATA_WIDTH-1:0]   pc_in;
    
    // ========================================================================
    // DUT 实例化
    // ========================================================================
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_dut (
        .clk    (clk),
        .rst_n  (rst_n),
        .raddr1 (raddr1),
        .raddr2 (raddr2),
        .raddr3 (raddr3),
        .rdata1 (rdata1),
        .rdata2 (rdata2),
        .rdata3 (rdata3),
        .we     (we),
        .waddr  (waddr),
        .wdata  (wdata),
        .pc_in  (pc_in)
    );
    
    // ========================================================================
    // 时钟生成
    // ========================================================================
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // ========================================================================
    // 测试序列
    // ========================================================================
    integer i;
    integer error_count;
    
    initial begin
        $display("====================================");
        $display("Register File Testbench");
        $display("====================================");
        
        // 初始化
        error_count = 0;
        rst_n = 0;
        raddr1 = 0;
        raddr2 = 0;
        raddr3 = 0;
        we = 0;
        waddr = 0;
        wdata = 0;
        pc_in = 32'h0000_1000;
        
        // 复位
        #(CLK_PERIOD * 5);
        rst_n = 1;
        #(CLK_PERIOD * 2);
        
        // ====================================================================
        // 测试 1: 写入所有寄存器 (R0-R14)
        // ====================================================================
        $display("\n[Test 1] Writing to registers R0-R14...");
        
        for (i = 0; i < 15; i = i + 1) begin
            @(posedge clk);
            we = 1;
            waddr = i;
            wdata = 32'hA000_0000 + i;
        end
        @(posedge clk);
        we = 0;
        
        $display("Write complete.");
        
        // ====================================================================
        // 测试 2: 读取所有寄存器
        // ====================================================================
        $display("\n[Test 2] Reading registers R0-R14...");
        
        for (i = 0; i < 15; i = i + 1) begin
            @(posedge clk);
            raddr1 = i;
            @(negedge clk);
            
            if (rdata1 !== 32'hA000_0000 + i) begin
                $display("  ERROR: R%0d = 0x%08X, expected 0x%08X", 
                         i, rdata1, 32'hA000_0000 + i);
                error_count = error_count + 1;
            end else begin
                $display("  PASS: R%0d = 0x%08X", i, rdata1);
            end
        end
        
        // ====================================================================
        // 测试 3: R15 (PC) 读取
        // ====================================================================
        $display("\n[Test 3] Reading R15 (PC)...");
        
        pc_in = 32'h0000_2000;
        @(posedge clk);
        raddr1 = 4'd15;
        @(negedge clk);
        
        // R15 应该返回 PC + 8
        if (rdata1 !== 32'h0000_2008) begin
            $display("  ERROR: R15 = 0x%08X, expected 0x%08X", 
                     rdata1, 32'h0000_2008);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: R15 (PC+8) = 0x%08X", rdata1);
        end
        
        // ====================================================================
        // 测试 4: 同时读三个端口
        // ====================================================================
        $display("\n[Test 4] Simultaneous 3-port read...");
        
        @(posedge clk);
        raddr1 = 4'd0;
        raddr2 = 4'd7;
        raddr3 = 4'd14;
        @(negedge clk);
        
        if (rdata1 !== 32'hA000_0000) begin
            $display("  ERROR: Port1 R0 = 0x%08X, expected 0x%08X", 
                     rdata1, 32'hA000_0000);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Port1 R0 = 0x%08X", rdata1);
        end
        
        if (rdata2 !== 32'hA000_0007) begin
            $display("  ERROR: Port2 R7 = 0x%08X, expected 0x%08X", 
                     rdata2, 32'hA000_0007);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Port2 R7 = 0x%08X", rdata2);
        end
        
        if (rdata3 !== 32'hA000_000E) begin
            $display("  ERROR: Port3 R14 = 0x%08X, expected 0x%08X", 
                     rdata3, 32'hA000_000E);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Port3 R14 = 0x%08X", rdata3);
        end
        
        // ====================================================================
        // 测试 5: 写后立即读 (Bypass)
        // ====================================================================
        $display("\n[Test 5] Write-then-read bypass...");
        
        @(posedge clk);
        we = 1;
        waddr = 4'd5;
        wdata = 32'hDEAD_BEEF;
        raddr1 = 4'd5;
        @(negedge clk);
        
        // 应该通过旁路读取新写入的值
        if (rdata1 !== 32'hDEAD_BEEF) begin
            $display("  ERROR: Bypass read R5 = 0x%08X, expected 0xDEAD_BEEF", 
                     rdata1);
            error_count = error_count + 1;
        end else begin
            $display("  PASS: Bypass read R5 = 0x%08X", rdata1);
        end
        
        @(posedge clk);
        we = 0;
        
        // ====================================================================
        // 结果汇总
        // ====================================================================
        #(CLK_PERIOD * 5);
        $display("\n====================================");
        if (error_count == 0) begin
            $display("All Tests PASSED!");
        end else begin
            $display("Tests FAILED with %0d errors", error_count);
        end
        $display("====================================");
        
        $finish;
    end
    
    // ========================================================================
    // 波形记录
    // ========================================================================
    initial begin
        $dumpfile("tb_register_file.vcd");
        $dumpvars(0, tb_register_file);
    end

endmodule
