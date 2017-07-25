`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:43:37 03/19/2017 
// Design Name: 
// Module Name:    hdmi_in_reader 
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
module hdmi_in_reader(
	input clk,
	input rst,
  
	input hdmi_in_clk,
	input [7:0] hdmi_in_R,
	input [7:0] hdmi_in_G,
	input [7:0] hdmi_in_B,
	input hdmi_in_active,
	input hdmi_in_hs,
	input hdmi_in_vs,
	
	input pulse_input,
	output pulse_output,
	
	input [23:0] time_count,
//	input waiting_for_next_frame,

	output fifo_full,
	output reg error_detected,
	output reg[7:0] frame_count,
	


  input rx,
  output tx,
  
  output in_precess
  );
//wire waiting_for_next_frame;

wire fifo_empty;
reg fifo_read_enable;
reg [7:0] red;
reg [7:0] green;
reg [7:0] blue;

reg [7:0] red_d0;
reg [7:0] green_d0;
reg [7:0] blue_d0;

reg [11:0] h_active_value;
reg [11:0] v_active_value;

reg [11:0] h_active_value_d0;
reg [11:0] v_active_value_d0;

wire[71:0] fifo_out;

wire [7:0] generated_r;
wire [7:0] generated_g;
wire [7:0] generated_b;

reg [7:0] generated_r_reg;
reg [7:0] generated_g_reg;
reg [7:0] generated_b_reg;

reg [23:0] frame_time;
reg [23:0] transmit_time_count;
reg [7:0] transmit_frame_count;
reg [23:0] frame_time_d0;
wire data_avaiable_4_verify;
reg data_avaiable_4_verify_d0;
reg data_avaiable_4_verify_d1;
reg first_frame = 1'b0;
reg in_precess = 1'b0;
reg [7:0]frame_count_should_be;
reg [7:0]vs_counter;

reg[3:0]sel;
reg[11:0]transmit_step_count;

parameter PULSE_DATA_IDLE = 2'd0;
parameter PULSE_DATA_FIFO= 2'd1;
parameter PULSE_DATA_TRANSMIT = 2'd2;
reg [1:0] pulse_data_state = PULSE_DATA_IDLE;
reg [56:0] pulse_tester_data_received;
wire [56:0] pulse_tester_data;
reg pulse_tester_rd_en;
wire pulse_tester_data_not_available;
reg pulse_data_transmitted;
reg [7:0]error_count;
wire [23:0] hdmi_delay;
reg [63:0]data_to_uart;
reg start_tx;
assign hdmi_delay = time_count - {red_d0, green_d0, blue_d0} - 23'h92;

always@(posedge clk or posedge rst)begin
	if(rst)begin
		first_frame <= 1'b0;
		data_avaiable_4_verify_d0 <= 1'b0;
		red_d0 <= 8'd0;
		green_d0 <= 8'd0;
		blue_d0 <= 8'd0;

		generated_r_reg <= 8'd0;
		generated_g_reg <= 8'd0;
		generated_b_reg <= 8'd0;
		h_active_value_d0 <= 12'd0;
		v_active_value_d0 <= 12'd0;

	end
	else begin
		first_frame <= 1'b1;
		data_avaiable_4_verify_d0 <= data_avaiable_4_verify;
		data_avaiable_4_verify_d1 <= data_avaiable_4_verify_d0;
		red_d0 <= red;
		green_d0 <= green;
		blue_d0 <= blue;
		
		generated_r_reg <= generated_r;
		generated_g_reg <= generated_g;
		generated_b_reg <= generated_b;
		h_active_value_d0 <= h_active_value;
		v_active_value_d0 <= v_active_value;
		frame_time_d0 <= frame_time;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		red[7:0] <= 8'd0;
		green[7:0] <= 8'd0;
		blue[7:0] <= 8'd0;
		h_active_value[11:0] <= 12'd0;
		v_active_value[11:0] <= 12'd0;
		frame_time[23:0] <= 24'd0;
	end
	else begin
		if(data_avaiable_4_verify)begin
			red[7:0] <= fifo_out[71:64];
			green[7:0] <= fifo_out[63:56];
			blue[7:0] <= fifo_out[55:48];
			h_active_value[11:0] <= fifo_out[47:36];
			v_active_value[11:0] <= fifo_out[35:24];
			frame_time[23:0] <= fifo_out[23:0];
		end
	end
end




uart_utility uart_utility_m1(
	.clk(clk),
	.rst(1'b0),
  
	.rx(rx),  
	.tx(tx),
  
	.data(data_to_uart),
	.start_tx(start_tx),

	.byte_from_uart(),
	.rx_data_available()
	);
always@(posedge clk)
begin
  if(data_avaiable_4_verify_d1 & in_precess)
    begin
		pulse_data_transmitted <= 1'b0;
		if(h_active_value_d0 == 12'd0 && v_active_value_d0 == 12'd0 )begin
			transmit_frame_count <= blue_d0;

			if(frame_count_should_be != blue_d0)begin
				start_tx <= 1'b1;
				frame_count_should_be <= blue_d0 + 8'd1;
				error_count <= error_count + 8'd1;
				data_to_uart <= {8'h11, frame_count_should_be, blue_d0, 40'd0};
			end
			else begin
				start_tx <= 1'b0;
				frame_count_should_be <= frame_count_should_be + 8'd1;
			end
		end
		else if(h_active_value_d0 == 12'd1 && v_active_value_d0 == 12'd0 )begin
			if(transmit_frame_count == 8'd0)begin
				start_tx <= 1'b1;
				error_count <= 8'd0;
				data_to_uart <= {8'h00, hdmi_delay, error_count, 24'd0};
			end
			else
				start_tx <= 1'b0;
		end
		else if(h_active_value_d0 != 12'd1920 && v_active_value_d0 != 12'd1080)begin
			if((generated_r_reg == red_d0) && (generated_g_reg == green_d0) && (generated_b_reg == blue_d0))begin
				start_tx <= 1'b0;
			end
			else begin
				error_count <= error_count + 8'd1;
				data_to_uart <= {8'h10, {4'd0, h_active_value_d0[11:8]}, h_active_value_d0[7:0], {4'd0,v_active_value_d0[11:8]}, v_active_value_d0[7:0],(generated_r_reg - red_d0),(generated_g_reg - green_d0),(generated_b_reg - blue_d0)};
				//data_to_uart <= {8'h10, {4'd0, h_active_value_d0[11:8]}, h_active_value_d0[7:0], {4'd0,v_active_value_d0[11:8]}, v_active_value_d0[7:0],24'd0};
				start_tx <= 1'b1;
			end
      end
      else begin
        start_tx <= 1'b0;
      end
    end
  else
    begin
    	if(!in_precess)begin
    		frame_count_should_be<= 1'b1;
    	end
		if(pulse_data_state == PULSE_DATA_TRANSMIT && pulse_data_transmitted == 1'b0)begin
			start_tx <= 1'b1;
			pulse_data_transmitted <= 1'b1;
			if(pulse_tester_data_received[56]==1'b0)
				data_to_uart <= {8'h01, pulse_tester_data_received[55:0]};
			else if(pulse_tester_data_received[55]==1'b0)
				data_to_uart <= {8'h12, pulse_tester_data_received[54:43],44'h0};
			else if(pulse_tester_data_received[55]==1'b1)
				data_to_uart <= {8'h13, 56'h0};
		end
		else begin
			start_tx <= 1'b0;
			pulse_data_transmitted <= 1'b0;
		end
    end
end

always@(posedge clk)
begin
  if(data_avaiable_4_verify_d1)
    begin
		if(h_active_value_d0 == 12'd0 && v_active_value_d0 == 12'd0)begin
			sel <= red_d0[7:4];
			transmit_step_count <= {red_d0[3:0],green_d0};
		end
		else begin
			sel <= sel;
			transmit_step_count <= transmit_step_count;
		end
    end
end
reg waiting_for_stable = 1'b0;
always@(posedge clk)
begin
  if(data_avaiable_4_verify_d1)
    begin
		if(h_active_value_d0 == 12'd0 && v_active_value_d0 == 12'd0 && blue_d0 == 8'hFF)
			waiting_for_stable <= 1'b1;
		else if(h_active_value_d0 == 12'd0 && v_active_value_d0 == 12'd0 && blue_d0 == 8'h00)
			if(waiting_for_stable == 1'b1)
				in_precess <= 1'b1;
		else
			in_precess <= in_precess;
    end
end



pulse_tester pulse_tester(
	.clk(clk),
	.rst(1'b0),
	.pulse_input(pulse_input),
	.pulse_output(pulse_output),
	.in_precess(in_precess),
	
	.pulse_tester_data(pulse_tester_data),
	.pulse_tester_rd_en(pulse_tester_rd_en),
	.pulse_tester_data_not_available(pulse_tester_data_not_available)
	);

always @(posedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		case (pulse_data_state)
			PULSE_DATA_IDLE: begin
				if (!pulse_tester_data_not_available) begin
					pulse_tester_rd_en <= 1'b1;
					pulse_data_state <= PULSE_DATA_FIFO;
				end
			end

			PULSE_DATA_FIFO: begin
				if (pulse_tester_rd_en == 1'b1)begin
					pulse_tester_rd_en <= 1'b0;
				end
				else begin
					pulse_tester_data_received <= pulse_tester_data;
					pulse_data_state <= PULSE_DATA_TRANSMIT;
				end
			end

			PULSE_DATA_TRANSMIT: begin
				if (pulse_data_transmitted) begin
					pulse_data_state <= PULSE_DATA_IDLE;
				end
			end
		endcase
	end
end
	
hdmi_in hdmi_in(
  .clk(clk),
  .hdmi_in_clk(hdmi_in_clk),
  .rst(1'b0),
  .hdmi_in_R(hdmi_in_R),
  .hdmi_in_G(hdmi_in_G),
  .hdmi_in_B(hdmi_in_B),
  .hdmi_in_active(hdmi_in_active),
  .hdmi_in_hs(hdmi_in_hs),
  .hdmi_in_vs(hdmi_in_vs),
  
  .time_count(time_count),
 // .waiting_for_next_frame(waiting_for_next_frame),

  .read_enable(1'b1),
  .data_from_hdmi(fifo_out),
  .fifo_full(fifo_full),
  .fifo_empty(fifo_empty),
  .fifo_valid(data_avaiable_4_verify)//,
//  
//  .tx(tx),
//  .rx(rx)
  );
  
image_gererator image_gererator_m0 (
  .h_active_value(h_active_value),
  .v_active_value(v_active_value),
  .sel(sel),
  .step_count(transmit_step_count),
  .red(generated_r),
  .green(generated_g),
  .blue(generated_b),
  
  .time_count(24'd0),
  .frame_count(8'd0)
  );
  
endmodule
