`timescale 1ns / 1ps
// 显示模块
module Display (
    input wire vga_clk, seg_clk,
    input wire [31:0] num,
    input wire [11:0] vga_data, // 12位RGB数据
    output wire [3:0] sout,
    output wire [8:0] row_addr, // pixel ram row addr, 480 (512) lines
    output wire [9:0] col_addr, // pixel ram col addr, 640 (1024) pixels
    output wire [3:0] r, g, b,
    output wire hs, vs // horizontal & vertical sync
);
    
	wire [7:0] bcd;
	 
    VGA_DRV screen (.vga_clk(vga_clk),.clrn(1'b1),.d_in(vga_data),.row_addr(row_addr),
        .col_addr(col_addr),.r(r),.g(g),.b(b),.hs(hs),.vs(vs));//调用VGA驱动
	 HexToBCD h2b(num[31:24],bcd); // 将十六进制数转bcd码输出
	 SEG_DRV segDevice (.clk(seg_clk),.data({bcd,num[23:0]}),.sout(sout));//调用七段数码管模块

endmodule
