`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:06:15 03/30/2017
// Design Name:   hdmi_driver
// Module Name:   C:/Users/liuzh_000/Documents/GE/B Project/hdmi_verify/hdmi_driver_tb.v
// Project Name:  hdmi_verify
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: hdmi_driver
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module hdmi_driver_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [15:0] time_count;

	// Outputs
	wire hs;
	wire vs;
	wire de;
	wire [7:0] rgb_r;
	wire [7:0] rgb_g;
	wire [7:0] rgb_b;
	wire hs_reg;
	wire vs_reg;
	wire hs_reg_d0;
	wire vs_reg_d0;
	wire [11:0] h_cnt;
	wire [11:0] v_cnt;
	wire [11:0] active_x;
	wire [11:0] active_y;
	wire [7:0] rgb_r_reg;
	wire [7:0] rgb_g_reg;
	wire [7:0] rgb_b_reg;

	// Instantiate the Unit Under Test (UUT)
	hdmi_driver uut (
		.clk(clk), 
		.rst(rst), 
		.time_count(time_count), 
		.hs(hs), 
		.vs(vs), 
		.de(de), 
		.rgb_r(rgb_r), 
		.rgb_g(rgb_g), 
		.rgb_b(rgb_b), 
		.hs_reg(hs_reg), 
		.vs_reg(vs_reg), 
		.hs_reg_d0(hs_reg_d0), 
		.vs_reg_d0(vs_reg_d0), 
		.h_cnt(h_cnt), 
		.v_cnt(v_cnt), 
		.active_x(active_x), 
		.active_y(active_y), 
		.rgb_r_reg(rgb_r_reg), 
		.rgb_g_reg(rgb_g_reg), 
		.rgb_b_reg(rgb_b_reg)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		time_count = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	
	always 
	begin
		#5
		clk=~clk;
		end
      
endmodule

