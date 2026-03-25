			`timescale 1ns/1ps

module tb_bcd_adder_ndigit_with_lookahead;

parameter N=3;
localparam WIDTH=4*N;

reg clk;
reg[WIDTH-1:0] A,B;
reg Cin;
wire[WIDTH-1:0] Sum;
wire Cout;

integer fout,ferr;
integer test_num=0;

//connect to the CLA-based top module
bcd_adder_ndigit_with_lookahead#(N) uut(
.clk(clk),
.A(A),
.B(B),
.Cin(Cin),
.Sum(Sum),
.Cout(Cout)
);

//make clock forever toggle
initial clk=0;
always #50 clk=~clk; //1600ns total period

//start values before tests
initial begin
A=12'h000;B=12'h000;Cin=0;
#1000; //wait for setup
end

//task to check result and print
task check_result;
input[WIDTH-1:0] a_bcd,b_bcd,expected_sum;
input expected_cout;
input[WIDTH-1:0] actual_sum;
input actual_cout;

integer a_val,b_val,exp_val,act_val;
begin
test_num=test_num+1;

a_val=100*a_bcd[11:8]+10*a_bcd[7:4]+a_bcd[3:0];
b_val=100*b_bcd[11:8]+10*b_bcd[7:4]+b_bcd[3:0];
exp_val=expected_cout*1000+100*expected_sum[11:8]+10*expected_sum[7:4]+expected_sum[3:0];
act_val=actual_cout*1000+100*actual_sum[11:8]+10*actual_sum[7:4]+actual_sum[3:0];

$display("%dns\t %03d+%03d=%04d Cout:%b",$time,a_val,b_val,act_val,actual_cout);
$fdisplay(fout,"%dns\t %03d+%03d=%04d Cout:%b",$time,a_val,b_val,act_val,actual_cout);

if(act_val!==exp_val)begin
$display("?ERROR at %dns",$time);
$fdisplay(ferr,"?ERROR at %dns: Expected=%d but Got=%d",$time,exp_val,act_val);
end
end
endtask

initial begin
fout=$fopen("simulation_output_stage2.txt","w");
ferr=$fopen("error_log_stage2.txt","w");

$display("Time\t A+B=Sum Cout");
$fdisplay(fout,"Time\t A+B=Sum Cout");

A=12'h001;B=12'h002;Cin=0;#100;#100;#100;
check_result(A,B,12'h003,0,Sum,Cout);

A=12'h050;B=12'h050;Cin=0;#100;#100;#100;
check_result(A,B,12'h100,0,Sum,Cout);

A=12'h099;B=12'h001;Cin=0;#100;#100;#100;
check_result(A,B,12'h100,0,Sum,Cout);

A=12'h123;B=12'h321;Cin=0;#100;#100;#100;
check_result(A,B,12'h444,0,Sum,Cout);

A=12'h800;B=12'h150;Cin=0;#100;#100;#100;
check_result(A,B,12'h950,0,Sum,Cout);

A=12'h500;B=12'h500;Cin=0;#100;#100;#100;
check_result(A,B,12'h000,1,Sum,Cout);

A=12'h987;B=12'h012;Cin=0;#100;#100;#100;
check_result(A,B,12'h999,0,Sum,Cout);

A=12'h999;B=12'h001;Cin=0;#100;#100;#100;
check_result(A,B,12'h000,1,Sum,Cout);

A=12'h100;B=12'h900;Cin=0;#100;#100;#100;
check_result(A,B,12'h000,1,Sum,Cout);

A=12'h234;B=12'h876;Cin=0;#100;#100;#100;
check_result(A,B,12'h110,1,Sum,Cout);

A=12'h000;B=12'h000;Cin=0;#100;#100;#100;
check_result(A,B,12'h000,0,Sum,Cout);

A=12'h001;B=12'h999;Cin=0;#100;#100;#100;
check_result(A,B,12'h000,1,Sum,Cout);

A=12'h222;B=12'h333;Cin=0;#100;#100;#100;
check_result(A,B,12'h555,0,Sum,Cout);

A=12'h090;B=12'h090;Cin=0;#100;#100;#100;
check_result(A,B,12'h180,0,Sum,Cout);

A=12'h999;B=12'h999;Cin=0;#100;#100;#100;
check_result(A,B,12'h600,1,Sum,Cout);

$fclose(fout);
$fclose(ferr);
$finish;
end


endmodule
