module Maze_Game # (
	parameter WIDTH 	= 10,
	parameter HEIGHT 	= 10,
	
	parameter MINS = 1,
	parameter SECS = 0,
	
	parameter CLK_F = 50000000 // 50 MHz
)(
	input		[3:0]							player_direction,
	input		[10:0]						seed,
	input										reset,
	input										clock,
	
	//output									gen_end,
	output	[(WIDTH * HEIGHT)-1:0]	maze,
	
	output	[6:0]							segout_0,
	output	[6:0]							segout_1,
	output	[6:0]							segout_2,
	output	[6:0]							segout_3
);
	
	integer maze_count;
	
	wire	[(WIDTH * HEIGHT)-1:0]	maze_wire;
	
	wire	[7:0]	player_x;
	wire	[7:0]	player_y;
	
	wire 	reset_player;
	wire 	player_at_end;
	wire	gen_start;
	reg	stop_player;

	wire	gen_end;
	
	wire	timer_end;
	
	always @(posedge player_at_end or negedge reset or posedge timer_end) begin
		if (reset == 1'b0) begin
			maze_count = 0;
			stop_player = 1'b0;
		end if (player_at_end == 1'b1) begin
			maze_count = maze_count + 32'd1;
		end else if (timer_end == 1'b1) begin
			stop_player = 1'b1;
		end
	end
	
	Maze_Input # (
		.WIDTH	(WIDTH	),
		.HEIGHT	(HEIGHT	)
	) maze_input (
		.player_direction	(player_direction	),
		.maze					(maze_wire			),
		.at_start			(reset_player		),
		.stop_player		(stop_player		),
		.player_x			(player_x			),
		.player_y			(player_y			),
		.at_end				(player_at_end		)
	);
	
	Maze_Maker # (
		.WIDTH	(WIDTH	),
		.HEIGHT	(HEIGHT	)
	) maze_maker(
		.gen_start	(gen_start),
		.seed			(seed),
		.reset		(reset),
		.clock		(clock),
		.maze			(maze_wire),
		.gen_end		(gen_end)
	);
	
	SevenSegTimer # (
		.MINS		(MINS		),
		.SECS		(SECS		),
		.CLK_F	(CLK_F	)
	) timer (
		.clock		(clock		),
		.reset		(reset		),
		.timer_end	(timer_end	),
		.segout_0	(segout_0	),
		.segout_1	(segout_1	),
		.segout_2	(segout_2	),
		.segout_3	(segout_3	)
	);
	
	assign reset_player = !gen_end;
	assign gen_start = player_at_end;
	assign maze = maze_wire;
	
endmodule
