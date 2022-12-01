`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2022 08:56:55 PM
// Design Name: 
// Module Name: branchModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Takes pcSig generated at Control module, func3 bits from instruction
// zero flag (zf), sign flag (sf), overflow flag (vf), carry flag (cf) and jal flag
// and decides the pcSel line for pc 00->pc+4, 01->pc+offset, 10->rs1+offset, 11->0
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module branchModule(
    input      [2:0] func3,
    input      [1:0] pcSig,
    input            jal, zf, cf, vf, sf,
    output reg [1:0] pcSel
    );
    always @(*) begin
        if (pcSig == 2'b00 || pcSig == 2'b11 || pcSig == 2'b10) begin
            pcSel = pcSig;
        end 
        else begin
            if (jal) begin
                pcSel = pcSig;
            end 
            else begin
                case (func3)
                    3'b000: pcSel = (zf)?       pcSig : 2'b00; // BEQ
                    3'b001: pcSel = (~zf)?      pcSig : 2'b00; // BNE
                    3'b100: pcSel = (sf != vf)? pcSig : 2'b00; // BLT
                    3'b101: pcSel = (sf == vf)? pcSig : 2'b00; // BGE
                    3'b110: pcSel = (~cf)?      pcSig : 2'b00; // BLTU
                    3'b111: pcSel = (cf)?       pcSig : 2'b00; // BGEU
                    default: pcSel = 2'b00;
                endcase
            end
        end  
    end
endmodule
