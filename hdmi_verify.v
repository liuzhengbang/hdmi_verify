`timescale 1ns / 1ps


module hdmi_verify (
  input clk_50m,
  input clk_27m,

  output reg[3:0]led,

  //hdmi output
  output hdmi_out_clk,
  output hdmi_out_hs,
  output hdmi_out_vs,
  output hdmi_out_de,
  output[7:0] hdmi_out_rgb_b,
  output[7:0] hdmi_out_rgb_g,
  output[7:0] hdmi_out_rgb_r,


  input hdmi_in_clk,
  input [7:0] hdmi_in_R,
  input [7:0] hdmi_in_G,
  input [7:0] hdmi_in_B,
  input hdmi_in_active,
  input hdmi_in_hs,
  input hdmi_in_vs,
  
  input pulse_input,
  output pulse_ouput,
	
  output tx,
  input rx
  );


wire video_clk;
wire hdmi_hs;
wire hdmi_vs;
wire hdmi_de;


wire[7:0] hdmi_r;
wire[7:0] hdmi_g;
wire[7:0] hdmi_b;

reg [20:0] counter;
wire fifo_full;
wire error_detected;
wire [7:0]frame_c;
reg err_flag;
reg [23:0] time_count;

reg is_hdmi_in_available;
reg [15:0]hdmi_in_available_counter;
reg [7:0]stable_counter;
wire stable_frame = ~is_hdmi_in_available;
wire in_precess;

always@(posedge hdmi_in_clk)
begin
	if(hdmi_in_vs == 1'b1)begin
		stable_counter <= stable_counter + 8'b1;
	end
	else if (hdmi_in_available_counter == 16'hFFFF)begin
		hdmi_in_available_counter <= 16'hFFFF;
		is_hdmi_in_available <= 1'b0;
		stable_counter <= 8'd0;
	end
	else
		hdmi_in_available_counter <= hdmi_in_available_counter + 12'b1;
	if(stable_counter == 8'hff)
		is_hdmi_in_available <= 1'b1;
	else
		is_hdmi_in_available <= 1'b0;
end

//always@(posedge hdmi_in_clk)
//begin
//	if(hdmi_in_hs == 1'b1)begin
//		hdmi_in_available_counter <= 12'b0;
//		if(hdmi_in_vs == 1'b1 && stable_counter != 8'hFF)begin
//			stable_counter <= stable_counter + 8'b1;
//		end
//	end
//	else if (hdmi_in_available_counter == 16'hFFFF)begin
//		hdmi_in_available_counter <= 16'hFFFF;
//		is_hdmi_in_available <= 1'b0;
//		stable_counter <= 8'd0;
//	end
//	else
//		hdmi_in_available_counter <= hdmi_in_available_counter + 12'b1;
//	if(stable_counter == 8'hff)
//		stable_frame <= 1'b1;
//	else
//		stable_frame <= 1'b0;
//end



always@(posedge video_clk)
begin
  if(counter == 21'd100)
    err_flag <=1'b0;
  else if (error_detected)
    err_flag <= 1'b1;
  else
    err_flag <= err_flag;
end

always @(posedge video_clk) begin
	time_count <= time_count + 24'd1;
end

always@(posedge video_clk)
begin
  if (in_precess == 1'b1)
    led[1:0] <= 2'b11;
  else 
    led[1:0] <= 3'b00;
	if (pulse_input)
		led[3] <= 1'b0;
	else
		led[3] <=1'b1;
		
	if (pulse_ouput)
		led[2] <= 1'b0;
	else
		led[2] <=1'b1;
end


pll_controller pll_video_m0(
  .CLK_IN1(clk_27m),
  .CLK_OUT1(video_clk)
  );

clock_out clock_out_m0(
  .clk_in(video_clk),
  .clk_out(hdmi_out_clk)
  );

hdmi_driver hdmi_driver(
  .clk(video_clk),
  .rst(1'b0),
  .time_count(time_count),
  .hs(hdmi_out_hs),
  .vs(hdmi_out_vs),
  .de(hdmi_out_de),
  .rgb_r(hdmi_out_rgb_r),
  .rgb_g(hdmi_out_rgb_g),
  .rgb_b(hdmi_out_rgb_b)
  );

hdmi_in_reader hdmi_in_reader(
  .clk(video_clk),
  .rst(1'b0),
  .hdmi_in_clk(hdmi_in_clk),
  .hdmi_in_R(hdmi_in_R),
  .hdmi_in_G(hdmi_in_G),
  .hdmi_in_B(hdmi_in_B),
  .hdmi_in_active(hdmi_in_active),
  .hdmi_in_hs(hdmi_in_hs),
  .hdmi_in_vs(hdmi_in_vs),
  .pulse_input(pulse_input),
  .pulse_output(pulse_ouput),
  .time_count(time_count),
//  .waiting_for_next_frame(waiting_for_next_frame),

  .fifo_full(fifo_full),
  .error_detected(error_detected),
  .frame_count(frame_c),
  .rx(rx),
  .tx(tx),
  .in_precess(in_precess)
  );





endmodule
