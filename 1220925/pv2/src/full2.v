`timescale 1ns/1ps
//////////////main/////////////
module bcd_adder_ndigit_with_lookahead#(parameter N=3)(
input clk,
input[4*N-1:0] A,B,
input Cin,
output[4*N-1:0] Sum,
output Cout
);

wire[4*N-1:0] A_buf,B_buf,sum_internal;
wire[N:0] carry;
assign carry[0]=Cin; //start carry from Cin

genvar i;

//input flip-flop
generate for(i=0;i<N;i=i+1)begin:input_regs
dff4 dff_a(.clk(clk),.D(A[4*i +:4]),.Q(A_buf[4*i +:4])); //store A
dff4 dff_b(.clk(clk),.D(B[4*i +:4]),.Q(B_buf[4*i +:4])); //store B
end endgenerate

//do BCD add
generate for(i=0;i<N;i=i+1)begin:bcd_digits
bcd_adder bcd_i(
.A(A_buf[4*i +:4]),
.B(B_buf[4*i +:4]),
.Cin(carry[i]),
.BCD_Sum(sum_internal[4*i +:4]),
.Cout(carry[i+1])
);
end endgenerate

//output flip-flop
generate for(i=0;i<N;i=i+1)begin:output_regs
dff4 dff_s(.clk(clk),.D(sum_internal[4*i +:4]),.Q(Sum[4*i +:4])); //store sum
end endgenerate

//last carry flip-flop
dff1 dff_cout(.clk(clk),.D(carry[N]),.Q(Cout)); //store Cout

endmodule

////////////////////////////////////////////////////////////////////////////////////////////
//BCD Adder with correction. If raw sum > 9 or got carry, add 6 using second CLA.
////////////////////////////////////////////////////////////////////////////////////////////
module bcd_adder (
    input [3:0] A,B,
    input Cin,
    output [3:0] BCD_Sum,
    output Cout
);
    wire [3:0] binary_sum;
    wire carry_out;
    wire correction_needed;
    wire [3:0] correction = 4'd6;
    wire [3:0] fix;

    assign correction_needed = (binary_sum > 4'd9) | carry_out;
    assign fix = correction_needed ? correction : 4'd0;

    cla_4bit_adder cla1(
        .A(A),.B(B),.Cin(Cin),
        .Sum(binary_sum),.Cout(carry_out)
    );

    wire [3:0] corrected_sum;
    wire dummy_cout;

    cla_4bit_adder cla2(
        .A(binary_sum),.B(fix),.Cin(1'b0),
        .Sum(corrected_sum),.Cout(dummy_cout)
    );

    assign BCD_Sum = corrected_sum;
    assign Cout = correction_needed;
endmodule

////////////////////////////////////////////////////////////////////////////////////////////
//4-bit Carry Lookahead Adder based on M. Mano book (Structural only)
////////////////////////////////////////////////////////////////////////////////////////////
module cla_4bit_adder(
    input [3:0] A,B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire [3:0] G,P,C;
    wire [15:0] temp;

    // Generate
    and #11 g0(G[0],A[0],B[0]);
    and #11 g1(G[1],A[1],B[1]);
    and #11 g2(G[2],A[2],B[2]);
    and #11 g3(G[3],A[3],B[3]);

    // Propagate
    xor #15 p0(P[0],A[0],B[0]);
    xor #15 p1(P[1],A[1],B[1]);
    xor #15 p2(P[2],A[2],B[2]);
    xor #15 p3(P[3],A[3],B[3]);

    assign C[0]=Cin;

    // C1 = G0 + P0嵩0
    and #11 a1(temp[0],P[0],C[0]);
    or  #11 o1(C[1],G[0],temp[0]);

    // C2 = G1 + P1廉0 + P1感0嵩0
    and #11 a2(temp[1],P[1],G[0]);
    and #11 a3(temp[2],P[1],P[0]);
    and #11 a4(temp[3],temp[2],C[0]);
    or  #11 o2(temp[4],G[1],temp[1]);
    or  #11 o3(C[2],temp[4],temp[3]);

    // C3 = G2 + P2廉1 + P2感1廉0 + P2感1感0嵩0
    and #11 a5(temp[5],P[2],G[1]);
    and #11 a6(temp[6],P[2],P[1]);
    and #11 a7(temp[7],temp[6],G[0]);
    and #11 a8(temp[8],temp[6],P[0]);
    and #11 a9(temp[9],temp[8],C[0]);
    or  #11 o4(temp[10],G[2],temp[5]);
    or  #11 o5(temp[11],temp[10],temp[7]);
    or  #11 o6(C[3],temp[11],temp[9]);

    // Sum[i] = Pi ^ Ci
    xor #15 s0(Sum[0],P[0],C[0]);
    xor #15 s1(Sum[1],P[1],C[1]);
    xor #15 s2(Sum[2],P[2],C[2]);
    xor #15 s3(Sum[3],P[3],C[3]);

    // Cout = G3 + P3嵩3
    and #11 a10(temp[12],P[3],C[3]);
    or  #11 o7(Cout,G[3],temp[12]);
endmodule

////////////////////////////////////////////////////////////////////////////////////////////
//Flip-flops for synchronization
////////////////////////////////////////////////////////////////////////////////////////////
module dff4(
    input clk,
    input[3:0] D,
    output reg[3:0] Q
);
    always@(posedge clk)
        Q<=D;
endmodule

module dff1(
    input clk,
    input D,
    output reg Q
);
    always@(posedge clk)
        Q<=D;
endmodule
