`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2022 12:06:08 PM
// Design Name: 
// Module Name: control
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


module control(
    input       [4:0] inst,
    input             inst20,
    input             inst25,//M-format
    output reg        jal, MemRead,
    output reg  [1:0] WhatToReg,
    output reg        MemWrite, ALUSrc1, ALUSrc2, RegWrite, 
    output reg  [1:0] pcSig, 
    output reg        PC_enable, PC_rst,
    output reg  [3:0] ALUOP 
    );
    always @(*) begin
        case(inst)  
          5'b01101 : begin //LUI
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b0000;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            RegWrite = 1; 
            pcSig = 2'b00;
            PC_enable =1;
            PC_rst = 0;
          end
          5'b00101 : begin //AUIPC
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b0001;
            MemWrite = 0;
            ALUSrc1 = 1;
            ALUSrc2 = 1;
            RegWrite = 1; 
            pcSig = 2'b00;
            PC_enable =1;
            PC_rst = 0;
          end
          5'b11011 : begin //JAL
            jal = 1;
            MemRead = 0;
            WhatToReg = 2'b10;
            ALUOP = 4'b0010;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegWrite = 1; 
            pcSig = 2'b01;
            PC_enable =1;
            PC_rst = 0;
          end
          5'b11001 : begin //JALR
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b10;
            ALUOP = 4'b0011;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            RegWrite = 1; 
            pcSig = 2'b10;
            PC_enable =1;
            PC_rst = 0;
          end
          5'b11000 : begin //B-Format
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b0100;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegWrite = 0; 
            pcSig = 2'b01;
            PC_enable =1; 
            PC_rst = 0;       
          end
          5'b00000 : begin //I-Format (load)
            jal = 0;
            MemRead = 1;
            WhatToReg = 2'b01;
            ALUOP = 4'b0101;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            RegWrite = 1; 
            pcSig = 2'b00;
            PC_enable =1;   
            PC_rst = 0;     
          end
          5'b01000 : begin //S-Format
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b0110;
            MemWrite = 1;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            RegWrite = 0; 
            pcSig = 2'b00;
            PC_enable =1;   
            PC_rst = 0;     
          end
          5'b00100 : begin //I-Format
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b0111;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 1;
            RegWrite = 1; 
            pcSig = 2'b00;
            PC_enable =1;     
            PC_rst = 0;   
          end
          5'b01100 : begin if (!inst25)
           begin //R-Format
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b1000;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegWrite = 1; 
            pcSig = 2'b00;
            PC_enable =1; 
            PC_rst = 0; 
          end 
          else begin
         //M-Format
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b1100;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegWrite = 1; 
            pcSig = 2'b00;
            PC_enable =1; 
            PC_rst = 0; 
          end
          end
          5'b00011 : begin //FENCE
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b1001;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegWrite = 0; 
            pcSig = 2'b11;
            PC_enable =0;      
            PC_rst = 1;  
          end
          5'b11100 : begin
          if (!inst20) begin //ECALL
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b1010;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegWrite = 0; 
            pcSig = 2'b11;
            PC_enable =0;
            PC_rst = 1;
            //$display ("Hello");      
            end        
          else  begin //EBREAK
            jal = 0;
            MemRead = 0;
            WhatToReg = 2'b00;
            ALUOP = 4'b1011;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegWrite = 0; 
            pcSig = 2'b00;
            PC_enable =0;   
            PC_rst = 0; 
          end
          end
          default  : begin
            jal = 0;
            MemRead = 0;
            WhatToReg = 0;
            ALUOP = 4'b0000;
            MemWrite = 0;
            ALUSrc1 = 0;
            ALUSrc2 = 0;
            RegWrite = 0; 
            pcSig = 2'b00;
            PC_enable =1; 
            PC_rst = 0;
          end
        endcase  
    end
endmodule
