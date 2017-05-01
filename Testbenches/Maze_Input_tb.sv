
`timescale 1ns/1ns //Defines the time scale

module Maze_Input_tb;
	
	reg 			clock;
	reg 			reset;
	reg 			maze_input_data;
	reg 	[3	:0]	player_direction;

	wire	[10	:0]	maze_input_address;
	wire	[7	:0]	player_x;
	wire	[7	:0]	player_y;
	wire			at_end;

	// Instantiate Device Under Test (DUT) from Quad_nA_AND_B verilog file.
	Maze_Input # (
			.WIDTH	(5),
			.HEIGHT	(5)
		) DUT (
		// Port map - connection between master ports and signals/registers   
		.clock				(clock 				),
		.player_direction	(player_direction	),
		.at_start			(reset				),
		.player_x			(player_x			),
		.player_y			(player_y			),
		.maze_input_data 	(maze_input_data	),
		.maze_input_address	(maze_input_address	),
		.at_end				(at_end				)
	);
	
	integer i, j;

	// The code in this begin-end block will run only once	 
	initial begin             
		// Reset
		reset = 1'b1;
		clock = 1'b1;
		player_direction = 4'b0000;
		maze_input_data = 1'b0;

		# 20;

		clock = ~ clock;

		#20;

		reset = 1'b0;

		$display("Begining tests...");   
		$display("Checking player keeps in bounds...");

		player_direction = 4'b0001; // Try moving up (to outisde of map)

		// Wait a few clock cycles
		for (i = 32'd0; i < 32'd8; i = i + 32'd1) begin
			clock = ~clock;
			#20;
		end

		if (player_x == 8'd0 && player_y == 8'd0) begin
			$display("Test passed!");
		end else begin
			$display("Test failed!");
		end

		$display("Checking player can move...");

		player_direction = 4'b0100; // Move right

		// Wait a few clock cycles
		for (i = 32'd0; i < 32'd8; i = i + 32'd1) begin
			clock = ~clock;
			#20;
		end

		if (player_x == 8'd1 && player_y == 8'd0) begin
			$display("Test passed!");
		end else begin
			$display("Test failed!");
		end

		$display("Checking player can reach exit...");
		// Need to move right three times and down four times to reach the exit
		
		// Move down four
		for (j = 32'd0; j < 32'd4; j = j + 32'd1) begin
			player_direction = 4'b0010; // Move down

			// Wait a few clock cycles
			for (i = 32'd0; i < 32'd8; i = i + 32'd1) begin
				clock = ~clock;
				#20;
			end

			player_direction = 4'b0000;

			// Wait one clock cycles
			for (i = 32'd0; i < 32'd2; i = i + 32'd1) begin
				clock = ~clock;
				#20;
			end
		end

		// Move right three times
		for (j = 32'd0; j < 32'd3; j = j + 32'd1) begin
			player_direction = 4'b0100; // Move down

			// Wait a few clock cycles
			for (i = 32'd0; i < 32'd8; i = i + 32'd1) begin
				clock = ~clock;
				#20;
			end

			player_direction = 4'b0000;

			// Wait one clock cycle
			for (i = 32'd0; i < 32'd2; i = i + 32'd1) begin
				clock = ~clock;
				#20;
			end
		end

		// Check if exit flag has been set and the player's location has been reset
		if (at_end == 1'b1 && player_x == 8'd0 && player_y == 8'd0) begin
			$display("Test passed!");
		end else begin
			$display("Test failed!");
		end

		// Check exit flag gets reset
		$display("Checking exit flag gets reset...");

		// Wait one clock cycle
		for (i = 32'd0; i < 32'd2; i = i + 32'd1) begin
			clock = ~clock;
			#20;
		end

		if (at_end == 1'b0) begin
			$display("Test passed!");
		end else begin
			$display("Test failed!");
		end

	end
	
endmodule





