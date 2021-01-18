`timescale 1ns / 1ps
// PS/2驱动
module PS2_DRV (
    input wire clk, rst, ps2_clk, ps2_data,
    output reg [7:0] data,
    output reg state
);

    localparam KB_BREAK = 1'b1;
    localparam KB_RELEASE = 1'b0;
    localparam KB_PRESS = 1'b1;
    reg [2:0] clk_sync;
    reg [3:0] cnt;   // 记录传入比特数    
	reg [7:0] temp;  // 临时变量
    reg f0;          // 用来检测断码0xF0

    // 采样，检测ps2_clk
    wire samp = clk_sync[2] & ~clk_sync[1];
    always @( posedge clk ) begin
        clk_sync <= {clk_sync[1:0], ps2_clk};
    end

    // 数传入bit，存入buffer
    always @( posedge clk ) begin
        if(!rst) begin
            cnt <= 4'h0;
            temp  <= 8'h00;
        end else if (samp) begin
            if(cnt == 4'hA) cnt <= 4'h0; // 0-10循环计数
            else cnt <= cnt + 4'h1;
            if(cnt >= 4'h1 && cnt <= 4'h8)
                temp[cnt - 1] <= ps2_data;  // 暂存有效数据位
        end
    end

    // 检测按下/释放，传输数据
    always @( posedge clk ) begin
        if(!rst) begin
            f0 <= ~KB_BREAK;
            state <= KB_RELEASE;
        end
        else if (cnt == 4'hA && samp) begin
            if (temp == 8'hF0) begin
                f0 <= KB_BREAK;		// 记录断码状态
            end else begin
                state <= (f0 == KB_BREAK) ? KB_RELEASE : KB_PRESS; // 记录按下/释放状态
                f0    <= (f0 == KB_BREAK) ? ~KB_BREAK : f0; // 重置断码状态
                data  <= temp; // 传出键盘数据
            end
        end
    end

endmodule
