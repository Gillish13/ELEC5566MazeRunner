module Maze_Input # (
	parameter WIDTH = 10,
	parameter HEIGHT = 10
)(
	input 			clock, // Clock signal
	input	[3	:0]	player_direction, // The player's direction input
	input			at_start, // Sets the player's position to be (0,0) when this is high
	input			maze_input_data, // Data from the maze's RAM module at address 'maze_input_address'

	output	[7	:0]	player_x, // The player's current x position
	output	[7	:0]	player_y, // The players current y position
	output	[10	:0]	maze_input_address, // The address in the maze RAM to request data from
	output			at_end // Set high when the player reaches the exit tile
);
	// Localparams used by the state machine
	localparam A = 3'b000;
	localparam B = 3'b001;
	localparam C = 3'b010;
	localparam D = 3'b011;
	localparam E = 3'b100;
	localparam F = 3'b101;
	
	reg [2:0]	state;
	
	// Localparams used to determine the direction
	localparam UP 		= 4'b0001;
	localparam DOWN 	= 4'b0010;
	localparam RIGHT	= 4'b0100;
	localparam LEFT		= 4'b1000;
	
	// Localparams used to interpret tile information from the maze RAM
	localparam FLOOR	= 1'b0;
	localparam WALL 	= 1'b1;
	
	reg	[3:0]	prev_direction;
	reg	[3:0] 	requested_direction;
	
	reg 	[7	:0]	x_reg; // Stores the x position of the player
	reg	[7	:0]	y_reg; // Stores the y position of the player
	
	reg	[10	:0]	maze_input_address_reg;
	
	reg			end_reg;
	
	
	always @(posedge clock) begin
		// Reset the player
		if (at_start == 1'b1) begin
			x_reg <= 8'd0;
			y_reg <= 8'd0;
			end_reg <= 1'b0;
			state <= A; // Reset state machine
		end
		
		// Check if the player is at the exit
		if (((player_x == WIDTH - 1 && (WIDTH - 1) % 2 == 0) || (player_x == WIDTH - 2 && (WIDTH - 2) % 2 == 0))  && player_y == HEIGHT - 1) begin
			end_reg <= 1'b1;
			x_reg <= 8'd0;
			y_reg <= 8'd0;
		end
		/*
		// TESTING ONLY
		else if (player_x == WIDTH - 1 && player_y == 0) begin
			end_reg <= 1'b1;
			x_reg <= 8'd0;
			y_reg <= 8'd0;
		end 
		*/
		else begin
			end_reg <= 1'b0;
		end
		
		case(state)	
			// Check if a direction has been pressed
			// If direction pressed, check if the player is in bounds and then request relevant tile data
			A : begin
				if (player_direction == UP && player_y > 8'h00 && player_direction != prev_direction) begin
					// Request the maze's tile in the up direction
					maze_input_address_reg <= (WIDTH * (player_y - 1)) + player_x;
					requested_direction <= UP;
					state <= B; // Next state
				end else if (player_direction == DOWN && player_y < HEIGHT - 1 && player_direction != prev_direction) begin
					// Request the maze's tile in the down direction
					maze_input_address_reg <= (WIDTH * (player_y + 1)) + player_x;
					requested_direction <= DOWN;
					state <= B; // Next state
				end else if (player_direction == RIGHT && player_x < WIDTH - 1 && player_direction != prev_direction) begin
					// Request the maze's tile in the right direction
					maze_input_address_reg <= (WIDTH * player_y) + player_x + 1;
					requested_direction <= RIGHT;
					state <= B; // Next state
				end else if (player_direction == LEFT && player_x > 8'h00 && player_direction != prev_direction) begin
					// Request the maze's tile in the left direction
					maze_input_address_reg <= (WIDTH * player_y) + player_x - 1;
					requested_direction <= LEFT;
					state <= B; // Next state
				end else begin
					prev_direction <= player_direction;
					state <= A; // Next state
				end
			end
			
			// Wait
			B : begin
				prev_direction <= player_direction;
				state <= C; // Next state
			end
			
			// Wait
			C : begin
				state <= D; // Next state
			end
			
			// Move player to new location if possible
			D : begin
				// If the tile requested is a floor, the player can move to it
				// Else do nothing
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
				
				state <= A; // Next state
			end
		endcase
	end
	
	assign maze_input_address = maze_input_address_reg;
	
	assign player_x = x_reg;
	assign player_y = y_reg;
	
	assign at_end = end_reg;
	
endmodule
