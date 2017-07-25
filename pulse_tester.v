`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:48:59 04/09/2017 
// Design Name: 
// Module Name:    pulse_tester 
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
module pulse_tester(
	input clk,
	input rst,
	input pulse_input,
	output reg pulse_output,
	input in_precess,
	
	output [56:0]pulse_tester_data,
	input pulse_tester_rd_en,
	output pulse_tester_data_not_available
	);

reg load;
reg [11:0]seed;
wire [11:0]rand_num;


parameter PULSE_OUT_IDLE = 3'd0;
parameter PULSE_OUT_WAITING = 3'd1;
parameter PULSE_OUT_IN_PROCESS = 3'd2;
parameter PULSE_OUT_ENDING = 3'd3;
reg [2:0] pulse_out_state = PULSE_OUT_IDLE;

parameter PULSE_IN_IDLE = 3'd0;
parameter PULSE_IN_WAITING = 3'd1;
parameter PULSE_IN_IN_PROCESS = 3'd2;
parameter PULSE_IN_ENDING = 3'd3;
parameter PULSE_IN_ERROR = 3'd4;
reg [2:0] pulse_in_state = PULSE_IN_IDLE;

reg start_pulse_in;
reg [29:0] pulse_width;
reg [29:0] pulse_countdown;
reg [31:0] pulse_in_countdown;
reg [29:0] full_pulse_variance;
wire [29:0] full_random_num;
reg [31:0]delay_counter;
reg [31:0]pulse_delay;
reg pulse_input_d0,pulse_input_d1, pulse_input_d2, pulse_input_d3, pulse_input_d4, pulse_input_d5, pulse_input_d6, pulse_input_d7, pulse_input_d8, pulse_input_d9;
reg pulse_input_d10,pulse_input_d11, pulse_input_d12, pulse_input_d13, pulse_input_d14, pulse_input_d15, pulse_input_d16, pulse_input_d17, pulse_input_d18, pulse_input_d19;
wire pulse_tester_rd_en;
wire pulse_tester_data_not_available;

reg fifo_wr_en;
reg [56:0]fifo_din;

assign full_random_num = {rand_num[7:0], 2'b11, 20'hFFFFF};
random_generator random_generator(
	.rst(rst), 
	.clk(clk), 
	.load(load), 
	.seed(seed),     
	.rand_num(rand_num) 
);

always@(posedge clk or posedge rst) begin
	if (rst) begin
		start_pulse_in <= 1'b0;
	end
	else begin
		pulse_countdown <= pulse_countdown - 30'd1;
		delay_counter <= delay_counter + 32'b1;
		case (pulse_out_state)
			PULSE_OUT_IDLE: begin
				pulse_output <= 1'b0;
				if(in_precess)begin
					pulse_countdown <= full_random_num;
					pulse_out_state <= PULSE_OUT_WAITING;
				end
				start_pulse_in <= 1'b0;
			end

			PULSE_OUT_WAITING: begin
				if (!pulse_countdown)begin
					pulse_countdown <= full_random_num;
					pulse_width <= full_random_num;
					start_pulse_in <= 1'b1;
					delay_counter <= 32'd0;
					pulse_out_state <= PULSE_OUT_IN_PROCESS;
				end				
			end

			PULSE_OUT_IN_PROCESS: begin
				start_pulse_in <= 1'b0;
				pulse_output <= 1'b1;
				if (!pulse_countdown)begin
					pulse_out_state <= PULSE_OUT_ENDING;
				end
			end
			
			PULSE_OUT_ENDING: begin
				pulse_output <= 1'b0;
				if(pulse_in_state == PULSE_IN_IDLE)
					pulse_out_state <= PULSE_OUT_IDLE;
			end
		endcase
  end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		pulse_input_d0 <= pulse_input;
		pulse_input_d1 <= pulse_input_d0;
		pulse_input_d2 <= pulse_input_d1;
		pulse_input_d3 <= pulse_input_d2;
		pulse_input_d4 <= pulse_input_d3;
		pulse_input_d5 <= pulse_input_d4;
		pulse_input_d6 <= pulse_input_d5;
		pulse_input_d7 <= pulse_input_d6;
		pulse_input_d8 <= pulse_input_d7;
		pulse_input_d9 <= pulse_input_d8;
		pulse_input_d10 <= pulse_input_d9;
		pulse_input_d11 <= pulse_input_d10;
		pulse_input_d12 <= pulse_input_d11;
		pulse_input_d13 <= pulse_input_d12;
		pulse_input_d14 <= pulse_input_d13;
		pulse_input_d15 <= pulse_input_d14;
		pulse_input_d16 <= pulse_input_d15;
		pulse_input_d17 <= pulse_input_d16;
		pulse_input_d18 <= pulse_input_d17;
		pulse_input_d19 <= pulse_input_d18;
		pulse_in_countdown <= pulse_in_countdown - 32'd1;
		case (pulse_in_state)
			PULSE_IN_IDLE: begin
				if(start_pulse_in)begin
					pulse_in_countdown <= 32'hFFFFFFFF;
					fifo_wr_en <= 1'b0;
					pulse_in_state <= PULSE_IN_WAITING;
				end
				else
					fifo_wr_en <= 1'b0;
			end

			PULSE_IN_WAITING: begin
				full_pulse_variance <= pulse_width;
				if (pulse_input && pulse_input_d0 && pulse_input_d1 && pulse_input_d2 && pulse_input_d3 && pulse_input_d4 && pulse_input_d5 && pulse_input_d6 && pulse_input_d7 && pulse_input_d8 && pulse_input_d9 && pulse_input_d10
				&& pulse_input_d11 && pulse_input_d12 && pulse_input_d13 && pulse_input_d14 && pulse_input_d15 && pulse_input_d16 && pulse_input_d17 && pulse_input_d18 && pulse_input_d19)begin
					fifo_wr_en <= 1'b0;
					pulse_delay <= delay_counter;
					pulse_in_state <= PULSE_IN_IN_PROCESS;
				end
				else if (!pulse_in_countdown)begin
					fifo_wr_en <= 1'b1;
					fifo_din <= {2'b11, 55'd0};
					pulse_in_state <= PULSE_IN_IDLE;
				end
				else
					fifo_wr_en <= 1'b0;
			end

			PULSE_IN_IN_PROCESS: begin
				fifo_wr_en <= 1'b0;
				full_pulse_variance <= full_pulse_variance - 30'd1;
				if ((~pulse_input) && (~pulse_input_d0) && (~pulse_input_d1) && (~pulse_input_d2) && (~pulse_input_d3) && (~pulse_input_d4) && (~pulse_input_d5) && (~pulse_input_d6) && (~pulse_input_d7) && (~pulse_input_d8) && (~pulse_input_d9) && (~pulse_input_d10) && (~pulse_input_d11) && (~pulse_input_d12) && (~pulse_input_d13) && (~pulse_input_d14) && (~pulse_input_d15) && (~pulse_input_d16) && (~pulse_input_d17) && (~pulse_input_d18) && (~pulse_input_d19))begin
					pulse_in_state <= PULSE_IN_ENDING;
				end
			end
			
			PULSE_IN_ENDING: begin
				fifo_wr_en <= 1'b1;
				fifo_din <= {1'b0, pulse_delay-32'd4, (full_pulse_variance[23:0]+24'd2)};
				pulse_in_state <= PULSE_IN_IDLE;
			end
		endcase
  end
end


always@(posedge clk or posedge rst) begin
	if (rst) begin
		load <= 1'b0;
	end
	else begin
		if(~in_precess)begin
			load <= 1'b1;
			seed <= 12'hFFF;
		end
		else begin
			load <= 1'b0;
		end
  end
end


pulse_tester_fifo pulse_tester_fifo(
	.clk(clk),
	.rst(rst),
	.din(fifo_din),
	.wr_en(fifo_wr_en),
	.rd_en(pulse_tester_rd_en),
	.dout(pulse_tester_data),
	.full(),
	.empty(pulse_tester_data_not_available)
	);
	
endmodule
