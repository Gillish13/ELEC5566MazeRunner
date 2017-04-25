module Maze_Game # (
	parameter WIDTH 	= 10,
	parameter HEIGHT 	= 10
)(
	//input		[10:0]						seed,
	input										reset,
	input										clock,
	
	input		[10:0]						maze_address,
	
	input		[3:0]							player_direction,

	
	output									maze_address_data,
	
	
	output	[7:0]	player_x,
	output	[7:0]	player_y
	//output									gen_end,
	//output	[(WIDTH * HEIGHT)-1:0]	maze

);

	wire reset_player;
	wire player_at_end;
	wire	gen_start;

	wire	gen_end;
	
	wire		[10:0]	maze_input_address;
	
	wire 					maze_input_data;
	
	
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

	/*
	// Set up clock signal
	always begin
		clock = ~clock;
	end
	*/
	
	assign reset_player = !gen_end;
	assign gen_start = player_at_end;
	//assign maze = maze_wire;
	
endmodule
