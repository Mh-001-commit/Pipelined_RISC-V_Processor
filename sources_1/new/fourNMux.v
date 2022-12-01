`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2022 10:53:35 PM
// Design Name: 
// Module Name: fourNMux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Basic 4-way mux for N-bit input
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fourNMux #(parameter N=32)(
    input [N-1:0] a, b, c, d,
    input [1:0] s,
    output reg [N-1:0] out
    );
    always @(*) begin
        case (s)
            2'b00: out = a;
            2'b01: out = b;
            2'b10: out = c;
            default: out = d;
        endcase
    end
endmodule
