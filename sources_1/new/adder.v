module adder#(parameter N = 32) (
    input   [N-1:0] A, B,
    input           cin,
    output  [N-1:0] sum
);
    assign sum = A + B + cin;
endmodule
