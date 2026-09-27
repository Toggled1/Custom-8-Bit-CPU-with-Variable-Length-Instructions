`timescale 1ns / 1ps

module alu_tb;
    logic [7:0] op_A = '0;
    logic [7:0] op_B = '0;
    logic [3:0] ALU_op = '0;
    logic [7:0] ALU_result;
    logic Z, C, N, V;

    alu dut (
        .op_A(op_A),
        .op_B(op_B),
        .ALU_op(ALU_op),
        .ALU_result(ALU_result),
        .Z(Z),
        .C(C),
        .N(N),
        .V(V)
    );



    initial begin
        $dumpfile("dump_alu.vcd");
        $dumpvars(0, alu_tb);

        // MOVE passes operand B through.
        op_A = 8'hA5;
        op_B = 8'h3C;
        ALU_op = 4'b0011;
        #1;
        if (ALU_result !== 8'h3C || {Z, C, N, V} !== 4'b0000)
            $fatal(1, "ALU MOVE test failed");


        // Unsigned carry and zero result.
        op_A = 8'hFF;
        op_B = 8'h01;
        ALU_op = 4'b1011;
        #1;
        if (ALU_result !== 8'h00 || {Z, C, N, V} !== 4'b1100)
            $fatal(1, "ALU ADD carry/zero test failed");


        // Signed overflow from 127 + 1.
        op_A = 8'h7F;
        op_B = 8'h01;
        #1;
        if (ALU_result !== 8'h80 || {Z, C, N, V} !== 4'b0011)
            $fatal(1, "ALU ADD signed-overflow test failed");



        $display("alu_tb passed");
        $finish;
    end
endmodule
