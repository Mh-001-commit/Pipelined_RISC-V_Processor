`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2022 07:22:22 PM
// Design Name: 
// Module Name: TheMemory
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
`include "defines.v"

module TheMemory(
    input             clk, MemRead, MemWrite, 
    input      [9:0]  addr, 
    input      [31:0] data_in,
    input      [2:0]  func3,
    output reg [31:0] data_out
    );
    
    wire [1:0]  size;
    wire s;
    assign {s,size} = func3;
    reg [7:0] mem [1023:0];
    
    wire [9:0] data_addr;
    assign data_addr = addr + `OFFSET;
    
    always @(*) begin
        if (clk) begin
            data_out = {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
        end else begin
            if (MemRead) begin
                case (size) 
                    2'b10: data_out = {mem[data_addr+3],mem[data_addr+2],mem[data_addr+1],mem[data_addr]};//LW
                    2'b01: data_out = (s)? {16'b0,mem[data_addr+1], mem[data_addr]}: {{16{mem[data_addr+1][7]}}, mem[data_addr+1], {mem[data_addr]}};//LHU --- LH
                    2'b00: data_out = (s)? {24'b0,mem[data_addr]}: {{24{mem[data_addr][7]}}, mem[data_addr]};//LBU --- LB
                endcase
            end
        end
    end
    
    always @(posedge clk) begin
        if (MemWrite)
            case (size) 
                2'b10:{mem[data_addr+3], mem[data_addr+2], mem[data_addr+1],mem[data_addr]} = data_in;         //SW
                2'b01:{mem[data_addr+1], mem[data_addr]} = data_in[15:0]; //SH    
                2'b00:{mem[data_addr]} = data_in[7:0]; 	//SB
            endcase      
    end
    
    
    ///////////////////////////////////////////////////////// Test 1 ///////////////////////////////////////////
    
    initial begin 
        {mem[3],mem[2],mem[1],mem[0]}     = 32'h00000013;  //        addi x0, x0, 0
        {mem[7],mem[6],mem[5],mem[4]}     = 32'h00540413;  //        addi x8, x8, 5	                          
        {mem[11],mem[10],mem[9],mem[8]}   = 32'h00a48493;  //        addi x9, x9, 10                          
        {mem[15],mem[14],mem[13],mem[12]} = 32'h00440413;  // loop:  addi x8, x8, 4       # RAW               
        {mem[19],mem[18],mem[17],mem[16]} = 32'hfe944ee3;  //        blt  x8, x9, loop    # RAW & Control     
        {mem[23],mem[22],mem[21],mem[20]} = 32'hffd40413;  // loop2: addi x8, x8, -3      # RAW               
        {mem[27],mem[26],mem[25],mem[24]} = 32'hfe945ee3;  //        bge x8, x9, loop2    # RAW & Control     
        {mem[31],mem[30],mem[29],mem[28]} = 32'h00728293;  //        addi x5, x5, 7                           
        {mem[35],mem[34],mem[33],mem[32]} = 32'hfe540ae3;  //        beq x8, x5, loop2    # RAW & Control     
        {mem[39],mem[38],mem[37],mem[36]} = 32'hfffe0e13;  //        addi x28, x28, -1                        
        {mem[43],mem[42],mem[41],mem[40]} = 32'hffd30313;  //        addi x6, x6, -3                          
        {mem[47],mem[46],mem[45],mem[44]} = 32'h00130313;  // loop3: addi x6, x6, 1       # RAW               
        {mem[51],mem[50],mem[49],mem[48]} = 32'hffc36ee3;  //        bltu x6, x28, loop3  # RAW & Control     
        {mem[55],mem[54],mem[53],mem[52]} = 32'hfff30313;  //        addi x6, x6, -1                          
        {mem[59],mem[58],mem[57],mem[56]} = 32'h006e7463;  //        bgeu x28, x6, loop4  # RAW & Control     
        {mem[63],mem[62],mem[61],mem[60]} = 32'hfff30313;  //        addi x6, x6, -1                          
        {mem[67],mem[66],mem[65],mem[64]} = 32'h00128293;  // loop4: addi x5, x5, 1                           
        {mem[71],mem[70],mem[69],mem[68]} = 32'h00041463;  //        bne x8, x0, EXIT                         
        {mem[75],mem[74],mem[73],mem[72]} = 32'h00128293;  //        addi x5, x5, 1                           
        {mem[79],mem[78],mem[77],mem[76]} = 32'h00100073;  // EXIT:  ebreak                                                                                                       
    end    
                                                                                      
    
    ////////////////////////////////////// Test 2 //////////////////////////////////////////////////
    
//    initial begin
//        {mem[3],mem[2],mem[1],mem[0]}     = 32'h00000013;  // addi x0,x0,1    
//        {mem[7],mem[6],mem[5],mem[4]}     = 32'h00150513;  // addi x10,x10,1      
//        {mem[11],mem[10],mem[9],mem[8]}   = 32'h00252293;  // slti x5,x10,2       
//        {mem[15],mem[14],mem[13],mem[12]} = 32'hfff58593;  // addi x11,x11,-1     
//        {mem[19],mem[18],mem[17],mem[16]} = 32'h0005b313;  // sltiu x6,x11,0      
//        {mem[23],mem[22],mem[21],mem[20]} = 32'h00134313;  // xori x6,x6,1        
//        {mem[27],mem[26],mem[25],mem[24]} = 32'h00136313;  // ori  x6,x6,1        
//        {mem[31],mem[30],mem[29],mem[28]} = 32'h00037313;  // andi x6,x6,0        
//        {mem[35],mem[34],mem[33],mem[32]} = 32'h00151513;  // slli x10,x10,1      
//        {mem[39],mem[38],mem[37],mem[36]} = 32'h00155513;  // srli x10,x10,1      
//        {mem[43],mem[42],mem[41],mem[40]} = 32'h00a50533;  // add x10,x10,x10     
//        {mem[47],mem[46],mem[45],mem[44]} = 32'h40b50333;  // sub x6,x10,x11      
//        {mem[51],mem[50],mem[49],mem[48]} = 32'h00a513b3;  // sll x7,x10,x10      
//        {mem[55],mem[54],mem[53],mem[52]} = 32'h00a02e33;  // slt x28,x0,x10      
//        {mem[59],mem[58],mem[57],mem[56]} = 32'h00a5beb3;  // sltu x29,x11,x10    
//        {mem[63],mem[62],mem[61],mem[60]} = 32'h00554533;  // xor x10,x10,x5      
//        {mem[67],mem[66],mem[65],mem[64]} = 32'h00555f33;  // srl x30,x10,x5      
//        {mem[71],mem[70],mem[69],mem[68]} = 32'h4055dfb3;  // sra x31, x11,x5     
//        {mem[75],mem[74],mem[73],mem[72]} = 32'h00556433;  // or  x8, x10,x5      
//        {mem[79],mem[78],mem[77],mem[76]} = 32'h00657433;  // and x8, x10, x6   
//        {mem[83],mem[82],mem[81],mem[80]} = 32'h00000073;  // ecall             
//    end
    
    
    ////////////////////////////////////// Test 3 //////////////////////////////////////////////////
    
//        initial begin                                                            
//        {mem[3],mem[2],mem[1],mem[0]}     = 32'h00000013; // addi x0, x0, 0      
//        {mem[7],mem[6],mem[5],mem[4]}     = 32'h00001537; // lui x10, 1          
//        {mem[11],mem[10],mem[9],mem[8]}   = 32'h00001517; // auipc x10, 1        
//        {mem[15],mem[14],mem[13],mem[12]} = 32'h00a58593; // addi x11, x11, 10   
//        {mem[19],mem[18],mem[17],mem[16]} = 32'h00258283; // lb x5, 2(x11)       
//        {mem[23],mem[22],mem[21],mem[20]} = 32'h0035c283; // lbu x5, 3(x11)      
//        {mem[27],mem[26],mem[25],mem[24]} = 32'h00059303; // lh x6, 0(x11)       
//        {mem[31],mem[30],mem[29],mem[28]} = 32'h0005d303; // lhu x6, 0(x11)      
//        {mem[35],mem[34],mem[33],mem[32]} = 32'h0005a383; // lw x7, 0(x11)       
//        {mem[39],mem[38],mem[37],mem[36]} = 32'h00758023; // sb x7, 0(x11)       
//        {mem[43],mem[42],mem[41],mem[40]} = 32'h00659023; // sh x6, 0(x11)       
//        {mem[47],mem[46],mem[45],mem[44]} = 32'h0055a023; // sw x5, 0(x11)       
//        {mem[51],mem[50],mem[49],mem[48]} = 32'h00c002ef; // jal x5, 12          
//        {mem[55],mem[54],mem[53],mem[52]} = 32'h00500033; // add x0, x0, x5      
//        {mem[59],mem[58],mem[57],mem[56]} = 32'h00000463; // beq x0, x0, Exit    
//        {mem[63],mem[62],mem[61],mem[60]} = 32'h000281e7; // L1: jalr x3, 0(x5)  
//        {mem[67],mem[66],mem[65],mem[64]} = 32'h0000000f; // Exit: fence     
        
//        // DATA
//        {mem[13+`OFFSET], mem[12+`OFFSET], mem[11+`OFFSET], mem[10+`OFFSET]} = 32'habdcbacd;                    
//        end                                                                      
    
    
    
      ////////////////////////////////////// Test 4 //////////////////////////////////////////////////

//MUL
//    initial begin
//    {mem[3],mem[2],mem[1],mem[0]}     = 32'h00000013;  // addi x0,x0,0
//    {mem[7],mem[6],mem[5],mem[4]}     = 32'h00500093;  // addi x1,x0,5 
//    {mem[11],mem[10],mem[9],mem[8]}   = 32'h00600113;  // addi x2,x0,6    
//    {mem[15],mem[14],mem[13],mem[12]} = 32'hffc00193;  // addi x3,x0,-4   
//    {mem[19],mem[18],mem[17],mem[16]} = 32'h01e00213;  // addi x4,x0,30   
//    {mem[23],mem[22],mem[21],mem[20]} = 32'h022082b3;  // mul x5,x1,x2              
//    {mem[27],mem[26],mem[25],mem[24]} = 32'h02419333;  // mulh x6,x3,x4               
//    {mem[31],mem[30],mem[29],mem[28]} = 32'h0220a3b3;  // mulhsu x7,x1,x2               
//    {mem[35],mem[34],mem[33],mem[32]} = 32'h0241b433;  // mulhu x8,x3,x4               
//    end
    ////////////////////////////////////// Test 5 //////////////////////////////////////////////////

//DIV and REM
//    initial begin
//    {mem[3],mem[2],mem[1],mem[0]}     = 32'h00000013;  // addi x0,x0,0
//    {mem[7],mem[6],mem[5],mem[4]}     = 32'h00500093;  // addi x1,x0,5 
//    {mem[11],mem[10],mem[9],mem[8]}   = 32'h00600113;  // addi x2,x0,6    
//    {mem[15],mem[14],mem[13],mem[12]} = 32'hffc00193;  // addi x3,x0,-4   
//    {mem[19],mem[18],mem[17],mem[16]} = 32'h01e00213;  // addi x4,x0,30   
//    {mem[23],mem[22],mem[21],mem[20]} = 32'h0220c2b3;  // div x5,x1,x2               
//    {mem[27],mem[26],mem[25],mem[24]} = 32'h0241d333;  // divu x6,x3,x4                
//    {mem[31],mem[30],mem[29],mem[28]} = 32'h0220e3b3;  // rem x7,x1,x2                
//    {mem[35],mem[34],mem[33],mem[32]} = 32'h0241f433;  // remu x8,x3,x4                
//    end

////////////////////////////////////// Test 6 //////////////////////////////////////////////////
// initial begin
// {mem[3],mem[2],mem[1],mem[0]}     = 32'h00000013;        
// {mem[7],mem[6],mem[5],mem[4]}     = 32'h00000593;        // addi x11 x0 0                 
// {mem[11],mem[10],mem[9],mem[8]}   = 32'h00300493;        // addi x9 x0 3                  
// {mem[15],mem[14],mem[13],mem[12]} = 32'h0095d963;       // bge x11 x9 18 <done>           
// {mem[19],mem[18],mem[17],mem[16]} = 32'h0429_4200;      // c.lw x8 x12 0 then c.addi x8 10
// {mem[23],mem[22],mem[21],mem[20]} = 32'h0511_c200;                                        
// {mem[27],mem[26],mem[25],mem[24]} = 32'h09e3_0585;                                        
// {mem[31],mem[30],mem[29],mem[28]} = 32'h0073_fe00;                                       
// {mem[35],mem[34],mem[33],mem[32]} = 16'h0000; 
 
// // data
// {mem[3+`OFFSET], mem[2+`OFFSET], mem[1+`OFFSET], mem[0+`OFFSET]} = 32'h00000000;                                
// end
   
            
endmodule





























