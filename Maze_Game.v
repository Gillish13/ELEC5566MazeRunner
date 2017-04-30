module Maze_Game # (
	parameter WIDTH 	= 30,
	parameter HEIGHT 	= 40
)(
	input					reset,
	input					clock,
	input					timer_end,

	input		[10:0]	maze_address,

	input		[3	:0]	player_direction,

	output				maze_address_data,
	
	output	[7	:0]	player_x,
	output	[7	:0]	player_y,
	
	output	[7	:0]	mazes_complete
	
);

	wire reset_player;
	wire player_at_end;
	wire	gen_start;

	wire	gen_end;
	
	wire		[10:0]	maze_input_address;
	
	wire 					maze_input_data;
	
	
	reg [7:0] mazes_complete_reg;
	reg increment_mazes_complete_reg;
	reg player_at_end_once;
	
	// mazes_complete Counter
	always @ (posedge clock or posedge reset) begin
		 if (reset) begin
			  mazes_complete_reg <= 8'b0;
		 end else if (increment_mazes_complete_reg == 1'b1) begin
			  mazes_complete_reg <= mazes_complete_reg + 8'b1;
		 end
	end
	
	always @(posedge clock) begin
		if (player_at_end == 1'b1) begin
			if (player_at_end_once == 1'b0) begin
				increment_mazes_complete_reg <= 1;
				player_at_end_once <= 1'b1;
			end else begin
				increment_mazes_complete_reg <= 0;
			end
		end else begin
			increment_mazes_complete_reg <= 0;
			player_at_end_once <= 1'b0;
		end
	end
	
	Maze_Input # (
		.WIDTH	(WIDTH	),
		.HEIGHT	(HEIGHT	)
	) maze_input (
		.player_direction		(player_direction		),
		.clock					(clock					),
		.at_start				(reset_player			),
		.player_x				(player_x				),
		.player_y				(player_y				),
		.maze_input_data		(maze_input_data		),
		.maze_input_address	(maze_input_address	),
		.at_end					(player_at_end			)
	);
	
	
	Maze_Maker # (
		.WIDTH	(WIDTH	),
		.HEIGHT	(HEIGHT	)
	) maze_maker(
		.gen_start				(gen_start),
		.seed						(11'b10101010101),
		.reset					(reset),
		.clock					(clock),
		.maze_address			(maze_address),
		.maze_input_address	(maze_input_address),
		.maze_address_data	(maze_address_data),
		.maze_input_data		(maze_input_data),
		.gen_end					(gen_end)
	);
	
	assign reset_player = (!gen_end) | timer_end;
	assign gen_start = player_at_end;
	assign mazes_complete = mazes_complete_reg;
	
endmodule
