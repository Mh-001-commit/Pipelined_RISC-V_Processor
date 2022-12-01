`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2022 11:21:05 PM
// Design Name: 
// Module Name: ALUControl
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


module ALUcontrol(
    input      [3:0] ALUOp,
    input      [2:0] func3,
    input            inst30,
    output reg [4:0] ALUSel
    );
    always @(*) begin
        case(ALUOp)
            4'b0000: ALUSel = 5'b000_11;
            4'b0001: ALUSel = 5'b000_00;
            4'b0010: ALUSel = 5'b000_00;
            4'b0011: ALUSel = 5'b000_00;
            4'b0100: ALUSel = 5'b000_01;
            4'b0101: ALUSel = 5'b000_00;
            4'b0110: ALUSel = 5'b000_00;
            4'b0111: begin
                case (func3)
                    3'b000: ALUSel = 5'b000_00;
                    3'b010: ALUSel = 5'b011_01;
                    3'b011: ALUSel = 5'b011_11;
                    3'b100: ALUSel = 5'b001_11;
                    3'b110: ALUSel = 5'b001_00;
                    3'b111: ALUSel = 5'b001_01;
                    3'b001: ALUSel = 5'b010_10;
                    default: begin
                        if (inst30)
                            ALUSel = 5'b010_00;
                        else
                            ALUSel = 5'b010_01;
                    end
                endcase
            end
            4'b1000: begin
                case (func3)
                    3'b000: begin
                        if (inst30)
                            ALUSel = 5'b000_01;
                        else
                            ALUSel = 5'b000_00;
                    end
                    3'b001: ALUSel = 5'b010_11;
                    3'b010: ALUSel = 5'b011_01;
                    3'b011: ALUSel = 5'b011_11;
                    3'b100: ALUSel = 5'b001_11;
                    3'b101: begin
                        if (inst30)
                            ALUSel = 5'b110_11;
                        else
                            ALUSel = 5'b110_01;
                    end
                    3'b110: ALUSel = 5'b001_00;
                    3'b111: ALUSel = 5'b001_01;
                endcase
            end
            4'b1001: ALUSel = 5'b111_11;
            4'b1010: ALUSel = 5'b111_11;
            4'b1011: ALUSel = 5'b111_11;
            4'b1100: begin
                           case(func3)
                                3'b000: ALUSel = 5'b100_00;//MUL
                                3'b001: ALUSel = 5'b100_01;//MULH
                                3'b010: ALUSel = 5'b100_10;//MULHSU
                                3'b011: ALUSel = 5'b101_00;//MULHU
                                3'b100: ALUSel = 5'b101_01;//DIV
                                3'b101: ALUSel = 5'b101_10;//DIVU
                                3'b110: ALUSel = 5'b101_11;//REM
                                3'b111: ALUSel = 5'b110_00;//REMU
                            endcase
                     end
        endcase
    end
endmodule
