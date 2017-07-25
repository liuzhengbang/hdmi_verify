`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:45:06 03/18/2017 
// Design Name: 
// Module Name:    image_gererator_peripheral 
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
module image_gererator_peripheral(
  input clk,
  input [11:0] h_active_value,
  input [11:0] v_active_value,
  input [3:0] sel,
  output reg[7:0] red,
  output reg[7:0] green,
  output reg[7:0] blue
  );
  
parameter H_TOTAL = 12'd1920;
parameter V_TOTAL = 12'd1080;

reg [11:0] h_advanced0;
wire [7:0] generated_r;
wire [7:0] generated_g;
wire [7:0] generated_b;

always@(posedge clk)
begin
  begin
    red <= generated_r;
	 green <= generated_g;
	 blue <= generated_b;
  end
end


always@(posedge clk)
begin
	if(h_active_value == H_TOTAL)
		begin
		   h_advanced0 <= 12'b0;
		end
	if(h_active_value == H_TOTAL - 12'b1)
		begin
		   h_advanced0 <= 12'b0;
		end
	else
		begin
			h_advanced0 <= h_active_value + 12'b1;
		end
end


image_gererator image_gererator (
  .h_active_value(h_advanced0),
  .v_active_value(v_active_value),
  .sel(sel),
  .red(generated_r),
  .green(generated_g),
  .blue(generated_b)
  );

endmodule
