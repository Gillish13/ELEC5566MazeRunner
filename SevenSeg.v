module SevenSeg (
	input[3:0] hex_in,
	output[6:0] seg_out
);

reg[6:0] seg;

always @(hex_in)
begin
	case(hex_in)
		4'h0: begin
			seg = 7'b0111111;
		end
		4'h1: begin
			seg = 7'b0000110;
		end
		4'h2: begin
			seg = 7'b1011011;
		end
		4'h3: begin
			seg = 7'b1001111;
		end
		4'h4: begin
			seg = 7'b1100110;
		end
		4'h5: begin
			seg = 7'b1101101;
		end
		4'h6: begin
			seg = 7'b1111101;
		end
		4'h7: begin
			seg = 7'b0000111;
		end
		4'h8: begin
			seg = 7'b1111111;
		end
		4'h9: begin
			seg = 7'b1100111;
		end
		default: begin
			seg = 7'b1001001;
		end
	endcase
end


assign seg_out = ~seg;

endmodule