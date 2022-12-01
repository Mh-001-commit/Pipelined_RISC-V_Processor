`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2022 05:24:36 PM
// Design Name: 
// Module Name: StallModule
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


module StallModule(
    input      rst, pcEnable_in, pcRst_in,
    output reg pcEnable_out, pcRst_out
    );
    initial begin
        pcEnable_out = 1;
        pcRst_out = 0;
    end
    always @(*) begin
        if (rst) begin
            pcEnable_out = 1;
            pcRst_out = 0;
        end else begin
            if (pcEnable_in == 0)
                pcEnable_out = 0;
            if (pcRst_in == 1)
                pcRst_out = 1;
        end
    end
endmodule
