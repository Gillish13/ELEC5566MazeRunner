module SevenSegTimer # (
	parameter MINS = 1,
	parameter SECS = 0,
	
	parameter CLK_F = 50000000 // 50 MHz
) (
	input 				clock,
	input 				reset,
	output				timer_end,
	output	[6:0]		segout_0,
	output	[6:0]		segout_1,
	output	[6:0]		segout_2,
	output	[6:0]		segout_3
);
	
	wire	[5:0]	sec_wire;
	wire	[5:0]	min_wire;
	
	wire	[7:0]	sec_segs;
	wire	[7:0]	min_segs;

	Timer # (
		.MINS		(MINS		),
		.SECS		(SECS		),
		.CLK_F	(CLK_F	)
	) timer (
		.clock		(clock		),
		.reset		(reset		),
		.timer_end	(timer_end	),
		.sec_out		(sec_wire	),
		.min_out		(min_wire	)
	);

	
	NBitBinary_BCD # (
		.WIDTH	(6),
		.DIGITS	(2)
	) sec_bcd (
		.binary	(sec_wire	),
		.bcd		(sec_segs	)
	);
	
	NBitBinary_BCD # (
		.WIDTH	(6),
		.DIGITS	(2)
	) min_bcd (
		.binary	(min_wire	),
		.bcd		(min_segs	)
	);
	
	SevenSeg	seg0	(
		.hex_in	(sec_segs	[3:0]	),
		.seg_out	(segout_0			)
	);
	
	SevenSeg	seg1	(
		.hex_in	(sec_segs	[7:4]	),
		.seg_out	(segout_1			)
	);
	
	SevenSeg	seg2	(
		.hex_in	(min_segs	[3:0]	),
		.seg_out	(segout_2			)
	);
	
	SevenSeg	seg3	(
		.hex_in	(min_segs	[7:4]	),
		.seg_out	(segout_3			)
	);
	
endmodule
