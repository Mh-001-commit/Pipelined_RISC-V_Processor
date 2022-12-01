`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2022 12:08:46 PM
// Design Name: 
// Module Name: register
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


module register #(parameter N=32) (
    input          clk, rst, load,
    input  [N-1:0] d,
    output [N-1:0] q
    );
    genvar i;
    wire [N-1:0] y;
    generate 
        for (i = 0; i < N; i = i+1) begin 
            DFlipFlop ff1(clk, rst, y[i], q[i]);
            mux m1(q[i], d[i], load, y[i]);
        end
    endgenerate
endmodule
