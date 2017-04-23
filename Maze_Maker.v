module Maze_Maker # (
	parameter WIDTH = 30,
	parameter HEIGHT = 40
)(
	input 				gen_start,
	
	input		[10:0]	seed,
	input					reset,
	input					clock,
	
	input		[10:0]	maze_address,
	
	output				maze_address_data,
	output				gen_end
);

	reg [1:0]	state;
	reg [1:0]	next_state;
	
	localparam A = 2'b00;
	localparam B = 2'b01;
	localparam C = 2'b10;
	localparam D = 2'b11;
	
	localparam FLOOR	= 1'b0;
	localparam WALL 	= 1'b1;
	
	integer x, y, last_wall_x;
	
	reg make_opening;
	
	reg									finished;
	
	wire	[10:0]						rand;
	
	// RAM registers
	reg	[10:0]	address;
	reg				data;
	reg				wren;
	
	
	LFSR_11_Bit prng (
		.seed		(seed		),
		.reset	(reset	),
		.clock	(clock	),
		.out		(rand		)
	);
	
	
	RAM maze_ram (
		.address	(address					),
		.clock	(clock					),
		.data		(data						),
		.wren		(wren						),
		.q			(maze_address_data	)
	);
	
	reg increment;
	
	// X counter
	always @(posedge clock or posedge reset) begin
		if (reset) begin
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
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			y <= 0;
		end else if (increment == 1'b1 && x == (WIDTH - 1)) begin
			if (y < (HEIGHT)) begin
            y <= y + 32'd1;
        end else begin
            y <= 32'b0;
        end
		end
	end
	
	always @(state or maze_address) begin
		case(state)
			// Initilize
			A : begin
				//x = -1;
				//y = 32'd0;
				finished = 1'b0;
				last_wall_x = -1;
				wren = 1'b1;
				make_opening = 1'b0;
				
				increment <= 1;
				
				next_state <= B;
			end
			
			// Set up tile
			B : begin
				increment <= 0;

				if (y % 2 == 1) begin
					address = (WIDTH * y) + x;
					data = WALL;
				end else if (y % 2 == 0) begin
					address = (WIDTH * y) + x;
					data = FLOOR;
				end
				
				next_state <= C;
			end
			
			
			// Iterate through the maze's array + make openings in the row above
			C : begin
				increment <= 1;
				
				// Check if y position is in bounds
				if (y >= HEIGHT - 1 && x >= WIDTH - 1) begin
					increment <= 0;
					// End generating
					next_state <= D;
				end else begin
					//x = x + 32'd1;
					next_state <= B;
				end
				
			end
			// End generate
			D : begin
				finished = 1'b1;
				wren = 1'b0;
				
				address = maze_address;
				
				next_state <= D;
			end
		endcase
	end
	
	/*
	always @(state or maze_address) begin
		case(state)
			// Initilize
			A : begin
				//x = -1;
				//y = 32'd0;
				finished = 1'b0;
				last_wall_x = -1;
				wren = 1'b1;
				make_opening = 1'b0;
				
				increment <= 1;
				
				next_state <= B;
			end
			
			// Set up tile
			B : begin
				increment <= 0;

				// Create exit
				if (((x == WIDTH - 1 && (WIDTH - 1) % 2 == 0) || (x == WIDTH - 2 && (WIDTH - 2) % 2 == 0)) && y == HEIGHT - 1) begin
					address = (WIDTH * y) + x;
					data = FLOOR;
				end
				// First row are all floor tiles
				else if (y == 32'd0) begin
					address = x;
					data = FLOOR;
				end
				// Odd rows start off as walls
				else if (y % 2 == 1) begin
					address = (WIDTH * y) + x;
					data = WALL;
				end
				// Even columns on even rows are always floor tiles
				else if (y % 2 == 0 && x % 2 == 0) begin
					address = (WIDTH * y) + x;
					data = FLOOR;
				end
				// A wall is made 
				else if ((rand % 2) == 1'b0) begin
					// Write a wall to the current tile
					address = (WIDTH * y) + x;
					data = WALL;
					// Set make opening flag
					make_opening = 1'b1;
				end
				// Wall is not made on that space
				else begin
					// Set current tile to be a floor
					address = (WIDTH * y) + x;
					data = FLOOR;
				end
				
				next_state <= C;
			end
			
			
			// Iterate through the maze's array + make openings in the row above
			C : begin
				increment <= 1;
				
				if (make_opening == 1'b1) begin
					make_opening = 1'b0;
					if (x == 1) begin
						address = (WIDTH * (y - 1));
						data = FLOOR;
					end else begin
						address = (WIDTH * (y - 1)) + (rand % ((x - last_wall_x) / 2) * 2) + last_wall_x + 1;
						data = FLOOR;
					end
					
					last_wall_x = x;
					
				end else 
				
				if (x == 0 && y % 2 == 1) begin
					address = (WIDTH * (y - 2)) + (rand % ((WIDTH - last_wall_x) / 2) * 2) + last_wall_x + 1;
					data = FLOOR;
					
					// Set cursor to be at the start of the next row
					//x = -1;
					//y = y + 32'd1;
					
					// Reset the x coordinate of the last made wall
					last_wall_x = -1;
				end
				
				// Check if y position is in bounds
				if (y >= HEIGHT - 1 && x >= WIDTH - 1) begin
					increment <= 0;
					// End generating
					next_state <= D;
				end else begin
					//x = x + 32'd1;
					next_state <= B;
				end
				
			end
			// End generate
			D : begin
				finished = 1'b1;
				wren = 1'b0;
				
				address = maze_address;
				
				next_state <= D;
			end
		endcase
	end
	*/
	
	// Change state of the state machine
	always @(posedge clock or posedge reset or posedge gen_start) begin
		if (reset == 1'b1 || gen_start == 1'b1) begin
			state <= A;
		end else begin
			state <= next_state;
		end
	end
	
	//assign maze = buffer;
	assign gen_end = finished;
	
endmodule
