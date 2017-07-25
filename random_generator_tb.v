`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:32:25 04/09/2017
// Design Name:   random_generator
// Module Name:   C:/Users/liuzh_000/Documents/GE/B Project/hdmi_verify/random_generator_tb.v
// Project Name:  hdmi_verify
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: random_generator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module random_generator_tb;

	// Inputs
	reg rst;
	reg clk;
	reg load;
	reg [11:0] seed;

	// Outputs
	wire [11:0] rand_num;

	// Instantiate the Unit Under Test (UUT)
	random_generator uut (
		.rst(rst), 
		.clk(clk), 
		.load(load), 
		.seed(seed), 
		.rand_num(rand_num)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;
		load = 1;
		seed = 12'hFFF;

		// Wait 100 ns for global reset to finish
		#100;
        load<=0;
		// Add stimulus here

	end
      
	always 
	begin
		#5
		clk=~clk;
		end
		
endmodule

