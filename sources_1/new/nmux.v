`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2022 01:02:10 PM
// Design Name: 
// Module Name: nmux
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

module nmux #(parameter N=32) (
    input [N-1:0]  a, b,
    input          s,
    output [N-1:0] c
    );
    genvar i;
    generate 
        for (i=0;i<N;i=i+1) begin 
            mux m1(a[i],b[i],s,c[i]);
        end
    endgenerate
endmodule
