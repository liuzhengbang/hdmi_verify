`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:52:35 03/18/2017 
// Design Name: 
// Module Name:    image_gererator 
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
module image_gererator(
  input [11:0] h_active_value,
  input [11:0] v_active_value,
  input [3:0] sel,
  input [11:0] step_count,
  input [23:0] time_count,
  input [7:0] frame_count,
  output reg[7:0] red,
  output reg[7:0] green,
  output reg[7:0] blue
  );
parameter WHITE_R 		= 8'hff;
parameter WHITE_G 		= 8'hff;
parameter WHITE_B 		= 8'hff;
parameter YELLOW_R 		= 8'hff;
parameter YELLOW_G 		= 8'hff;
parameter YELLOW_B 		= 8'h00;                              	
parameter CYAN_R 		  = 8'h00;
parameter CYAN_G 		  = 8'hff;
parameter CYAN_B 		  = 8'hff;                             	
parameter GREEN_R 		= 8'h00;
parameter GREEN_G 		= 8'hff;
parameter GREEN_B 		= 8'h00;
parameter MAGENTA_R 	= 8'hff;
parameter MAGENTA_G 	= 8'h00;
parameter MAGENTA_B 	= 8'hff;
parameter RED_R 		  = 8'hff;
parameter RED_G 		  = 8'h00;
parameter RED_B 		  = 8'h00;
parameter BLUE_R 		  = 8'h00;
parameter BLUE_G 		  = 8'h00;
parameter BLUE_B 		  = 8'hff;
parameter BLACK_R 		= 8'h00;
parameter BLACK_G 		= 8'h00;
parameter BLACK_B 		= 8'h00;

parameter H_TOTAL = 12'd1920;
parameter V_TOTAL = 12'd1080;
reg [1:0]is_black;


always@(*) begin
  if((h_active_value == 12'd0) && (v_active_value == 12'd0)) begin
    red <= {sel,step_count[11:8]};
    green <= step_count[7:0];
    blue <= frame_count;
  end
  else if((h_active_value == 12'd1) && (v_active_value == 12'd0)) begin
    red <= time_count[23:16];
    green <= time_count[15:8];
    blue <= time_count[7:0];
  end
  else 
  case (sel)
    4'b0000:
      begin
        if(is_black[0] + is_black[1] == 2'b01)         
		  begin
            red <= BLACK_R;
            green <= BLACK_G;
            blue <= BLACK_B;
			 end
		 else
			 begin
            red <= WHITE_R;
            green <= WHITE_G;
            blue <= WHITE_B;
          end
		end
		
	4'b0001:
		begin
			red <= h_active_value[7:0];
			green <= v_active_value[7:0];
			blue <= {h_active_value[11:8], v_active_value[11:8]};	
		end
		
	4'b0010:
		begin
			if((h_active_value == 12'h2cf) && (v_active_value == 12'h0f))
			begin
            red <= 8'hFF;
            green <= 8'hFE;
            blue <= 8'hFD;
			end
			else begin
				red <= 8'hAA;
            green <= 8'hBB;
            blue <= 8'hCC;
			end
		end
		
	4'b0011:
		begin
			if((h_active_value == 12'h2cf) && (v_active_value == 12'h0f))
			begin
            red <= 8'hFF;
            green <= 8'hFF;
            blue <= 8'hFD;
			end
			else begin
				red <= 8'hAA;
            green <= 8'hBB;
            blue <= 8'hCC;
			end
		end
	4'b0100:
		begin
			red <= h_active_value[7:0]+step_count[7:0];
			green <= v_active_value[7:0]+step_count[7:0];
			blue <= {h_active_value[11:8], v_active_value[11:8]}+step_count[7:0];	
		end
		
    default:
	   if(h_active_value == 12'b0 & v_active_value == 12'b0)
		  begin
            red <= BLUE_R;
            green <= BLUE_G;
            blue <= BLUE_B;
		  end
		else if(h_active_value == H_TOTAL - 12'd1 & v_active_value == 12'b0)
		  begin
            red <= BLUE_R;
            green <= BLUE_G;
            blue <= BLUE_B;
		  end
      else if(h_active_value == 12'b0)
		  begin
            red <= WHITE_R;
            green <= WHITE_G;
            blue <= WHITE_B;
		  end
      else if(h_active_value == H_TOTAL-1)
		  begin
            red <= WHITE_R;
            green <= WHITE_G;
            blue <= WHITE_B;
		  end
      else if(v_active_value == 12'b0)
		  begin
            red <= GREEN_R;
            green <= GREEN_G;
            blue <= GREEN_B;
		  end
		 else if(v_active_value == V_TOTAL - 12'd1)
		  begin
            red <= BLUE_R;
            green <= BLUE_G;
            blue <= BLUE_B;
		  end
      else if(v_active_value == V_TOTAL)
		  begin
            red <= GREEN_R;
            green <= GREEN_G;
            blue <= GREEN_B;
		  end
		else
		  begin
            red <= RED_R;
            green <= RED_G;
            blue <= RED_B;
		  end
	endcase

end


always@(h_active_value)
begin
  if(h_active_value < (H_TOTAL/4) * 1)
    begin
      is_black[1] = 1'b1;
    end
  else if(h_active_value < (H_TOTAL/4) * 2)
    begin
      is_black[1] = 1'b0;
    end
  else if(h_active_value < (H_TOTAL/4) * 3)
    begin
      is_black[1] = 1'b1;
    end
  else
    begin
      is_black[1] = 1'b0;
    end
end

always@(v_active_value)
begin
  if(v_active_value < (V_TOTAL/4) * 1)
    begin
      is_black[0] = 1'b1;
    end
  else if(v_active_value < (V_TOTAL/4) * 2)
    begin
      is_black[0] = 1'b0;
    end
  else if(v_active_value < (V_TOTAL/4) * 3)
    begin
      is_black[0] = 1'b1;
    end
  else
    begin
      is_black[0] = 1'b0;
    end
end





endmodule
