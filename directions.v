module directions (
	
	input clock,
	
	input reset,
	
	inout ps2_clk,
	inout ps2_data,
	
	output [3:0]direction
	
);

wire [7:0] data;
wire ready;


ps2_host directions (
	
	.sys_clk(clock),
	.sys_rst(reset),
	.ps2_clk(ps2_clk),
	.ps2_data(ps2_data),
	
	.rx_data(data),
	.ready(ready)
);


reg [3:0] direction_reg;
assign direction = direction_reg;

reg [7:0] last_key;
reg [7:0] break_key;


always @ (posedge clock) begin
	if (ready) begin
		// left
		if (data == 8'h1C && last_key != 8'hF0) begin
			direction_reg = 4'b1000;
		end 
		// down
		else if (data == 8'h1B && last_key != 8'hF0) begin
			direction_reg = 4'b0010;
		end 
		// up
		else if (data == 8'h1D && last_key != 8'hF0) begin
			direction_reg = 4'b0001;
		end  
		// right
		else if (data == 8'h23 && last_key != 8'hF0) begin
			direction_reg = 4'b0100;
		end 
	
		else begin
			direction_reg = 4'b0000;
		end
		
		last_key <= data;
		
	end else if (data == 8'hF0) begin
		last_key <= data;
	end 
end


	


endmodule

