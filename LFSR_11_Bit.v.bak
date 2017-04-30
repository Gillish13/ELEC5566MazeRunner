module LFSR_11_Bit (
	input 	[10:0]	seed,
	input					clock,
	input					reset,
	output	[10:0]	out
);

	reg	[10:0]	buffer;
	reg				bit_one;
	
	always @(posedge clock)
	begin
		if (reset == 1'b0) begin
			buffer = seed;
		end else begin
			bit_one = buffer[10] ^ buffer[6];
			buffer = buffer << 1;
			buffer[0] = bit_one;
		end
	end

	assign out = buffer;
	
endmodule
