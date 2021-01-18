`timescale 1ns / 1ps

module Top(
	input wire clk, ps2_clk, ps2_data,
	output wire [3:0] r, g, b,
   output wire hs, vs, SEGCLK, SEGCLR, SEGDT, SEGEN
    );
	 
	wire [8:0] row_addr; //行坐标
	wire [9:0] col_addr; // 列坐标
	wire [11:0] vga_data; // 颜色数据
	wire [31:0] clkdiv;
	wire [6:0] score; //分值
	wire [1:0] life;
	wire [31:0] num;
	assign num={1'b0,score,22'b0,life};
	
	clkdiv div0(clk,1'b0,clkdiv);
	Display d0(clkdiv[1],clkdiv[3],num,vga_data,{SEGCLK,SEGDT,SEGEN,SEGCLR},row_addr,col_addr,r,g,b,hs,vs);
	GameCtrl g0(clk,ps2_clk,clkdiv[1],clkdiv[15],row_addr,col_addr,ps2_data,vga_data,score,life);

endmodule
