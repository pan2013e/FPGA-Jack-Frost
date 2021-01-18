`timescale 1ns / 1ps

module InnerDecoder(
	input wire [3:0] hex,
	output wire [6:0] segment
    );
	
	wire p;
	// 调用之前实验的MC14495模块进行译码
	MyMC14495 m1(.D0(hex[0]),.D1(hex[1]),.D2(hex[2]),.D3(hex[3]),.point(1'b0),.LE(1'b0),.a(segment[0]),.b(segment[1]),.c(segment[2]),
		.d(segment[3]),.e(segment[4]),.f(segment[5]),.g(segment[6]));
endmodule
