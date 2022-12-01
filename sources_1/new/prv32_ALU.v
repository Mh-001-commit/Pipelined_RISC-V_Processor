module prv32_ALU(
	input   wire [31:0] a, b,
	input   wire [4:0]  shamt,
	input   wire [4:0]  ALUSel,
	output  reg  [31:0] r,
	output  wire cf, zf, vf, sf	
);
    
    wire [31:0] add, op_b;
    wire[31:0] sh_i, sh_r;
    
    wire signed [31:0] a_signed;
    reg [63:0] mul;
    reg [63:0] mul_s;
//    wire cfa, cfs;
    
    assign op_b = (~b);
    
    assign {cf, add} = ALUSel[0] ? (a + op_b + 1'b1) : (a + b);
    
    assign zf = (add == 0);
    assign sf = add[31];
    assign vf = (a[31] ^ (op_b[31]) ^ add[31] ^ cf);
    

    assign a_signed = a;
    
    assign sh_i = a_signed >>> shamt;
    assign sh_r = a_signed >>> b;
    always @ * begin
        r = 0;
        (* parallel_case *)
        case (ALUSel)
            // arithmetic
           5'b000_00 : r = add; //ADD
           5'b000_01 : r = add; //SUB
           5'b000_11 : r = b;   //LUI
           // logic
           5'b001_00:  r = a | b;
           5'b001_01:  r = a & b;
           5'b001_11:  r = a ^ b;
           // shift (I)
           5'b010_00:  r = sh_i; //SRAI
           5'b010_01:  r= a >> shamt; //SRLI
           5'b010_10:  r= a <<< shamt; //SLLI
           // slt & sltu
           5'b011_01:  r = {31'b0,(sf != vf)}; 
           5'b011_11:  r = {31'b0,(~cf)};
           // shift (R)
           5'b010_11: r = a <<< b;
           5'b110_01: r = a >> b;
           5'b110_11: r = sh_r;
           // (M)
           //MUL  
           5'b100_00: r = $signed(a)*$signed(b); // MUL
           5'b100_01: r = ($signed(a) * $signed(b)) >>> 32; //MULH
           5'b100_10: begin
                            mul_s = ($signed(a) * $signed({1'b0, b}));
                            r = mul_s[(32+32-1):32];//MULHSU
                      end
           5'b101_00: begin
                            mul= a * b;
                            r = mul[(32+32-1):32];//MULHU
                      end
           // DIV , REM
           5'b101_01: r = (b)? $signed(a) / $signed(b):-32'd1; // DIV
           5'b101_10: r = (b)? a / b:32'd4294967295; // DIVU
           5'b101_11: r = (b)? $signed(a) % $signed(b):a; // REM
           5'b110_00: r = (b)? a % b:a; // REMU
           default: r = 32'd0;
           endcase
           
    end  
endmodule