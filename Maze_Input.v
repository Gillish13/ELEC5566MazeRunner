module Maze_Input # (
	parameter WIDTH = 10,
	parameter HEIGHT = 10
)(
	input 									clock,

		
	input		[3:0]							player_direction,
	input										at_start,
	input						 				maze_input_data,
	//input 	[(WIDTH * HEIGHT)-1:0]	maze,
	
	output	[7:0]							player_x,
	output	[7:0]							player_y,
	
	output	[10:0]						maze_input_address,
	
	output									at_end
);

	localparam A = 3'b000;
	localparam B = 3'b001;
	localparam C = 3'b010;
	localparam D = 3'b011;
	localparam E = 3'b100;
	localparam F = 3'b101;
	
	reg [2:0]	state;
	reg [2:0]	next_state;
		
	localparam UP 		= 4'b0001;
	localparam DOWN 	= 4'b0010;
	localparam RIGHT	= 4'b0100;
	localparam LEFT	= 4'b1000;
	
	localparam FLOOR	= 1'b0;
	localparam WALL 	= 1'b1;
	
	reg	[3:0]	prev_direction;
	reg	[3:0] requested_direction;
	
	reg 	[7:0]	x_reg;
	reg	[7:0]	y_reg;
	
	reg	[10:0]	maze_input_address_reg;
	
	reg	end_reg;
	
	
	always @(posedge clock) begin
	
		if (at_start == 1'b1) begin
			x_reg <= 8'd0;
			y_reg <= 8'd0;
			end_reg <= 1'b0;	
		end
		
		if (((player_x == WIDTH - 1 && (WIDTH - 1) % 2 == 0) || (player_x == WIDTH - 2 && (WIDTH - 2) % 2 == 0))  && player_y == HEIGHT - 1) begin
			end_reg <= 1'b1;
			x_reg <= 8'd0;
			y_reg <= 8'd0;
		end
		// TESTING ONLY
		else if (player_x == WIDTH - 1 && player_y == 0) begin
			end_reg <= 1'b1;
			x_reg <= 8'd0;
			y_reg <= 8'd0;
		end else begin
			end_reg <= 1'b0;
		end
		
		case(state)
		
			// Check if a direction has been pressed
			// If direction pressed, request relevant tile data + wait
			// Move player to new location if possible
			// If player moved, check if at end
			
			// Check if a direction has been pressed
			// If direction pressed, request relevant tile data
			A : begin
				if (player_direction == UP && player_y > 8'h00 && player_direction != prev_direction) begin
					maze_input_address_reg <= (WIDTH * (player_y - 1)) + player_x;
					requested_direction <= UP;
					state <= B;
				end else if (player_direction == DOWN && player_y < HEIGHT - 1 && player_direction != prev_direction) begin
					maze_input_address_reg <= (WIDTH * (player_y + 1)) + player_x;
					requested_direction <= DOWN;
					state <= B;
				end else if (player_direction == RIGHT && player_x < WIDTH - 1 && player_direction != prev_direction) begin
					maze_input_address_reg <= (WIDTH * player_y) + player_x + 1;
					requested_direction <= RIGHT;
					state <= B;
				end else if (player_direction == LEFT && player_x > 8'h00 && player_direction != prev_direction) begin
					maze_input_address_reg <= (WIDTH * player_y) + player_x - 1;
					requested_direction <= LEFT;
					state <= B;
				end else begin
					prev_direction <= player_direction;
					state <= A;
				end
			end
			
			// Wait
			B : begin
				prev_direction <= player_direction;
				state <= C;
			end
			
			// Wait
			C : begin
				state <= D;
			end
			
			// Move player to new location if possible
			D : begin
				if (maze_input_data == FLOOR) begin
					case (requested_direction) 
						UP : begin
							y_reg <= player_y - 1;
						end
						
						DOWN : begin
							y_reg <= player_y + 1;
						end
						
						LEFT : begin
							x_reg <= player_x - 1;
						end
						
						RIGHT : begin
							x_reg <= player_x + 1;
						end
					endcase
				end
				
				state <= A;
			end
			
		endcase
		
	end
	
	/*
	always @(player_direction or at_start) begin
		if (at_start == 1'b1) begin
			x_reg = 1'b0;
			y_reg = 1'b0;
			end_reg = 1'b0;
		end else begin
			if (player_direction == UP && player_y > 8'h00 && maze[(WIDTH * (player_y - 1)) + player_x] == 0) begin
				// Move up
				y_reg = player_y - 8'h01;
			end else if (player_direction == DOWN && player_y < HEIGHT - 1 && maze[(WIDTH * (player_y + 1)) + player_x] == 0) begin
				// Move down
				y_reg = player_y + 8'h01;
			end else if (player_direction == RIGHT && player_x < WIDTH - 1 && maze[(WIDTH * player_y) + player_x + 1] == 0) begin
				// Move right
				x_reg = player_x + 8'h01;
			end else if (player_direction == LEFT && player_x > 8'h00 && maze[(WIDTH * player_y) + player_x - 1] == 0) begin
				// Move left
				x_reg = player_x - 8'h01;
			end
			
			if (((player_x == WIDTH - 1 && (WIDTH - 1) % 2 == 0) || (player_x == WIDTH - 2 && (WIDTH - 2) % 2 == 0))  && player_y == HEIGHT - 1) begin
			end_reg = 1'b1;
		end else begin
			end_reg = 1'b0;
		end
			
		end
	end
	*/
	
	assign maze_input_address = maze_input_address_reg;
	
	assign player_x = x_reg;
	assign player_y = y_reg;
	
	assign at_end = end_reg;
	
endmodule
