module LFSR_8_Bit (
	input 	[7:0]	seed,
	input				clock,
	input				reset,
	output	[7:0]	out
);

	reg	[7:0]	buffer;
	reg			bit_one;
	
	always @(posedge clock)
	begin
		if (reset == 1'b0) begin
			buffer = seed;
		end else begin
			bit_one = ((buffer[7] ^ buffer[5]) ^ buffer[4]) ^ buffer[3];
			buffer = buffer << 1;
			buffer[0] = bit_one;
		end
	end

	assign out = buffer;
	
endmodule