
`timescale 1ns/1ns //Defines the time scale

module LFSR_11_Bit_tb;
	
	// This register acts as a local variable for the input to the DUT.
	//reg 	[11:0]	input_tests;
	wire 	[10:0] 	output_tests;

	reg 		pass; // Variable to store whether the test has passed or failed
	integer 	iterations;

	reg 		clock;
	reg 		reset;

	// Instantiate Device Under Test (DUT) from Quad_nA_AND_B verilog file.
	LFSR_11_Bit DUT (
		// Port map - connection between master ports and signals/registers   
		.seed	(11'b10101010101	),
		.clock	(clock 			),
		.reset	(reset			),
		.out 	(output_tests		)	
	);
	

	// The code in this begin-end block will run only once	 
	initial begin             
		$display("\tTime,\tOutputs");   
		$monitor("%d,\t%d",$time,output_tests); // Monitor the output of the LFSR
		
		// Reset the device to set the initial value to the seed
		reset = 1'b1;
		clock = 1'b1;

		# 20; // Delay

		// Test begins here
		for (iterations = 12'd0; iterations <= 12'd24096; iterations = iterations + 12'd1) begin // Run through every output once
			reset = 1'b0; // Make sure device is not reset
			clock = ~clock; // Invert clock signal

			#20; // Delay
		end

	end
	
endmodule




