module Maze_Maker # (
	// Parameters to set the dimensions of the maze
	parameter WIDTH = 30,
	parameter HEIGHT = 40
)(
	input 			gen_start, // Maze will begin generating when high
	
	input		[10:0]	seed,	// Seed for the PRNG
	input			reset, // Reset signal
	input			clock, // Clock signal
	
	input		[10:0]	maze_address, // RAM address to access the maze. Used by the LCD to get a tile
	input		[10:0]	maze_input_address, // RAM address to access the maze. Used by the player input module
	
	output			maze_address_data, // Data in the RAM address accessed by 'maze_address'
	output 			maze_input_data, // Data in the RAM address accessed by 'maze_input_address'
	
	output			gen_end // Set high when a maze has finished generating
);
	// Localparams for the state machine
	localparam A = 3'b000;
	localparam B = 3'b001;
	localparam C = 3'b010;
	localparam D = 3'b011;
	localparam E = 3'b100;
	localparam F = 3'b101;
	localparam G = 3'b110;
	
	reg [2:0]	state;
	reg [2:0]	next_state;
	
	// Localparams for the maze's tiles
	localparam FLOOR	= 1'b0;
	localparam WALL 	= 1'b1;
	
	integer x, y, last_wall_x;
	
	reg 		make_opening;
	reg		finished;
	
	wire	[10:0]	rand;
	
	// RAM registers
	reg	[10:0]	address;
	reg		data;
	reg		wren;
	
	LFSR_11_Bit prng (
		.seed	(seed	),
		.reset	(reset	),
		.clock	(clock	),
		.out	(rand	)
	);
	
	
	RAM maze_ram (
		.address_a	(address		),
		.address_b	(maze_input_address	),
		.clock		(clock			),
		.data_a		(data			),
		.wren_a		(wren			),
		.wren_b		(1'b0			),
		.q_a		(maze_address_data	),
		.q_b		(maze_input_data	)
	);
	
	reg increment;
	
	// X counter
	always @(posedge clock or posedge reset or posedge gen_start) begin
		if (reset || gen_start) begin
			x <= 0;
		end else if (increment == 1'b1) begin
			if (x < WIDTH - 1) begin
				x <= x + 32'd1;
			end else begin
				x <= 0;
			end
		end
	end
	
	// Y counter
	always @(posedge clock or posedge reset or posedge gen_start) begin
		if (reset || gen_start) begin
			y <= 0;
		end else if (increment == 1'b1 && x == (WIDTH - 1)) begin
			if (y < (HEIGHT)) begin
            			y <= y + 32'd1;
        		end else begin
           			y <= 32'b0;
        		end
		end
	end
	
	
	always @(posedge clock or posedge reset or posedge gen_start) begin
		if (reset == 1'b1 || gen_start == 1'b1) begin
			state <= A; // Reset the state machine
		end else begin
			case(state)
				// Initilize
				A : begin
					finished = 1'b0; // Sets gen_end to 0
					last_wall_x = -1; // Resets the last wall made location
					wren = 1'b1; // Allow for writing to the RAM using port A
					make_opening = 1'b0; // Reset the make_opening flag
					
					increment <= 1; // Set the counters to increment next clock cycle
					
					state <= B; // Move to the next state
				end
				
				// Set up tile
				B : begin
					increment <= 0;

					// Create exit
					if (((x == WIDTH - 1 && (WIDTH - 1) % 2 == 0) || (x == WIDTH - 2 && (WIDTH - 2) % 2 == 0)) && y == HEIGHT - 1) begin
						address <= (WIDTH * y) + x;
						data <= FLOOR;
					end
					// First row are all floor tiles
					else if (y == 32'd0) begin
						address <= x;
						data <= FLOOR;
					end
					// Odd rows start off as walls
					else if (y % 2 == 1) begin
						address <= (WIDTH * y) + x;
						data <= WALL;
					end
					// Even columns on even rows are always floor tiles
					else if (y % 2 == 0 && x % 2 == 0) begin
						address <= (WIDTH * y) + x;
						data <= FLOOR;
					end
					// A wall is made on the current tile
					else if ((rand % 2) == 1'b0) begin
						// Write a wall to the current tile
						address <= (WIDTH * y) + x;
						data <= WALL;
						// Set make opening flag
						make_opening <= 1'b1;
					end
					// Wall is not made on the current tile
					else begin
						// Set current tile to be a floor
						address <= (WIDTH * y) + x;
						data <= FLOOR;
					end
					
					state <= C; // Move to the next state
				end
				
				// Iterate through the maze's array + make openings in the row above
				C : begin
					// Check if an opening in the row above needs to be made
					if (make_opening == 1'b1) begin
						// If a wall is made at x = 1, the opening must be made at (0, y-1)
						if (x == 1) begin
							address <= (WIDTH * (y - 1));
							data <= FLOOR;
						// If the number of tiles between the current wall made and last wall made is 2, opening must be made at (last_wall_x+1,y-1)
						end else if (x - last_wall_x == 2) begin
							address <= (WIDTH * (y - 1)) + last_wall_x + 1;
							data <= FLOOR;
						// Else, create an opening in the row above on an even tile between the last wall made and the current tile
						end else begin
							address <= (WIDTH * (y - 1)) + ((rand % ((x - last_wall_x) / 2)) * 2) + last_wall_x + 1;
							data <= FLOOR;
						end
					end
					
					// If at the start of an odd numbered row, make sure an opening was made to connect the last tile of the row above
					if (x == 0 && y % 2 == 1) begin
						// If the number of tiles between the current wall made and last wall made is 2, opening must be made at (last_wall_x+1,y-2)
						if (x - last_wall_x == 2) begin
							address <= (WIDTH * (y - 2)) + last_wall_x + 1;
							data <= FLOOR;
						// Else, create an opening two rows above on an even tile between the last wall made and the last tile on that row
						end else begin
							address <= (WIDTH * (y - 2)) + ((rand % ((WIDTH - last_wall_x) / 2)) * 2) + last_wall_x + 1;
							data <= FLOOR;
						end
					end
					
					
					// Check if y position is in bounds
					if (y >= HEIGHT - 1 && x >= WIDTH - 1) begin
						increment <= 0;
						// End generating
						state <= F; // Move to the next state
					end else begin
						//x = x + 32'd1;
						state <= D; // Move to the next state
					end
				end
				
				// Set up the last_wall_x value and begin incrementing
				D : begin
					increment <= 1; // Begin incrementing cursor
					// If an opening has just been made, set the x location of the last wall made to be the current x location
					if (make_opening == 1'b1) begin
						last_wall_x <= x;
					end
					
					// If on a new odd row, reset the x value of the last wall made
					if (x == 0 && y % 2 == 1) begin
						last_wall_x <= -1;
					end
					
					state <= E; // Move to the next state
				end
				
				// Wait
				E : begin
					increment <= 0; // Stop increment the cursor
					make_opening <= 1'b0; // Reset the make opening flag
					state <= B; // Move to the next state
				end
				
				// End generate
				F : begin
					wren = 1'b0; // Disable writing to RAM port A
					finished = 1'b1; // Set gen_end to be high
					
					address = maze_address; // Allow for the 'maze_address' input to access the RAM in port A
					
					state <= F; // Move to the next state
				end
			endcase
		end
	end
	
	assign gen_end = finished;
	
endmodule
