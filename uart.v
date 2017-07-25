`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Zhengbang Liu
// 
// Create Date:    19:35:08 03/21/2017 
// Design Name: 
// Module Name:    uart_control 
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
module uart(
   input clk,
   input rst,
	 
   input rx,
   output reg [7:0]rx_byte,
   input tx_enable,        //Transmit enable
   output is_receiving,    // Low when receive line is idle.	 
	 
   output tx,
   input [7:0]tx_byte,
   output rx_available,         //One Byte has been received
   output is_transmitting // Low when transmit line is idle.
   );

parameter CLOCK_DIVIDE = 12'd3867; // clock rate (50Mhz) / (baud rate (9600) * 4)

// States for RX
parameter RX_IDLE = 3'd0;
parameter RX_CHECK_START = 3'd1;
parameter RX_READ_BITS = 3'd2;
parameter RX_CHECK_STOP = 3'd3;
parameter RX_DELAY_RESTART = 3'd4;
parameter RX_ERROR = 3'd5;
parameter RX_RECEIVED = 3'd6;

// States for the TX
parameter TX_IDLE = 2'd0;
parameter TX_SENDING = 2'd1;
parameter TX_END_SENDING = 2'd2;

reg [12:0]rx_clk_divider = CLOCK_DIVIDE;
reg [12:0]tx_clk_divider = CLOCK_DIVIDE;

reg [2:0]recv_state = RX_IDLE;
reg [5:0]rx_countdown;
reg [3:0]rx_bits_remaining;

reg tx_out = 1'b1;
reg [1:0]tx_state = TX_IDLE;
reg [5:0]tx_countdown;
reg [3:0]tx_bits_remaining;
reg [7:0]tx_data;

assign rx_available = recv_state == RX_RECEIVED;
assign is_receiving = recv_state != RX_IDLE;

assign tx = tx_out;
assign is_transmitting = tx_state != TX_IDLE;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		recv_state <= RX_IDLE;
	end
	
	else begin
		rx_clk_divider <= rx_clk_divider - 11'd1;
		if (!rx_clk_divider) begin
			rx_clk_divider <= CLOCK_DIVIDE;
			rx_countdown <= rx_countdown - 6'd1;
		end
			
		case (recv_state)
			RX_IDLE: begin
				// A low pulse on the receive line indicates the
				// start of data.
				if (!rx) begin
					rx_clk_divider <= CLOCK_DIVIDE;
					rx_countdown <= 6'd2;
					recv_state <= RX_CHECK_START;
				end
			end
		
			RX_CHECK_START: begin
				if (!rx_countdown) begin
					// Check the pulse is still there
					if (!rx) begin
						rx_countdown <= 6'd4;
						rx_bits_remaining <= 4'd7;
						recv_state <= RX_READ_BITS;
					end
					else begin
						recv_state <= RX_IDLE;
					end
				end
			end
		
			RX_READ_BITS: begin
				if (!rx_countdown) begin
					rx_byte <= {rx, rx_byte[7:1]};
					rx_countdown <= 6'd4;
					rx_bits_remaining <= rx_bits_remaining - 4'd1;
					recv_state <= rx_bits_remaining ? RX_READ_BITS : RX_CHECK_STOP;
				end
			end
		
			RX_CHECK_STOP: begin
				if (!rx_countdown) begin
					recv_state <= rx ? RX_RECEIVED : RX_CHECK_STOP;
				end
			end

			RX_RECEIVED: begin
				recv_state <= RX_IDLE;
			end
		endcase
	end
end


always @(posedge clk or posedge rst) begin
	if (rst) begin
		tx_state <= TX_IDLE;
	end
	
	else begin
		tx_clk_divider <= tx_clk_divider - 11'd1;
		if (!tx_clk_divider) begin
			tx_clk_divider <= CLOCK_DIVIDE;
			tx_countdown <= tx_countdown - 6'd1;
		end

		case (tx_state)
			TX_IDLE: begin
				if (tx_enable) begin
					tx_data <= tx_byte;
					tx_clk_divider <= CLOCK_DIVIDE;
					tx_countdown <= 6'd4;
					tx_out <= 1'b0;
					tx_bits_remaining <= 4'd8;
					tx_state <= TX_SENDING;
				end
			end
			
			TX_SENDING: begin
				if (!tx_countdown) begin
					if (tx_bits_remaining) begin
						tx_bits_remaining <= tx_bits_remaining - 4'd1;
						tx_out <= tx_data[0];
						tx_data <= {1'b0, tx_data[7:1]};
						tx_countdown <= 6'd4;
						tx_state <= TX_SENDING;
					end 
					else begin
						tx_out <= 1'b1;
						tx_countdown <= 6'd8;
						tx_state <= TX_END_SENDING;
					end
				end
			end
			
			TX_END_SENDING: begin
				if (!tx_countdown)
					tx_state <= TX_IDLE;
			end
		endcase
	end
end

endmodule
