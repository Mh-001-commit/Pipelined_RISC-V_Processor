`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2022 03:34:31 PM
// Design Name: 
// Module Name: forwardingUnit
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


module forwardingUnit(
    input      [4:0] ID_EX_Rs1, ID_EX_Rs2, MEM_WB_Rd,
    input            MEM_WB_RegWrite,
    output reg       fA, fB
    );
    always @(*) begin
        if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd0) && (MEM_WB_Rd == ID_EX_Rs1)) begin
            fA = 1'b1;
        end
        else begin
            fA = 1'b0;
        end
        if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd0) && (MEM_WB_Rd == ID_EX_Rs2)) begin
            fB = 1'b1;
        end
        else begin
            fB = 1'b0;
        end
    end
endmodule

