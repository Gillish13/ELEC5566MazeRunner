module Maze_Maker # (
	parameter WIDTH = 10,
	parameter HEIGHT = 10
)(
	input 									gen_start,

	input		[7:0]							seed,
	input										reset,
	input										clock,
	
	output									gen_end,
	output	[(WIDTH * HEIGHT)-1:0]	maze
);

	reg [1:0]	state;
	reg [1:0]	next_state;
	
	localparam A = 2'b00;
	localparam B = 2'b01;
	localparam C = 2'b10;
	localparam D = 2'b11;

	integer x, y, last_wall_x;
	
	reg	[(WIDTH * HEIGHT)-1:0]	buffer;
	
	reg									finished;
	
	wire	[7:0]							rand;
	
	LFSR_8_Bit prng (
		.seed		(seed		),
		.reset	(reset	),
		.clock	(clock	),
		.out		(rand		)
	);
	
	always @(state) begin
		case(state)
			// Iterate through the maze's array
			A : begin
				if (x >= WIDTH) begin
						x = 32'd1;
						
						// Add connection to column at end of row
						buffer[(WIDTH * (y - 1)) + (rand % ((WIDTH - last_wall_x) / 2) * 2) + last_wall_x + 1] = 1'b0;
						
						y = y + 32'd2;
						last_wall_x = -1;
				end
				if (y >= HEIGHT) begin
						next_state <= C;
					end else begin
						next_state <= B;
					end
				end
			
			// Set up wall
			B : begin
				if ((rand % 2) == 1'b1) begin
					buffer[(WIDTH * y) + x] = 1'b1;
					
					if (x == 1) begin
						buffer[(WIDTH * (y - 1)) + 0] = 1'b0;
					end else begin
						buffer[(WIDTH * (y - 1)) + (rand % ((x - last_wall_x) / 2) * 2) + last_wall_x + 1] = 1'b0;
					end
					
					last_wall_x = x;
					
					x = x + 32'd2;
					next_state <= A;
				end else begin
					x = x + 32'd2;
					next_state <= A;
				end
			end
			
			// End generate
			C : begin
				finished = 1'b1;
				next_state <= C;
			end
			
			// Initilize
			D : begin
				finished = 1'b0;
				for (x = 32'd0; x < WIDTH; x = x + 1) begin
					for (y = 32'd0; y < HEIGHT; y = y + 1) begin
						if (y % 2 == 32'd0 || (((x == WIDTH - 1 && (WIDTH - 1) % 2 == 0) || (x == WIDTH - 2 && (WIDTH - 2) % 2 == 0)) && y == HEIGHT - 1)) begin
							buffer[(WIDTH * y) + x] = 1'b0;
						end
						else begin
							buffer[(WIDTH * y) + x] = 1'b1;
						end
					end
				end
				
				x = 32'd1;
				y = 32'd2;
				
				next_state <= A;
			end
		endcase
	end
	
	always @(posedge clock or negedge reset or posedge gen_start) begin
		if (reset == 1'b0 || gen_start == 1'b1) begin
			state <= D;
		end else begin
			state <= next_state;
		end
	end
	
	assign maze = buffer;
	assign gen_end = finished;
	
endmodule
