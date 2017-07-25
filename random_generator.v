`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:10:30 04/09/2017 
// Design Name: 
// Module Name:    random_generator 
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
module random_generator(
	 input               rst,    /*rst_n is necessary to prevet locking up*/
    input               clk,      /*clock signal*/
    input               load,     /*load seed to rand_num,active high */
    input      [11:0]    seed,     
    output reg [11:0]    rand_num  /*random number output*/
);


always@(posedge clk or posedge rst)
begin
    if(rst)
        rand_num    <=12'b0;
    else if(load)
        rand_num <=seed;    /*load the initial value when load is active*/
    else
        begin
            rand_num[0] <= rand_num[11];
            rand_num[1] <= rand_num[0];
            rand_num[2] <= rand_num[1];
            rand_num[3] <= rand_num[2];
            rand_num[4] <= rand_num[3]^rand_num[11];
            rand_num[5] <= rand_num[4]^rand_num[11];
            rand_num[6] <= rand_num[5]^rand_num[11];
            rand_num[7] <= rand_num[6]^rand_num[11];
				rand_num[8] <= rand_num[7]^rand_num[11];
				rand_num[9] <= rand_num[8]^rand_num[11];
				rand_num[10] <= rand_num[9]^rand_num[11];
				rand_num[11] <= rand_num[10];
        end
            
end
endmodule
