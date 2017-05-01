module LFSR_11_Bit (
	input 	[10:0]	seed, // Number to initialise the PRNG
	input		clock, // Clock signal
	input		reset, // Reset signal
	output	[10:0]	out // Current state of the PRNG
);

	reg	[10:0]	buffer;
	reg		bit_one;
	
	// Every clock cycle or when a reset occurs
	always @(posedge clock or posedge reset)
	begin
		// If the module is reset, set the current value of the buffer to be the seed
		if (reset == 1'b1) begin
			buffer = seed;
		// Every clock cycle, shift the bits left by one and set bit 1 to be the XOR of bits 11 and 7 (pre-shifted)
		end else begin
			bit_one = buffer[10] ^ buffer[6];
			buffer = buffer << 1;
			buffer[0] = bit_one;
		end
	end
	
	// Set the output to be identical to the buffer
	assign out = buffer;
	
endmodule
