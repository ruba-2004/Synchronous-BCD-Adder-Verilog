`timescale 1ns/1ps

module tb_bcd_adder_ndigit_with_ff;

parameter N=3;
localparam WIDTH=4*N;

reg clk;
reg[WIDTH-1:0] A,B;
reg Cin;
wire[WIDTH-1:0] Sum;
wire Cout;

integer fout,ferr;
integer test_num=0;

//connect DUT
bcd_adder_ndigit_with_ff#(N) uut(
.clk(clk),
.A(A),
.B(B),
.Cin(Cin),
.Sum(Sum),
.Cout(Cout)
);

//make clock forever toggle
initial clk=0;
always #800 clk=~clk; //1600ns total period

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

//convert BCD to real decimal for show
a_val=100*a_bcd[11:8]+10*a_bcd[7:4]+a_bcd[3:0];
b_val=100*b_bcd[11:8]+10*b_bcd[7:4]+b_bcd[3:0];
exp_val=expected_cout*1000+100*expected_sum[11:8]+10*expected_sum[7:4]+expected_sum[3:0];
act_val=actual_cout*1000+100*actual_sum[11:8]+10*actual_sum[7:4]+actual_sum[3:0];

$display("%dns\t %03d+%03d=%04d Cout:%b",$time,a_val,b_val,act_val,actual_cout);
$fdisplay(fout,"%dns\t %03d+%03d=%04d Cout:%b",$time,a_val,b_val,act_val,actual_cout);

//if wrong, show error
if(act_val!==exp_val)begin
$display("?ERROR at %dns",$time);
$fdisplay(ferr,"?ERROR at %dns: Expected=%d but Got=%d",$time,exp_val,act_val);
end
end
endtask

//run test cases
initial begin
fout=$fopen("simulation_output.txt","w");
ferr=$fopen("error_log.txt","w");

$display("Time\t A+B=Sum Cout");
$fdisplay(fout,"Time\t A+B=Sum Cout");

//===real tests===
A=12'h500;B=12'h600;Cin=0;#1600;#1600;
check_result(A,B,12'h100,1,Sum,Cout);

A=12'h999;B=12'h002;Cin=0;#1600;#1600;
check_result(A,B,12'h001,1,Sum,Cout);

A=12'h099;B=12'h099;Cin=0;#1600;#1600;
check_result(A,B,12'h198,0,Sum,Cout);

A=12'h095;B=12'h005;Cin=0;#1600;#1600;
check_result(A,B,12'h100,0,Sum,Cout);

A=12'h098;B=12'h003;Cin=0;#1600;#1600;
check_result(A,B,12'h101,0,Sum,Cout);

A=12'h099;B=12'h009;Cin=0;#1600;#1600;
check_result(A,B,12'h108,0,Sum,Cout);

A=12'h089;B=12'h011;Cin=0;#1600;#1600;
check_result(A,B,12'h100,0,Sum,Cout);

A=12'h499;B=12'h501;Cin=0;#1600;#1600;
check_result(A,B,12'h000,1,Sum,Cout);

A=12'h123;B=12'h877;Cin=0;#1600;#1600;
check_result(A,B,12'h000,1,Sum,Cout);

A=12'h999;B=12'h001;Cin=0;#1600;#1600;
check_result(A,B,12'h000,1,Sum,Cout);

A=12'h999;B=12'h000;Cin=0;#1600;#1600;
check_result(A,B,12'h999,0,Sum,Cout);

A=12'h000;B=12'h000;Cin=0;#1600;#1600;
check_result(A,B,12'h000,0,Sum,Cout);

A=12'h999;B=12'h999;Cin=0;#1600;#1600;
check_result(A,B,12'h998,1,Sum,Cout); //999+999=1998

//===wrong test on purpose
A=12'h050;B=12'h050;Cin=0;#1600;#1600;
check_result(A,B,12'h099,0,Sum,Cout); //wrong expected

$fclose(fout);
$fclose(ferr);
$finish;
end

endmodule
