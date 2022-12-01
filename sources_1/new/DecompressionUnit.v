`timescale 1ns / 1ps


module DecompressionUnit(
input clk,
input rst,
input  [31:0] inst,
output reg [31:0] new_inst,
output reg is_comp
);
always @(*) begin
    case (inst[1:0])//1
        2'b11: begin
            is_comp = 0;
            new_inst = inst;
       end          
       2'b00: begin
            is_comp = 1;
            case(inst[15:13])//2
                 // c.lw -> lw rd', imm(rs1') 
                3'b010: begin   
                   new_inst = {5'b0, inst[5], inst[12:10], inst[6],
                   2'b00, 2'b01, inst[9:7], 3'b010, 2'b01, inst[4:2], 7'b0000011};
                end  
                // c.sw -> sw rs2', imm(rs1')
                3'b110: begin
                   new_inst = {5'b0, inst[5], inst[12], 2'b01, inst[4:2],
                   2'b01, inst[9:7], 3'b010, inst[11:10], inst[6],
                   2'b00, 7'b0100011};
                end  
            endcase //2
       end 
       2'b01: begin
          is_comp = 1;
          case (inst[15:13])//3
          3'b000: begin
                        // c.addi -> addi rd, rd, nzimm
                        // c.nop
                        new_inst = {{6 {inst[12]}}, inst[12], inst[6:2],
                       inst[11:7], 3'b0, inst[11:7], 7'b0010011};
                  end
          3'b001: begin
                            // 001: c.jal -> jal x1, imm
                            new_inst = {inst[12], inst[8], inst[10:9], inst[6],
                            inst[7], inst[2], inst[11], inst[5:3],
                            {9 {inst[12]}}, 4'b0, ~inst[15], 7'b1101111};
                      end
          3'b011: begin
                             // c.lui -> lui rd, imm
                               new_inst = {{15 {inst[12]}}, inst[6:2], inst[11:7], 7'b0110111};
                   end
          3'b100: begin 
                    case (inst[11:10])//4  
                         2'b00, 2'b01: begin
                            // 00: c.srli -> srli rd, rd, shamt
                            // 01: c.srai -> srai rd, rd, shamt
                            new_inst = {1'b0, inst[10], 5'b0, inst[6:2], 2'b01, inst[9:7],
                             3'b101, 2'b01, inst[9:7], 7'b0010011};
                        end   
                         2'b10: begin
                            // c.andi -> andi rd, rd, imm
                            new_inst = {{6 {inst[12]}}, inst[12], inst[6:2], 2'b01, inst[9:7],
                            3'b111, 2'b01, inst[9:7], 7'b0010011 };
                         end                                                      
                         2'b11: begin
                             case ({inst[12], inst[6:5]})//5
                                  3'b000: begin
                                        // c.sub -> sub rd', rd', rs2'
                                        new_inst = {2'b01, 5'b0, 2'b01, inst[4:2], 2'b01, inst[9:7],
                                        3'b000, 2'b01, inst[9:7], 7'b0110011};
                                   end        
                                  3'b001: begin
                                        // c.xor -> xor rd', rd', rs2'
                                        new_inst = {7'b0, 2'b01, inst[4:2], 2'b01, inst[9:7], 3'b100,
                                                   2'b01, inst[9:7], 7'b0110011};
                                   end
                                  3'b010: begin                                                  
                                        // c.or  -> or  rd', rd', rs2'                               
                                        new_inst = {7'b0, 2'b01, inst[4:2], 2'b01, inst[9:7], 3'b110,
                                                   2'b01, inst[9:7], 7'b0110011};                    
                                   end                                                            
                                  3'b011: begin
                                         // c.and -> and rd', rd', rs2'
                                            new_inst = {7'b0, 2'b01, inst[4:2], 2'b01, inst[9:7], 3'b111,
                                                       2'b01, inst[9:7], 7'b0110011};
                                  end
                             endcase//5
                         end
                   endcase//4 
                end      
           endcase//3
          end
               2'b10: begin
                              is_comp = 1;
                              case (inst[15:13])//6
                              3'b010: begin
                                            // c.slli -> slli rd, rd, shamt
                                            new_inst = {7'b0, inst[6:2], inst[11:7], 3'b001, inst[11:7], 7'b0010011};
                                       end
                              3'b100: begin
                                          // ebreak
                                          if (inst[11:2] == 0) 
                                          new_inst = {32'h00_10_00_73};
                                          //c.jalr
                                          else if (inst[6:2] == 0)
                                          new_inst = {12'b0, inst[11:7], 3'b000, 5'b00001, 7'b1100111};
                                          // c.add -> add rd, rd, rs2
                                          else 
                                           new_inst = {12'b0, inst[11:7], 3'b000, 5'b00001, 7'b0110011};
                                       end          
                              endcase//6
                      end
        endcase//1                      
                   
end //always


endmodule
