`timescale 1ns / 1ps
// 数码管驱动
module SEG_DRV(
	input wire clk,
	input wire [31:0] data,
	output wire [3:0] sout
    );
	 
	 wire [63:0] dispData;
	 Decoder U0(.hex(data),.digits(dispData));//译码
	 ShiftReg #(.WIDTH(64)) U1(.clk(clk),.pdata(dispData),.sout(sout)); //调用移位寄存器

endmodule
