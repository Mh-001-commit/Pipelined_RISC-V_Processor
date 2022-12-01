`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2022 07:29:21 PM
// Design Name: 
// Module Name: rv32_pipelined
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


module rv32_pipelined(
    input clk, rst
    );
    
    // IF Wires
    wire [31:0] pc, pcPlus4, nextPc;
    wire        realEnable, realRst;
   
    // ID Wires
    wire [31:0] IF_ID_PC, IF_ID_pcPlus4, IF_ID_IR;
    wire [31:0] readData1, readData2, imm;
    wire [4:0]  readReg1, readReg2, writeReg;
    wire        jal, memRead, memWrite, ALUSrc1, ALUSrc2, regWrite; 
    wire        pcEnable, pcRst;
    wire [1:0]  whatToReg, pcSig;
    wire [3:0]  ALUOP;  

    // EXE Wires
    wire [31:0] ID_EX_PC, ID_EX_pcPlus4, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm;
    wire        ID_EX_IR30;
    wire [2:0]  ID_EX_Func3;
    wire [4:0]  ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd, ID_EX_shamt;
    wire        ID_EX_jal, ID_EX_memRead;
    wire [1:0]  ID_EX_whatToReg, ID_EX_pcSig;
    wire        ID_EX_memWrite, ID_EX_ALUSrc1, ID_EX_ALUSrc2, ID_EX_regWrite, ID_EX_pcEnable; 
    wire [3:0]  ID_EX_ALUOP;
    wire [9:0]  addrOutput;
    wire [31:0] ALUInput1, ALUInput2, ALURes;
    wire [1:0]  pcSel;
    wire        cf, zf, vf, sf; 
    wire [4:0]  ALUSel;
    wire [31:0] offsetPc;
    
    // MEM Wires
    wire [31:0] EX_MEM_pcPlus4, EX_MEM_ALURes; 
    wire [1:0]  EX_MEM_whatToReg;
    wire        EX_MEM_regWrite; 
    wire [2:0]  EX_MEM_Func3;
    wire [4:0]  EX_MEM_Rd;
    wire [31:0] EX_MEM_DataIn;
    wire EX_MEM_memRead, EX_MEM_memWrite;
    
    wire [31:0] memReadData;
    
    // WB Wires
    wire [31:0] MEM_WB_pcPlus4, MEM_WB_ALURes, MEM_WB_memReadData;
    wire        MEM_WB_regWrite;
    wire [4:0]  MEM_WB_Rd;
    wire [1:0]  MEM_WB_whatToReg;
    wire [31:0] writeData;
    
    
    //Forwarding unit
    wire fA,fB;
    wire [31:0] outMuxFwdA,outMuxFwdB;
    //flush 
    wire [31:0] NOP = 32'h00000013;
    wire [31:0] IR;
    wire branch = (pcSel!=2'b00);
    
    
    //Decompression 
    wire is_comp;
    wire [31:0] decomp;
    
    
    
 //////////////////////////////////////////////////////////// IF ////////////////////////////////////////////////////////////

    StallModule stall(.rst(rst), .pcEnable_in(pcEnable), .pcRst_in(pcRst), .pcEnable_out(realEnable), .pcRst_out(realRst));
    
    register #(32) PCR(.clk(clk), .rst(rst || realRst), .load(realEnable), .d(nextPc), .q(pc));
    
    // adder #(32) pcPlus4Adder(.A(pc), .B(32'd4), .cin(0), .sum(pcPlus4));
    
    nmux #(10) MemAddrMux(.a(EX_MEM_ALURes[9:0]), .b(pc[9:0]), .s(clk), .c(addrOutput));
    
    TheMemory Mem(.clk(clk), .MemRead(EX_MEM_memRead), .MemWrite(EX_MEM_memWrite), .addr(addrOutput),
     .data_in(EX_MEM_DataIn), .func3(EX_MEM_Func3), .data_out(memReadData));
    
    nmux #(32) IF_ID_mux(memReadData,NOP ,branch ,IR);
            
//    register #(96) IF_ID (
//        .clk(~clk), .rst(rst), .load(1),
//        .d({pc, pcPlus4, IR}),  // 
//        .q({IF_ID_PC, IF_ID_pcPlus4, IF_ID_IR})
//    );
    //For DecompressionUnit
    adder #(32) pcPlus4Adder(.A(pc), .B(is_comp?32'd2:32'd4), .cin(0), .sum(pcPlus4));
    DecompressionUnit DU(.clk(clk), .rst(rst), .inst(IR), .new_inst(decomp), .is_comp(is_comp));
    
    register #(96) IF_ID (
        .clk(~clk), .rst(rst), .load(1),
        .d({pc, pcPlus4, decomp}),  // 
        .q({IF_ID_PC, IF_ID_pcPlus4, IF_ID_IR})
    );

 //////////////////////////////////////////////////////////// ID ////////////////////////////////////////////////////////////
    assign readReg1 = IF_ID_IR[`IR_rs1];
    assign readReg2 = IF_ID_IR[`IR_rs2];
    assign writeReg = IF_ID_IR[`IR_rd];
        
    rv32_ImmGen ImmGen(.IR(IF_ID_IR), .Imm(imm));
    
    control controlUnit (.inst(IF_ID_IR[`IR_opcode]), .inst20(IF_ID_IR[20]), .inst25(IF_ID_IR[25]), .jal(jal), 
                        .MemRead(memRead), .WhatToReg(whatToReg), .MemWrite(memWrite),
                        .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .RegWrite(regWrite),
                        .pcSig(pcSig), .PC_enable(pcEnable), .PC_rst(pcRst), .ALUOP(ALUOP));
    
    
    register_file #(32) RF(.clk(~clk), .rst(rst), .RegWrite(MEM_WB_regWrite), .ReadReg1(readReg1),
                           .ReadReg2(readReg2), .WriteReg(MEM_WB_Rd), .WriteData(writeData),
                           .ReadData1(readData1), .ReadData2(readData2));
    
    register #(200) ID_EX (
        .clk(clk), .rst(rst), .load(1),
        .d({IF_ID_PC, IF_ID_pcPlus4, readData1, readData2,
            imm, IF_ID_IR[30], IF_ID_IR[`IR_funct3], IF_ID_IR[`IR_shamt], readReg1, readReg2, writeReg,
            jal, memRead, whatToReg, memWrite, ALUSrc1, ALUSrc2, regWrite, pcSig, pcEnable, pcRst, ALUOP}),
        .q({ID_EX_PC, ID_EX_pcPlus4, ID_EX_RegR1, ID_EX_RegR2,
            ID_EX_Imm, ID_EX_IR30, ID_EX_Func3, ID_EX_shamt, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd,
            ID_EX_jal, ID_EX_memRead, ID_EX_whatToReg, ID_EX_memWrite, ID_EX_ALUSrc1, ID_EX_ALUSrc2, ID_EX_regWrite,
            ID_EX_pcSig, ID_EX_pcEnable, ID_EX_pcRst, ID_EX_ALUOP}) 
    );
    
    
 //////////////////////////////////////////////////////////// EX ////////////////////////////////////////////////////////////
    ALUcontrol ALUControl (.ALUOp(ID_EX_ALUOP), .func3(ID_EX_Func3), .inst30(ID_EX_IR30),
                           .ALUSel(ALUSel));
    forwardingUnit fwdUnit (ID_EX_Rs1, ID_EX_Rs2, MEM_WB_Rd, MEM_WB_regWrite, fA, fB);
    
    nmux #(32) FAMux (.a(ID_EX_RegR1),.b(writeData),.s(fA),.c(outMuxFwdA));
    nmux #(32) FBMux (.a(ID_EX_RegR2),.b(writeData),.s(fB),.c(outMuxFwdB));
    nmux #(32) ALUSrc1Mux(.a(outMuxFwdA), .b(ID_EX_PC), .s(ID_EX_ALUSrc1), .c(ALUInput1));
    nmux #(32) ALUSrc2Mux(.a(outMuxFwdB), .b(ID_EX_Imm), .s(ID_EX_ALUSrc2), .c(ALUInput2));
    
    prv32_ALU ALUMain(.a(ALUInput1), .b(ALUInput2), .shamt(ID_EX_shamt), .ALUSel(ALUSel),
                      .r(ALURes), .cf(cf), .zf(zf), .vf(vf), .sf(sf));
    
    branchModule Branch(.func3(ID_EX_Func3), .pcSig(ID_EX_pcSig), .jal(ID_EX_jal), .zf(zf), .cf(cf), 
                        .vf(vf), .sf(sf), .pcSel(pcSel));
                        
    assign pcRst = (pcSel == 2'b11);
    
    adder #(32) offsetPcAdder(.A(ID_EX_Imm), .B(ID_EX_PC), .cin(0), .sum(offsetPc));  
     
    register #(109) EX_MEM ( 
        .clk(~clk), .rst(rst), .load(1),
        .d({ID_EX_pcPlus4, outMuxFwdB, ID_EX_memRead, ID_EX_memWrite, 
            ID_EX_whatToReg, ID_EX_Func3, ID_EX_regWrite, ALURes, ID_EX_Rd}),
        .q({EX_MEM_pcPlus4, EX_MEM_DataIn, EX_MEM_memRead, EX_MEM_memWrite, 
            EX_MEM_whatToReg, EX_MEM_Func3, EX_MEM_regWrite, EX_MEM_ALURes, EX_MEM_Rd})
    );
    
 //////////////////////////////////////////////////////////// MEM ////////////////////////////////////////////////////////////
    register #(104) MEM_WB (
        .clk(clk), .rst(rst), .load(1),
        .d({EX_MEM_pcPlus4, EX_MEM_whatToReg, EX_MEM_regWrite, EX_MEM_ALURes, EX_MEM_Rd, memReadData}),
        .q({MEM_WB_pcPlus4, MEM_WB_whatToReg, MEM_WB_regWrite, MEM_WB_ALURes, MEM_WB_Rd, MEM_WB_memReadData})
    ); 
    
 //////////////////////////////////////////////////////////// WB ////////////////////////////////////////////////////////////
    
    fourNMux #(32) writeDataMux(.a(MEM_WB_ALURes), .b(MEM_WB_memReadData), .c(MEM_WB_pcPlus4), .d(32'd0), .s(MEM_WB_whatToReg), 
                      .out(writeData));
    fourNMux #(32) pcMux (.a(pcPlus4), .b(offsetPc), .c(ALURes), .d(0), .s(pcSel), .out(nextPc));
endmodule
