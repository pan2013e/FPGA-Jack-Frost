`timescale 1ns / 1ps
// 译码器
module Decoder(
	input wire [31:0] hex,
	output wire [63:0] digits
    );
	
	// 调用单个数码管段码的译码器，点亮左侧两个数码管
	InnerDecoder
		U6(.hex(hex[27:24]),.segment(digits[54:48])),
		U7(.hex(hex[31:28]),.segment(digits[62:56]));

	// 将其他六个数码管消隐，同时将小数点消隐
	assign digits[6:0] = 7'b1111111;
	assign {digits[63],digits[55],digits[47],digits[39],
	digits[31],digits[23],digits[15],digits[7]}=8'hFF;
	assign {digits[46:40],digits[38:32],digits[30:24],
	digits[22:16],digits[14:8]}=35'b11111111_11111111_11111111_11111111_111;

endmodule
