`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	Zhengbang Liu
// 
// Create Date:    22:51:31 03/22/2017 
// Design Name: 
// Module Name:    uart_interface 
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
module uart_interface(
	input clk,
	input rst,
	
	input uart_rx,	
	output uart_tx,
	
	input tx_data_enable,
	output rx_data_available,

	input [7:0]byte_to_uart,
	output [7:0]byte_from_uart,

	//input rd_en,

	output error_fifo_full
	);

// States for Transmit
parameter TRANS_IDLE = 2'd0;
parameter TRANS_RD_FIFO= 2'd1;
parameter TRANS_PREPARE_TRANSMIT = 2'd2;
parameter TRANS_TRANSMIT = 2'd3;
reg [1:0] trans_state = TRANS_IDLE;

wire [7:0]tx_fifo_din;
wire tx_fifo_wr_en;
reg tx_fifo_rd_en;
wire [7:0]tx_fifo_dout;
wire tx_fifo_full;
wire tx_fifo_empty;

reg [7:0]byte_waiting_transmit;
wire uart_is_transmitting;
reg uart_tx_enable;
reg [7:0]uart_tx_byte;
wire uart_rx_available;
wire [7:0]uart_rx_byte;

assign tx_fifo_wr_en = tx_data_enable;
assign tx_fifo_din = byte_to_uart;
//assign rx_fifo_rd_en = rd_en;
assign error_fifo_full = tx_fifo_full;
assign byte_from_uart = uart_rx_byte;

assign rx_data_available = uart_rx_available;

transmit_fifo transmit_fifo(
	.clk(clk),
	.rst(rst),
	.din(tx_fifo_din),
	.wr_en(tx_fifo_wr_en),
	.rd_en(tx_fifo_rd_en),
	.dout(tx_fifo_dout),
	.full(tx_fifo_full),
	.empty(tx_fifo_empty)
	);


always @(posedge clk or posedge rst) begin
	if (rst) begin
	byte_waiting_transmit <= 8'd0;
	uart_tx_enable <= 1'b0;
	end
	else begin
		case (trans_state)
			TRANS_IDLE: begin
				uart_tx_enable <=1'b0;
				if (!tx_fifo_empty) begin
					tx_fifo_rd_en <= 1'b1;
					trans_state <= TRANS_RD_FIFO;
				end
			end

			TRANS_RD_FIFO: begin
				if (tx_fifo_rd_en == 1'b1)begin
					tx_fifo_rd_en <= 1'b0;
				end
				else begin
					byte_waiting_transmit <= tx_fifo_dout;
					trans_state <= uart_is_transmitting ? TRANS_PREPARE_TRANSMIT : TRANS_TRANSMIT;
				end
			end

			TRANS_PREPARE_TRANSMIT: begin
				if (!uart_is_transmitting) begin
					uart_tx_enable <= 1'b1;
					uart_tx_byte <= byte_waiting_transmit;
					trans_state <= TRANS_IDLE;
				end
			end

			TRANS_TRANSMIT: begin
				uart_tx_enable <= 1'b1;
				uart_tx_byte <= byte_waiting_transmit;
				trans_state <= TRANS_IDLE;
			end
		endcase
	end
end

uart uart_m(
	.clk(clk),
	.rst(rst),
	.rx(uart_rx),
	.tx(uart_tx),
	.tx_enable(uart_tx_enable),
	.tx_byte(uart_tx_byte),
	.rx_available(uart_rx_available),
	.rx_byte(uart_rx_byte),
	.is_receiving(),
	.is_transmitting(uart_is_transmitting)
	);

endmodule
