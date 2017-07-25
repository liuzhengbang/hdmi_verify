`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    18:44:05 03/18/2017
// Design Name:
// Module Name:    hdmi_in
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
module hdmi_in(
	input clk,
	input hdmi_in_clk,
	input rst,
	
	input [7:0] hdmi_in_R,
	input [7:0] hdmi_in_G,
	input [7:0] hdmi_in_B,
	input hdmi_in_active,
	input hdmi_in_hs,
	input hdmi_in_vs,
	input [23:0] time_count,
	
//	input waiting_for_next_frame,
	
	input read_enable,
	output [71:0] data_from_hdmi,
	output fifo_full,
	output fifo_empty,
	output fifo_valid//,
//	
//	input rx,
//	output tx
  );

parameter H_TOTAL = 12'd1920;
parameter V_TOTAL = 12'd1080;

reg hdmi_in_hs_d0;
reg hdmi_in_vs_d0;
reg hdmi_in_hs_d1;
reg hdmi_in_vs_d1;
reg [7:0] hdmi_in_R_d0;
reg [7:0] hdmi_in_G_d0;
reg [7:0] hdmi_in_B_d0;
reg hdmi_in_active_d0;
reg [7:0] hdmi_in_R_d1;
reg [7:0] hdmi_in_G_d1;
reg [7:0] hdmi_in_B_d1;
reg hdmi_in_active_d1;

wire hs_detected = hdmi_in_hs && (~hdmi_in_hs_d0);
wire vs_detected = hdmi_in_vs && (~hdmi_in_vs_d0);
wire waiting_for_next_frame;

//reg is_stable_frame;
reg [11:0]h_active_value;
reg [11:0]v_active_value;
reg [11:0]frame_count;
wire [71:0]fifo_out;

wire [71:0]fifo_din;

assign data_from_hdmi = fifo_out;
always@(posedge hdmi_in_clk or posedge rst) begin
  if (rst) begin
    hdmi_in_hs_d0 <= 1'b0;
    hdmi_in_vs_d0 <= 1'b0;

  end
  else begin
		hdmi_in_hs_d0 <= hdmi_in_hs;
		hdmi_in_vs_d0 <= hdmi_in_vs;
		hdmi_in_R_d0 <= hdmi_in_R;
		hdmi_in_G_d0 <= hdmi_in_G;
		hdmi_in_B_d0 <= hdmi_in_B;
		hdmi_in_active_d0 <= hdmi_in_active;
		
		hdmi_in_hs_d1 <= hdmi_in_hs_d0;
		hdmi_in_vs_d1 <= hdmi_in_vs_d0;
		hdmi_in_R_d1 <= hdmi_in_R_d0;
		hdmi_in_G_d1 <= hdmi_in_G_d0;
		hdmi_in_B_d1 <= hdmi_in_B_d0;
		hdmi_in_active_d1 <= hdmi_in_active_d0;
  end
end

always@(posedge hdmi_in_clk or posedge rst) begin
  if (rst) begin
    h_active_value <= 12'd0;
  end
  else begin
    if(hdmi_in_hs_d1)
        h_active_value <= 12'd0;
      else if(hdmi_in_active_d1)
        h_active_value <= h_active_value + 12'd1;
      else
        h_active_value <= 12'd0;
  end
end


always@(posedge hdmi_in_clk or posedge rst)
begin
  if (rst) begin
    v_active_value <= 12'd0;
  end
  else begin
    if(hdmi_in_vs_d1)
      v_active_value <= 12'd0;
    else if(h_active_value == H_TOTAL - 12'b1)
      v_active_value <= v_active_value + 12'd1;
    else
      v_active_value <= v_active_value;
    end
end


always@(posedge hdmi_in_clk or posedge rst) begin
  if (rst) begin
    frame_count <= 12'b0;
  end
  else begin
    if(vs_detected)
      frame_count <= frame_count + 12'd1;
    else
      frame_count <= frame_count;
  end
end

assign fifo_din = {
	hdmi_in_R_d1[7:0],
	hdmi_in_G_d1[7:0],
	hdmi_in_B_d1[7:0],
	h_active_value[11:0],
	v_active_value[11:0],
	time_count[23:0]
	};
reg [71:0] hdmi_in_data;
reg hdmi_in_data_available;

hdmi_in_fifo hdmi_in_fifo(
	.rst(1'b0),
	.wr_clk(hdmi_in_clk),
	.rd_clk(clk),
	.din(hdmi_in_data),
	.wr_en(hdmi_in_data_available),
	.rd_en(read_enable),
	.dout(fifo_out),
	.full(fifo_full),
	.empty(fifo_empty),
	.valid(fifo_valid)
	);
  
always@(posedge hdmi_in_clk)
begin
  if(hdmi_in_active_d1)
    begin
      hdmi_in_data <= fifo_din;
      hdmi_in_data_available <= 1'b1;
    end
  else
    begin
        hdmi_in_data_available <= 1'b0;
    end
end


endmodule
