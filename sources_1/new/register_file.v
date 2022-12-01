`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2022 01:36:49 PM
// Design Name: 
// Module Name: register_file
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


module register_file #(parameter N = 32) (
    input          clk, rst, RegWrite, 
    input  [4:0]   ReadReg1, ReadReg2, WriteReg,
    input  [N-1:0] WriteData,
    output [N-1:0] ReadData1, ReadData2
    );
    genvar i;
    wire [N-1:0] data [31:0];
    generate
        for (i = 0; i < 32; i=i+1) begin
            register #(N) rr (clk, rst, ((WriteReg == i) && RegWrite && (WriteReg != 0)), WriteData, data[i]);
        end
    endgenerate
    assign ReadData1 = data[ReadReg1];
    assign ReadData2 = data[ReadReg2];   
endmodule
