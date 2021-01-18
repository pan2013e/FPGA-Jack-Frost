`timescale 1ns / 1ps

module ShiftReg(clk, pdata, sout);
	parameter WIDTH = 64;
	parameter DELAY = 12;
	input clk;
	input [WIDTH - 1:0] pdata;
	output [3:0] sout;
	assign sout = {sck, sdat, oe, clrn};
	
	wire sck, sdat, clrn;
	reg oe;
	
	reg [WIDTH:0] shift; // 模拟移位寄存器
	reg [DELAY-1:0] counter = -1; //利用寄存器延时
	wire sckEn;
	
	assign sckEn = |shift[WIDTH - 1:0]; // clk使能
	assign sck = ~clk & sckEn; // 数码管时钟
	assign sdat = shift[WIDTH]; // 移位寄存器移出的数据
	assign clrn = 1'b1; 
	
	always @ (posedge clk)
	begin
		if(sckEn)
			shift <= {shift[WIDTH - 1:0], 1'b0};
		else
		begin
			if(&counter)
			begin
				shift <= {pdata, 1'b1}; // 左移
				oe <= 1'b0; // 通过延迟，实现数据未就绪、移位时不让数码管刷新数据
			end
			else
				oe <= 1'b1;  // 数码管刷新数据
			counter <= counter + 1'b1;
		end
	end
endmodule
		else
