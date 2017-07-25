`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Zhengbang Liu
//
// Create Date:    18:44:05 03/18/2017
// Design Name:
// Module Name:    hdmi_driver
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module hdmi_driver(
	input clk,
	input rst,
	input [23:0] time_count,
	output hs,
	output vs,
	output de,
	output[7:0] rgb_r,
	output[7:0] rgb_g,
	output[7:0] rgb_b,
	
	output hs_reg,
	output vs_reg,
	output hs_reg_d0,
	output vs_reg_d0,
	output[11:0] h_cnt,
	output[11:0] v_cnt,
	output[11:0] active_x,
	output[11:0] active_y,
	output[7:0] rgb_r_reg,
	output[7:0] rgb_g_reg,
	output[7:0] rgb_b_reg,
	output h_active,
	output v_active,
	output video_active,
	output video_active_d0

);

//parameter H_ACTIVE = 16'd1280;
//parameter H_FP = 16'd110; 
//parameter H_SYNC = 16'd40; 
//parameter H_BP = 16'd220;
//parameter V_ACTIVE = 16'd720; 
//parameter V_FP 	= 16'd5;
//parameter V_SYNC  = 16'd5;
//parameter V_BP	= 16'd20;

parameter H_ACTIVE = 12'd1920;
parameter H_FP = 12'd88;
parameter H_SYNC = 12'd44;
parameter H_BP = 12'd148; 
parameter V_ACTIVE = 12'd1080;
parameter V_FP 	= 12'd4;
parameter V_SYNC  = 12'd5;
parameter V_BP	= 12'd36;

parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;

reg hs_reg = 1'b0;
reg vs_reg = 1'b0;
reg hs_reg_d0 = 1'b0;
reg vs_reg_d0 = 1'b0;
reg[11:0] h_cnt = 12'd0;
reg[11:0] v_cnt = 12'd0;
reg[11:0] active_x = 12'd0;
reg[11:0] active_y = 12'd0;
reg[7:0] rgb_r_reg = 8'd0;
reg[7:0] rgb_g_reg = 8'd0;
reg[7:0] rgb_b_reg = 8'd0;
reg h_active = 1'b0;
reg v_active = 1'b0;
wire[23:0] time_count;
wire video_active;
reg video_active_d0 = 1'b0;

wire [7:0] r;
wire [7:0] g;
wire [7:0] b;

reg [7:0] frame_count;
reg [7:0] sel_count;

assign hs = hs_reg_d0;
assign vs = vs_reg_d0;
assign video_active = h_active & v_active;
assign de = video_active_d0;
assign rgb_r = rgb_r_reg;
assign rgb_g = rgb_g_reg;
assign rgb_b = rgb_b_reg;
wire vs_detected = vs_reg && (~vs_reg_d0);


always@(posedge clk or posedge rst) begin
	if(rst) begin
		hs_reg_d0 <= 1'b0;
		vs_reg_d0 <= 1'b0;
		video_active_d0 <= 1'b0;
	end
	else begin
			hs_reg_d0 <= hs_reg;
			vs_reg_d0 <= vs_reg;
			video_active_d0 <= video_active;
		end
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		frame_count <= 8'd0;
	end
	else
		if((v_cnt == V_FP) && (h_cnt == H_FP - 12'd1)) begin
			frame_count <= frame_count + 8'd1;
		end
end

//##########################  h_cnt
always@(posedge clk or posedge rst) begin
	if(rst)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL - 12'd1)
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end

//########################  hs_reg
always@(posedge clk or posedge rst) begin
	if(rst)
		hs_reg <= 1'b0;
	else if(h_cnt == H_FP - 12'd1)
		hs_reg <= 1'b1;
	else if(h_cnt == H_FP + H_SYNC - 12'd1)
		hs_reg <= 1'b0;
	else
		hs_reg <= hs_reg;
end

//########################  h_active
always@(posedge clk or posedge rst) begin
	if(rst)
		h_active <= 1'b0;
	else if(h_cnt == H_FP + H_SYNC + H_BP - 12'd1)
		h_active <= 1'b1;
	else if(h_cnt == H_TOTAL - 12'd1)
		h_active <= 1'b0;
	else
		h_active <= h_active;
end

//########################  active_x
always@(posedge clk or posedge rst) begin
	if(rst)
		active_x <= 12'd0;
	else if(h_cnt >= H_FP + H_SYNC + H_BP - 12'd1)
		active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0] - 12'd1);
	else
		active_x <= active_x;
end




//######################## v_cnt
always@(posedge clk or posedge rst) begin
	if(rst)
		v_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL  - 12'd1)
		if(v_cnt == V_TOTAL - 12'd1)
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;
	else
		v_cnt <= v_cnt;
end


//########################  vs_reg
always@(posedge clk or posedge rst) begin
	if(rst)
		vs_reg <= 1'd0;
	else if((v_cnt == V_FP) && (h_cnt == H_FP - 12'd1))
		vs_reg <= 1'b1;
	else if((v_cnt == V_FP + V_SYNC) && (h_cnt == H_FP - 12'd1))
		vs_reg <= 1'b0;	
	else
		vs_reg <= vs_reg;
end

//########################  v_active
always@(posedge clk or posedge rst) begin
	if(rst)
		v_active <= 1'd0;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 12'd1) && (h_cnt == H_TOTAL  - 12'd1))
		v_active <= 1'b1;
	else if((v_cnt == V_TOTAL - 12'd1) && (h_cnt == H_TOTAL  - 12'd1))
		v_active <= 1'b0;	
	else
		v_active <= v_active;
end

//########################  active_y
always@(posedge clk or posedge rst) begin
	if(rst)
		active_y <= 12'd0;
	else if((v_cnt >= V_FP + V_SYNC + V_BP - 12'd1) && (h_cnt == H_TOTAL  - 12'd1))
		active_y <= v_cnt - (V_FP[11:0] + V_SYNC[11:0] + V_BP[11:0] - 12'd1);
	else
		active_y <= active_y;
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
		rgb_r_reg <= 8'h00;
		rgb_g_reg <= 8'h00;
		rgb_b_reg <= 8'h00;
	end
	else if(video_active) begin
		rgb_r_reg <= r;
		rgb_g_reg <= g;
		rgb_b_reg <= b;
	end
	else begin
		rgb_r_reg <= 8'h00;
		rgb_g_reg <= 8'h00;
		rgb_b_reg <= 8'h00;
	end
end

reg [11:0] step_count;
always@(posedge clk or posedge rst) begin
	if(rst) begin
		step_count <= 12'h0;
		sel_count <= 8'b0;
	end
	else if((v_cnt == V_FP) && (h_cnt == H_FP - 12'd1)) begin
		step_count <= step_count + 12'b1;
		sel_count <= sel_count + 8'b1;
	end
	else begin
		step_count <= step_count;
		sel_count <= sel_count;
	end
end
reg [3:0]sel;
always@(posedge clk or posedge rst) begin
	if(rst) begin
		sel <= 4'h0;
	end
	else if((sel_count == 4'b1111)&&(v_cnt == V_FP) && (h_cnt == H_FP - 12'd1)) begin
		sel <= sel + 4'b1;
	end
	else begin
		sel <= sel;
	end
end

image_gererator image_gererator_m1(
	.h_active_value(active_x),
	.v_active_value(active_y),
	.sel(sel),
	.step_count(step_count),
	.time_count(time_count),
	.frame_count(frame_count),
	.red(r),
	.green(g),
	.blue(b)
	);

endmodule 