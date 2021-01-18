`timescale 1ns / 1ps
// 时钟分频器
module clkdiv(
	input wire clk, rst, 
	output reg [31:0] clkdiv
    );

	always @ (posedge clk or posedge rst) begin
		if (rst) clkdiv <= 0;
		else clkdiv <= clkdiv + 1'b1;
	end
endmodule
