`timescale 1ns / 1ps

module tb_adder;

    // Inputs
    logic [31:0] a;
    logic [31:0] b;
    logic        cin;

    // Outputs
    logic [31:0] sum_rca;
    logic        cout_rca;
    logic [31:0] sum_cla;
    logic        cout_cla;

    // Expected outputs
    logic [32:0] expected_sum;

    // Instantiate the Ripple Carry Adder
    rca_32bit dut_rca (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum_rca),
        .cout(cout_rca)
    );

    // Instantiate the Carry Lookahead Adder
    cla_32bit dut_cla (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum_cla),
        .cout(cout_cla)
    );

    initial begin
        $dumpfile("adder_wave.vcd");
        $dumpvars(0, tb_adder);

        // TODO: Initialize inputs
        a = 0; b = 0; cin = 0;

        // Test Loop
        repeat (10) begin
            #10;
            // TODO: Generate random inputs
            // a = $random;
            // b = ...
            
            #1; // Wait for logic to settle

            // Calculate expected result
            expected_sum = a + b + cin;

            // Check RCA
            if ({cout_rca, sum_rca} !== expected_sum) begin
                $display("RCA Error: A=%h B=%h Cin=%b | Exp=%h | Got=%h", a, b, cin, expected_sum, {cout_rca, sum_rca});
            end else begin
                $display("RCA OK: A=%h B=%h", a, b);
            end

            // Check CLA
            if ({cout_cla, sum_cla} !== expected_sum) begin
                $display("CLA Error: A=%h B=%h Cin=%b | Exp=%h | Got=%h", a, b, cin, expected_sum, {cout_cla, sum_cla});
            end else begin
                $display("CLA OK: A=%h B=%h", a, b);
            end
        end

        $finish;
    end

endmodule
