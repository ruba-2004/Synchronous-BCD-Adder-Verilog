`timescale 1ns/1ps
	//////////////main/////////////
module bcd_adder_ndigit_with_ff#(parameter N=3)(
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
//This module add 2 BCD digit A and B with Cin. First it make normal sum with ripple adder.
//	If sum bigger than 9 or got carry, then need fix. Fix is plus 6.
//	Second adder do the fix. Final BCD_Sum is correct answer. Cout say if fix happen.
////////////////////////////////////////////////////////////////////////////////////////////
module bcd_adder (
    input [3:0] A, B,        //4-bit input digits A and B (BCD)
    input Cin,               //carry input from before
    output [3:0] BCD_Sum,    //final correct BCD result
    output Cout              //say if we fix the sum or not
);

    wire [3:0] binary_sum;       // this for raw result A+B+Cin
    wire carry_out;              //carry from that raw sum
    wire correction_needed;      //need fix? (yes if >9 or got carry)
    wire [3:0] correction = 4'd6;//if wrong, we fix by add 6
    wire [3:0] fix;              //this will be 6 or 0

    //if sum bigger than 9 or got carry, we need fix (add 6)
    assign correction_needed = (binary_sum > 4'd9) | carry_out;

    //if need fix, then use 6, else use 0
    assign fix = correction_needed ? correction : 4'd0;

    //first we add A + B + Cin, like normal adder
    ripple_carry_adder_4bit rca1 (
        .A(A), .B(B), .Cin(Cin),
        .Sum(binary_sum), .Cout(carry_out)
    );

    wire [3:0] corrected_sum;    // this hold fixed value
    wire dummy_cout;             //we don’t care about carry here

    //second adder: add 6 if needed, else just pass sum
    ripple_carry_adder_4bit rca2 (
        .A(binary_sum), .B(fix), .Cin(1'b0),
        .Sum(corrected_sum), .Cout(dummy_cout)
    );

    //give final answer after fix
    assign BCD_Sum = corrected_sum;

    // output 1 if we do fix, else 0
    assign Cout = correction_needed;
endmodule


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//This module add 4-bit numbers A and B with carry in. it use 4 full adders, one for each bit .first adder use Cin then next one use carry from before.
//Final output is 4-bit Sum and Cout for next adder. Work like chain,one by one.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
module ripple_carry_adder_4bit (
    input [3:0] A, B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire c1, c2, c3;

    full_adder FA0 (A[0],B[0],Cin, Sum[0],c1);
    full_adder FA1 (A[1],B[1],c1, Sum[1],c2);
    full_adder FA2 (A[2],B[2],c2,Sum[2],c3);
    full_adder FA3 (A[3], B[3],c3,Sum[3],Cout);
endmodule


//Full adder take three bits A, B, and Cin. It make Sum with XOR, 
//and Cout happen when two or more bits is 1. logic AB + (AXORB)Cin.
module full_adder (
    input A, B, Cin,
    output Sum, Cout
);
    wire AxorB, AandB, AxorBandCin;

    assign #15 AxorB = A ^ B;
    assign #15 Sum = AxorB ^ Cin;
    assign #11 AandB = A & B;
    assign #11 AxorBandCin = AxorB & Cin;
    assign #11 Cout = AandB | AxorBandCin;
endmodule


//This flipflop take 4bit input D. When clock go up (posedge clk) it save D into Q.Like memory for 4 bits.

module dff4 (
    input clk,
    input [3:0] D,
    output reg [3:0] Q
);
    always @(posedge clk)
        Q <= D;
endmodule
//This one same, but only for 1 bit. When clock tick, it save input D into Q. Keep value until next clock.

module dff1 (
    input clk,
    input D,
    output reg Q
);
    always @(posedge clk)
        Q <= D;
endmodule
