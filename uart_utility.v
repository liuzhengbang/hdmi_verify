`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:06 03/25/2017 
// Design Name: 
// Module Name:    uart_utility 
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
module uart_utility(
	input clk,
	input rst,
	output tx,
	input rx,
	input [63:0] data,

	input start_tx,
	output [7:0]byte_from_uart,
	output rx_data_available
	);


reg tx_data_enable;
reg [7:0]byte_to_uart;
reg [3:0]tx_counter;
reg [63:0]data_waiting_transmit;
wire [63:0]protocol_fifo_dout;

reg protocol_fifo_rd_en;
wire protocol_fifo_empty;


// States for Transmit
parameter PROTOCOL_IDLE = 2'd0;
parameter PROTOCOL_RD_FIFO= 2'd1;
parameter PROTOCOL_TRANSMIT = 2'd2;
reg [1:0] protocol_state = PROTOCOL_IDLE;


always @(posedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		case (protocol_state)
			PROTOCOL_IDLE: begin
				tx_data_enable <=1'b0;
				if (!protocol_fifo_empty) begin
					protocol_fifo_rd_en <= 1'b1;
					protocol_state <= PROTOCOL_RD_FIFO;
				end
			end

			PROTOCOL_RD_FIFO: begin
				if (protocol_fifo_rd_en == 1'b1)begin
					protocol_fifo_rd_en <= 1'b0;
				end
				else begin
					data_waiting_transmit <= protocol_fifo_dout;
					protocol_state <= PROTOCOL_TRANSMIT;
					tx_counter <= 4'd9;
				end
			end

			PROTOCOL_TRANSMIT: begin
				tx_data_enable <= 1'b1;
				tx_counter <= tx_counter - 4'd1;
				if(tx_counter == 4'd9)
					byte_to_uart <= 8'h4D;//header
				else if(tx_counter == 4'd8)
					byte_to_uart <= 8'h43;//header
					
				else if(tx_counter == 4'd7)
					byte_to_uart <= data_waiting_transmit[63:56];
				else if(tx_counter == 4'd6)
					byte_to_uart <= data_waiting_transmit[55:48];
				else if(tx_counter == 4'd5)
					byte_to_uart <= data_waiting_transmit[47:40];
				else if(tx_counter == 4'd4)
					byte_to_uart <= data_waiting_transmit[39:32];
				else if(tx_counter == 4'd3)
					byte_to_uart <= data_waiting_transmit[31:24];
				else if(tx_counter == 4'd2)
					byte_to_uart <= data_waiting_transmit[23:16];
				else if(tx_counter == 4'd1)
					byte_to_uart <= data_waiting_transmit[15:8];
				else if(tx_counter == 4'd0) begin
						byte_to_uart <= data_waiting_transmit[7:0];
						protocol_state <= PROTOCOL_IDLE;
					end
			end
		endcase
	end
end





uart_protocol_fifo uart_protocol_fifo(
	.clk(clk),
	.rst(rst),
	.din(data),
	.wr_en(start_tx),
	.rd_en(protocol_fifo_rd_en),
	.dout(protocol_fifo_dout),
	.full(),
	.empty(protocol_fifo_empty)
	);


uart_interface m0(
	.clk(clk),
	.rst(rst),
	
	.uart_rx(rx),	
	.uart_tx(tx),
	
	.tx_data_enable(tx_data_enable),
	.rx_data_available(rx_data_available),

	.byte_to_uart(byte_to_uart),
	.byte_from_uart(byte_from_uart),

	.error_fifo_full()
	);



endmodule