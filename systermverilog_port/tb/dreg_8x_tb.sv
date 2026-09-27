`timescale 1ns / 1ps

module dreg_8x_tb;
    logic clk = 1'b0;
    logic reset = 1'b0;
    logic write_enable = 1'b0;
    logic [7:0] din = '0;
    logic [2:0] write_select = '0;
    logic [2:0] read_select = '0;
    logic [7:0] dout;

    always #5 clk = ~clk;

    Dreg_8x dut (
        .din(din),
        .dout(dout),
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .write_select(write_select),
        .read_select(read_select)
    );


    //begin test block

    initial begin
        $dumpfile("dump_dreg_8x.vcd");
        $dumpvars(0, dreg_8x_tb);

        // Synchronous reset clears all eight registers.
        reset = 1'b1;
        @(posedge clk);
        #1;
        if (dout !== 8'h00)
            $fatal(1, "Dreg_8x reset test failed");
        reset = 1'b0;

        // Write and read register 3.
        @(negedge clk);
        write_enable = 1'b1;
        write_select = 3'd3;
        din = 8'hA5;
        @(posedge clk);
        #1;
        write_enable = 1'b0;
        read_select = 3'd3;
        #1;
        if (dout !== 8'hA5)
            $fatal(1, "Dreg_8x register 3 write/read test failed");



        // Write another register and verify the first one was preserved.
        @(negedge clk);
        write_enable = 1'b1;
        write_select = 3'd6;
        din = 8'h3C;
        @(posedge clk);
        #1;
        write_enable = 1'b0;
        read_select = 3'd6;
        #1;
        if (dout !== 8'h3C)
            $fatal(1, "Dreg_8x register 6 write/read test failed");

        read_select = 3'd3;
        #1;
        if (dout !== 8'hA5)
            $fatal(1, "Dreg_8x register isolation test failed");

        // Disabled writes must not change the selected register.
        @(negedge clk);
        din = 8'hFF;
        @(posedge clk);
        #1;
        read_select = 3'd6;
        #1;
        if (dout !== 8'h3C)
            $fatal(1, "Dreg_8x write-disable hold test failed");




        $display("dreg_8x_tb passed");
        $finish;
    end
endmodule
