`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2022 09:39:48 PM
// Design Name: 
// Module Name: rv32p_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rv32p_tb();
reg clk;
reg rst;
parameter clk_period=10;

rv32_pipelined put1(clk, rst);
    initial begin
        clk =1'b1;
        forever begin
            #(clk_period/2)clk=~clk;
        end
    end
    initial begin
        rst=1'b1;
        #(clk_period)
        rst=1'b0;
    end

endmodule
