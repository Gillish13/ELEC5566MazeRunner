
`timescale 1ns/1ns //Defines the time scale

module Maze_Game_tb;
	
	reg  				clock;
	reg  				reset;
	reg 	[10	:0]		maze_address;
	reg 	[3	:0]		player_direction;
	reg 				timer_end;

	wire 				maze_address_data;
	wire 				gen_end;
	wire	[7	:0]		player_x;
	wire	[7	:0]		player_y;
	wire	[7	:0]		mazes_complete;

	integer 			i, j;

	// Instantiate Device Under Test (DUT).
	Maze_Game #
	(
		.WIDTH	(5),
		.HEIGHT	(2)
	) DUT (
		// Port map - connection between master ports and signals/registers   
		.timer_end 		(timer_end			),
		.clock			(clock 				),
		.reset			(reset				),
		.maze_address 		(maze_address 		),
		.maze_address_data	(maze_address_data	),
		.player_direction	(player_direction	),
		.player_x		(player_x			),
		.player_y		(player_y			),
		.gen_end		(gen_end			),
		.mazes_complete		(mazes_complete		)	
	);

	// The code in this begin-end block will run only once	 
	initial begin             
		// Generate maze
		$display("Begining generation..."); 

		// Reset  
		maze_address = 11'd0;
		reset = 1'b1;
		clock = 1'b1;
		timer_end = 1'b0;
		player_direction = 4'b0000;

		# 20;

		// Tests begin here
		for (i = 32'd0; i < 32'hFFFFFFFF; i = i + 32'd1) begin

			reset = 1'b0;
			clock = ~clock;
			#20;
			// End loop when generation is finished
			if (gen_end == 1'b1) begin
				break;
			end
		end

		$display("Generation finished. Time taken: %d",$time);  
		$display("Checking if player moving to the exit creates a new map...");

		// Move player toward the exit (4 right, 1 down)
		// Move right four times
		for (j = 32'd0; j < 32'd4; j = j + 32'd1) begin
			player_direction = 4'b0100; // Move right

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

		// Move down
		player_direction = 4'b0010; // Move down

		// Wait a few clock cycles
		for (i = 32'd0; i < 32'd8; i = i + 32'd1) begin
			clock = ~clock;
			#20;
		end

		player_direction = 4'b0000;

		// Wait three clock cycles
		for (i = 32'd0; i < 32'd6; i = i + 32'd1) begin
			clock = ~clock;
			#20;
		end

		if (gen_end == 1'b0) begin
			$display("Test passed!");
		end else begin
			$display("Test failed!");
		end

		// Wait for maze to regenerate
		for (i = 32'd0; i < 32'hFFFFFFFF; i = i + 32'd1) begin
		// Test begins here
			clock = ~clock;
			#20;
			// End loop when generation is finished
			if (gen_end == 1'b1) begin
				break;
			end
		end

		$display("Checking if the timer ending stops the player moving...");
		timer_end = 1'b1;

		// Wait one clock cycle
		for (i = 32'd0; i < 32'd2; i = i + 32'd1) begin
			clock = ~clock;
			#20;
		end

		player_direction = 4'b0100; // Move right

		// Wait a few clock cycles
		for (i = 32'd0; i < 32'd10; i = i + 32'd1) begin
			clock = ~clock;
			#20;
		end

		player_direction = 4'b0000;

		if (player_x == 8'd0 && player_y == 8'd0) begin
			$display("Test passed!");
		end else begin
			$display("Test failed!");
		end
	end
endmodule
