
`timescale 1ns/1ns //Defines the time scale

module Maze_Maker_tb;
	
	// This register acts as a local variable for the input to the DUT.
	reg  				clock;
	reg  				reset;
	reg 		[10:0]		maze_address;
	wire 				maze_address_data;
	wire 				gen_end;

	integer 			i;
	reg 		[1199:0] 	maze_output;

	// Instantiate Device Under Test (DUT).
	Maze_Maker #
	(
		.WIDTH	(30),
		.HEIGHT	(40)
	) DUT (
		// Port map - connection between master ports and signals/registers   
		.seed			(11'b10101010101	),
		.gen_start 		(1'b0 			),
		.clock			(clock 			),
		.reset			(reset			),
		.maze_address 		(maze_address 		),
		.maze_input_address 	(11'b00000000000	),
		.maze_address_data	(maze_address_data	),
		.gen_end		(gen_end		)	
	);
	

	// The code in this begin-end block will run only once	 
	initial begin             
		// Generate maze
		$display("Begining generation..."); 

		// Reset  
		maze_address = 11'd0;
		reset = 1'b1;
		clock = 1'b1;

		# 20;

		for (i = 32'd0; i < 32'hFFFFFFFF; i = i + 32'd1) begin
		// Test begins here

			reset = 1'b0;
			clock = ~clock;
			#20;
			// End loop when generation is finished
			if (gen_end == 1'b1) begin
				break;
			end
		end


		$display("Generation finished. Time taken: %d\nAcquiring maze data...", $time);  

		// Acquire data from the maze
		maze_output = 1200'd0;

		// Iterate through the RAM addresses containing the maze data
		for (maze_address = 11'd0; maze_address < 11'd1200; maze_address = maze_address + 11'd1) begin
			// Run a few clock cycles to make sure we get the correct data from the RAM
			for (i = 32'd0; i < 32'd8; i = i + 32'd1) begin
				clock = ~clock;
				#20;
			end

			maze_output[maze_address] = maze_address_data; 
		end

		$display("%b", maze_output);
		$display("Acquired maze data");
	end
	
endmodule





