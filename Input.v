`timescale 1ns / 1ps
//输入模块
module Input (
    input wire clk, ps2_clk, ps2_data,
    output wire [3:0] mode
);

    wire [7:0] kb_key;
    wire kb_state;
    reg left, right, jump, restart;
    assign mode = {left, right, jump, restart};

    PS2_DRV keyboard (.clk(clk),.rst(1'b1),.ps2_clk(ps2_clk),.ps2_data(ps2_data),
        .data(kb_key),.state(kb_state));//调用PS/2驱动

	// 根据键盘数据确定当前mode
    always @( posedge clk ) begin
        case(kb_key)
            8'h29: restart = kb_state;
            8'h75: jump = kb_state;
            8'h6b: left = kb_state;
            8'h74: right = kb_state;
        endcase
    end

endmodule
