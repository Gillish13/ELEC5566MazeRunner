
`timescale 1ns/1ns //Defines the time scale

module Timer_tb;
	
	reg 			clock;
	reg 			reset;
	wire 	[5:0] 	sec_out;
	wire 	[5:0] 	min_out;
	wire			timer_end;

	integer 		i;

	// Instantiate Device Under Test (DUT).
	Timer # (
		.MINS	(1),
		.SECS	(0),
		.CLK_F	(5)		// CLK_F set to 5 to reduce simulation time
	) DUT (
		// Port map - connection between master ports and signals/registers   
		.clock		(clock		),
		.reset		(reset		),
		.sec_out	(sec_out	),
		.min_out	(min_out	),
		.timer_end	(timer_end	)	
	);
	

	// The code in this begin-end block will run only once	 
	initial begin             
		$display("Starting timer");   

		reset = 1'b1;
		clock = 1'b1;

		# 20;

		// Test begins here
		for (i = 32'd0; i <= 32'hFFFFFFFF; i = i + 32'd1) begin
			reset = 1'b0;
			clock = ~clock;
			#20;

			if (timer_end == 1'b1) begin
				$display("Timer ended");
				break;
			end
		end
	end
	
endmodule





