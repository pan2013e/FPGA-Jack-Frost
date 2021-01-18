`timescale 1ns / 1ps

module HexToBCD(
    input wire [7:0] hex,
    output wire [7:0] bcd
    );

    assign bcd[7:4]=(hex/10==10)?0:hex/10; // 十位
    assign bcd[3:0]=hex%10; // 个位
    
endmodule
