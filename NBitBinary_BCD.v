module NBitBinary_BCD #(
	parameter 	WIDTH = 8,
	parameter 	DIGITS = 3
)(
	input			[WIDTH-1:0]			binary,
	output		[(DIGITS*4)-1:0]	bcd
);

reg		[(DIGITS*4)-1:0]	bcd_value;
integer 							i, j;

always @(binary) begin
	bcd_value = 64'h0;
	
	for (i = 0; i < WIDTH; i = i + 1) begin
		bcd_value[0] = binary[WIDTH-(i+1)];
		
		if (i != WIDTH - 1) begin
			for (j = 0; j < DIGITS; j = j + 1) begin
				if (bcd_value[(j*4) +: 4] > 4'h4) begin
					bcd_value[(j*4) +: 4] = bcd_value[(j*4) +: 4] + 4'h3;
				end
			end
			
			bcd_value = bcd_value << 1;
			
		end
	end
end

assign bcd = bcd_value;

endmodule
