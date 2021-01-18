`timescale 1ns / 1ps

module GameCtrl(
	input clk,
	input ps2_clk, vga_clk,key_clk,
	input [8:0]row,
	input [9:0]col,
	input ps2_data,
	output reg [11:0]color,
	output wire [6:0] score,
	output wire [1:0] life
    );
	//格子28x32 人60x45注意脚   23x15个格子  小怪45x45
	wire [18:0] win_addr,lose_addr, bg_addr, initial_addr,person_addr,froze_addr,monster_addr;
	assign win_addr=row*640+col; //将当前像素点的位置换算到640×480图像位置
	assign lose_addr=row*640+col;
	assign bg_addr=row*640+col;
	assign initial_addr = row*640+col;
	
	reg [10:0] X_Person;//人左
	reg [9:0] Y_Person;//人上
	reg [344:0] block;//方块位置
	reg [10:0] X_Monster;//小怪左
	reg [9:0] Y_Monster;//小怪上
	reg [344:0] froze_block;//要冻住方块=1
	reg [344:0] dead_block;//无法冻住的方块
	
	assign person_appear = row-Y_Person>=0 && row-Y_Person<=45 && col-X_Person>=0 && col-X_Person<=60;//判断人是否出现
	assign person_addr = (row-Y_Person)*60+(col-X_Person);//换算到人的位置，下同
	assign froze_appear = froze_block[row/32*23+col/28];
	assign froze_addr = row%32*32+col%28;
	assign monster_addr = (row-Y_Monster)*45+(col-X_Monster);
	assign monster_appear = row-Y_Monster>=0 && row-Y_Monster<=45 && col-X_Monster>=0 && col-X_Monster<=45;
	
	wire win_out1b,lose_out1b,initial_out1b;
	wire [11:0] win_out,lose_out,bg_out,initial_out,left_person_out,right_person_out,froze_out;//读出的颜色
	wire [11:0] left_monster_out,right_monster_out,left_monster_froze_out,right_monster_froze_out;
	ROM_Win win0(.clka(vga_clk),.addra(win_addr),.douta(win_out1b));//从各个ROM中读出颜色赋给_out,下同  
	ROM_Lose lose0(.clka(vga_clk),.addra(lose_addr),.douta(lose_out1b));
	ROM_Background bg0(.clka(vga_clk),.addra(bg_addr),.douta(bg_out)); 
	ROM_Initial initial0(.clka(vga_clk),.addra(initial_addr),.douta(initial_out1b)); 
	ROM_Left_Person p0(.clka(vga_clk),.addra(person_addr),.douta(left_person_out)); 
	ROM_Right_Person p1(.clka(vga_clk),.addra(person_addr),.douta(right_person_out)); 
	ROM_Froze f0(.clka(vga_clk),.addra(froze_addr),.douta(froze_out));
	ROM_Left_Monster mons0(.clka(vga_clk),.addra(monster_addr),.douta(left_monster_out));
	ROM_Right_Monster mons1(.clka(vga_clk),.addra(monster_addr),.douta(right_monster_out));
	ROM_Left_Monster_Froze mons2(.clka(vga_clk),.addra(monster_addr),.douta(left_monster_froze_out));
	ROM_Right_Monster_Froze mons3(.clka(vga_clk),.addra(monster_addr),.douta(right_monster_froze_out));
	
	assign win_out = {12{win_out1b}};//黑白颜色要扩展成12b,下同
	assign lose_out = {12{lose_out1b}};
	assign initial_out = {12{initial_out1b}};
	reg [1:0] state;//00-initial 01-game 10-win 11-lose
	wire [3:0] mode;//left, right, jump, start
	reg [3:0] cur_mode;//描述人物当前状态,left,right,jump,down
	reg [2:0] monster_mode;//2-left 1-right 0-froze描述小怪的状态
	assign score = regscore;//冰冻格子x2即为得分
	assign life = reglife;
	reg [6:0] regscore;
	reg [1:0] reglife;
	reg [7:0]high; 
	Input input0(.clk(clk),.ps2_clk(ps2_clk),.ps2_data(ps2_data),.mode(mode));//获取ps2中键盘的读数
	
	initial begin//初始化地图，记录格子位置mode[0]
		state <= 2'b00;
		X_Person <= 300;
		Y_Person <= 405;
		cnt <= 0;
		cnt1 <= 0;
		cur_mode <= 4'b1000;
		reglife <= 3;
		regscore <= 0;
		high <= 0;
		block[116] <= 1'b1;
		block[120:119] <= 2'b11;
		block[126:124] <= 3'b111;
		block[131] <= 1'b1;
		block[187:185] <= 3'b111;
		block[195] <= 1'b1;
		block[205:200] <= 6'b111111;
		block[255:254] <= 2'b11;
		block[269:260] <= {10{1'b1}};
		block[343:323] <= {21{1'b1}};
		dead_block[21:0] <= {22{1'b1}};
		dead_block[23:22] <= 2'b11;
		dead_block[46:45] <= 2'b11;
		dead_block[69:68] <= 2'b11;
		dead_block[92:91] <= 2'b11;
		dead_block[115:114] <= 2'b11;
		dead_block[118:117] <= 2'b11;
		dead_block[130:127] <= 4'b1111;
		dead_block[138:137] <= 2'b11;
		dead_block[161:160] <= 2'b11;
		dead_block[184:183] <= 2'b11;
		dead_block[199:196] <= 4'b1111;
		dead_block[207:206] <= 2'b11;
		dead_block[230:229] <= 2'b11;
		dead_block[253:252] <= 2'b11;
		dead_block[276:275] <= 2'b11;
		dead_block[299:298] <= 2'b11;
		dead_block[322:321] <= 2'b11;
		dead_block[344] <= 1'b1;
	end
	
	always@(posedge clk)begin//根据状态和上述物体出现情况赋color
		if(mode[0]) begin 
		state<= 2'b01;
		monster_mode[0] = 0;
		end else begin
			case (state)
				2'b00:begin//00-initial
					color <= initial_out;
				end
				2'b01:begin//01-game
					if(~monster_appear)begin//小怪不出现
						if(person_appear && ~froze_appear)begin//画人和背景
							if(cur_mode[3]) color <= (left_person_out==12'b0)?bg_out:left_person_out;//人物图像为黑色使用下一层颜色
							if(cur_mode[2]) color <= (right_person_out==12'b0)?bg_out:right_person_out;
						end 
						else if(person_appear && froze_appear)begin//人和冰块
							if(cur_mode[3]) color <= (left_person_out==12'b0)?froze_out:left_person_out;
							if(cur_mode[2]) color <= (right_person_out==12'b0)?froze_out:right_person_out;
						end 
						else if(~person_appear && froze_appear)begin//冰块
							color <= froze_out;
						end else
							color <= bg_out;
					end 
					else begin//小怪出现的地方不用考虑冰块和背景
						if(person_appear)begin
							if(cur_mode[3])begin//人左
								if(monster_mode[0])begin//怪冻
									if(monster_mode[2]) color <= (left_person_out==12'b0)? left_monster_froze_out:left_person_out;
									else color <= (left_person_out==12'b0)? right_monster_froze_out:left_person_out;
								end else begin
									if(monster_mode[2]) color <= (left_person_out==12'b0)? left_monster_out:left_person_out;
									else color <= (left_person_out==12'b0)? right_monster_out:left_person_out;
								end
							end else begin//人右
								if(monster_mode[0])begin//怪冻
									if(monster_mode[2]) color <= (right_person_out==12'b0)? left_monster_froze_out:right_person_out;
									else color <= (right_person_out==12'b0)? right_monster_froze_out:right_person_out;
								end else begin
									if(monster_mode[2]) color <= (right_person_out==12'b0)? left_monster_out:right_person_out;
									else color <= (right_person_out==12'b0)? right_monster_out:right_person_out;
								end
							end
						end
						else begin
							if(monster_mode[0]) color <= (monster_mode[2])? left_monster_froze_out:right_monster_froze_out;
							else color <= (monster_mode[2])? left_monster_out:right_monster_out;
						end
					end
				end
				2'b10:begin//10-win
					color <= win_out;
				end
				2'b11:begin//11-lose
					color <= lose_out;
				end
			endcase
			if(person_appear && monster_appear)begin//判断碰撞
				if((X_Person+57<=X_Monster && X_Person+63>=X_Monster && ~monster_mode[0])||(X_Monster+42<=X_Person && X_Person+48>=X_Person && ~monster_mode[0]) )//冰冻小怪//
					state <= 2'b11;//如果平行碰撞进入lose
				else 
					monster_mode[0] = 1;//否则冰冻小怪
			end
			if(regscore==100) state <= 2'b10;//进入win
		end
	end
	
	wire [9:0]i;//判断人物下面的格子
	wire [9:0]j;//判断人物上面的格子
	assign j = (cur_mode[3])? (X_Person+34)/28+(Y_Person-1)/32*23:(X_Person+24)/28+(Y_Person-1)/32*23;//简单的计算,下同
	assign i = (cur_mode[3])? (X_Person+34)/28+(Y_Person+45)/32*23:(X_Person+24)/28+(Y_Person+45)/32*23;
	reg [2:0] cnt;//计时器，下同
	reg [2:0] cnt1;
	
	always@ (posedge key_clk)begin//对键盘数据处理
		if(mode[0])begin//重置到game界面并重置游戏状况
			X_Person <= 300;
			Y_Person <= 405;
			X_Monster <= 500;
			Y_Monster <= 402;
			monster_mode[2] = 1;
			monster_mode[1] = 0;
			cnt <= 0;
			cnt1 <= 0;
			reglife <= 3;
			regscore <= 0;
			high <= 0;
			froze_block[344:0] <= 0;
		end else begin
		
			if(block[i] && ~froze_block[i])begin//冰冻格子
				froze_block[i] <= 1;
				regscore <= regscore+2;
			end
		
			if(cnt1==2)begin
				cnt1<=0;
				if(~block[i] && ~dead_block[i] && ~cur_mode[1])cur_mode[0]=1;//下面没有格子进入下降状态
				if(cur_mode[1])begin 
					Y_Person <= Y_Person-1;//jump
					if(high==110 || dead_block[j])begin//跳到一定高度或者撞到不可跳跃的格子
						cur_mode[1] = 0;
						high <= 0;
						if(~block[i] && ~dead_block[i])cur_mode[0]=1;//下面没有格子进入下降状态
					end else
						high <= high+1;
				end
				if(cur_mode[0])begin Y_Person <= Y_Person+1;//下降状态
					if(block[i] || dead_block[i])cur_mode[0]=0;//判断是否有格子
				end
			end else cnt1 <= cnt1+1;
			
			if(cnt==3 && state==2'b01) begin//计时器
				cnt<=0;
				if (mode[3])begin
					if(cur_mode[3])begin
						if(X_Person>12) X_Person <=  X_Person-1;//往左
					end else begin
					cur_mode[3]=1;cur_mode[2]=0;
					X_Person <= X_Person -10;//修正左右互换人物脚的位置,下同
					end
				end else begin
				if(mode[2])begin
					if(cur_mode[2])begin
						if(X_Person<568) X_Person <=  X_Person+1;//往右
					end else begin
					cur_mode[3]=0;cur_mode[2]=1;
					X_Person <= X_Person + 10;
					end
				end 
				end
				if(mode[1]&&~cur_mode[0])begin
					cur_mode[1]=1;
				end
				if(cnt1==0 && state==2'b01)begin//比人慢一倍
				//小怪从左到右到一定位置然后从右到左并循环
					if(monster_mode[2] && X_Monster==26)begin
						monster_mode[2] = 0; monster_mode[1] = 1;
					end
					if(monster_mode[1] && X_Monster==572)begin
						monster_mode[2] = 1; monster_mode[1] = 0;
					end
					if(!monster_mode[0])begin
						if(monster_mode[2]) X_Monster <= X_Monster-1;
						else X_Monster <= X_Monster+1;
					end
				end
			end else cnt <= cnt + 1;
		end
	end
endmodule
