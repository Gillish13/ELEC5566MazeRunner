module NBitBinary_BCD #(
	parameter 	WIDTH = 8, // Number of bits for the binary input
	parameter 	DIGITS = 3 // Number of seven segment digits to output to
)(
	input			[WIDTH-1:0]			binary,
	output		[(DIGITS*4)-1:0]	bcd
);

reg		[(DIGITS*4)-1:0]	bcd_value; // Register value of bcd (used in always loop)
integer 							i, j; // Used in the for loop

// When the binary input changes
always @(binary) begin
	bcd_value = 64'h0; // Reset the bcd value
	
	// Iterate through each bit using the shift and three method
	for (i = 0; i < WIDTH; i = i + 1) begin
		bcd_value[0] = binary[WIDTH-(i+1)]; // Set zeroth bit of the bcd_value to be the (WIDTH-(i+1))th bit of the binary number
		
		if (i != WIDTH - 1) begin // If not at the end of the binary number
			for (j = 0; j < DIGITS; j = j + 1) begin
				if (bcd_value[(j*4) +: 4] > 4'h4) begin // Are the four bits greater than 5
					bcd_value[(j*4) +: 4] = bcd_value[(j*4) +: 4] + 4'h3; // Add three
				end
			end
			
			bcd_value = bcd_value << 1; // Shift
			
		end
	end
end

assign bcd = bcd_value;

endmodule
