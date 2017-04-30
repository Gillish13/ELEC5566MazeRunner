module Timer # (
	// Time for the timer to count down from
	parameter MINS = 1,
	parameter SECS = 0,
	
	parameter CLK_F = 50000000 // 50 MHz
) (
	input 			clock, // Clock signal
	input 			reset, // Reset signal
	output			timer_end, // Set high when the timer finishes counting down
	output	[5:0]	sec_out, // Value of the current number of seconds remaining
	output	[5:0]	min_out // Value of the current number of minutes remaining
);
	
	integer mins, secs, phase_increment;
	
	reg timer_end_reg;
	
	always @ (posedge clock or posedge reset) begin
		if (reset == 1'b1) begin
			timer_end_reg = 1'b0;
			phase_increment = 0;
			mins = MINS;
			secs = SECS;
		end else begin
		
			if (phase_increment >= CLK_F) begin
				phase_increment = 0;
				
				if (secs == 0 && mins > 0) begin
					secs = 59;
					mins = mins - 1;
				end else if (secs != 0) begin
					secs = secs - 1;
				end
				
			end else begin
				phase_increment = phase_increment + 1;
				
				if (secs == 0 && mins == 0) begin
					mins = 0;
					secs = 0;
					timer_end_reg = 1'b1;
				end
			end
		end
	end
	
	assign timer_end = timer_end_reg;
	assign sec_out = secs;
	assign min_out = mins;
	
endmodule
