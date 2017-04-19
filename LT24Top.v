module LT24Top (
    //
    // Global Clock/Reset
    // - Clock
    input              clock,
    // - Global Reset
    input              globalReset,
    // - Application Reset - for debug
    output             resetApp,
    //
    // LT24 Interface
    output             LT24_WRn,
    output             LT24_RDn,
    output             LT24_CSn,
    output             LT24_RS,
    output             LT24_RESETn,
    output [     15:0] LT24_D,
    output             LT24_LCD_ON,
	 
	 output [9:0]		led_bus
);

// Flags
reg startChar;	// sets the initial character
reg charAlternator;	// alternates between characters

reg  [7: 0] xCharOrigin		; // register to store character x origin
reg  [8: 0] yCharOrigin		; // register to store character y origin
reg  [3: 0] charXCord	; // stores the character X coordinate
reg	 [3: 0] charYCord	; // stores the character Y coordinate

// Flags

reg  [ 7:0] xAddr      ;
reg  [ 8:0] yAddr      ;
reg  [15:0] pixelData  ;
wire        pixelReady ;

localparam WIDTH = 240;
localparam HEIGHT = 320;

// Maze making variables

localparam height = 10;
localparam width = 30;

//reg [(width * height)-1:0] maze_wire_reg;
wire [(width * height)-1:0] maze_wire;
reg gen_start;
reg reset;
wire gen_end;
reg gen_end_reg;
reg [10:0] maze_tracker;

//assign maze_wire_reg = maze_wire



Maze_Maker # (
	.WIDTH  (width  ),
	.HEIGHT (height )
) maze_maker(
	.gen_start  (1'b0),
	.seed			(11'b10101010101),
	.reset		(globalReset),
	.clock		(clock),
	.maze 		(maze_wire),
	.gen_end		(gen_end)
);



LT24Display #(
    .WIDTH       (240        ),
    .HEIGHT      (320        ),
    .CLOCK_FREQ  (50000000   )
) Display (
    .clock       (clock      ),
    .globalReset (globalReset),
    .resetApp    (resetApp   ),
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (1'b1 		  ),
    .pixelReady  (pixelReady ),
	 .pixelRawMode(1'b0       ),
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    .LT24_WRn    (LT24_WRn   ),
    .LT24_RDn    (LT24_RDn   ),
    .LT24_CSn    (LT24_CSn   ),
    .LT24_RS     (LT24_RS    ),
    .LT24_RESETn (LT24_RESETn),
    .LT24_D      (LT24_D     ),
    .LT24_LCD_ON (LT24_LCD_ON)
);





// cursor counter
always @ (posedge clock or posedge globalReset) begin

	
	
	if (globalReset) begin
		// set cursor at the origin
		yAddr <= 9'b0;	// set y coordinate to zero
		xAddr <= 8'b0;	// set x coordinate to zero
		
		// reset characters
		xCharOrigin <= 5'b0;
		yCharOrigin <= 6'b0;
		
		//
		charXCord <= 4'b0;
		charYCord <= 4'b0;
		
		// reset flags
		startChar <= 1'b0;
		
		// start the generation of the maze
		// gen_start <= 1'b1;
		//reset <= 1'b1;
		maze_tracker <= 11'b0;
	end 
	// ensure cursor is within bounds and LCD is ready to accept data 
	else if (pixelReady && (xAddr < (WIDTH)) && (yAddr < (HEIGHT)) && gen_end == 1'b1 && maze_tracker <= (width * height)) begin
		
		if (startChar == 0) begin
				startChar = 1'b1;
				// read the first value in the maze array
				if (maze_wire[maze_tracker] == 0) begin
					// set color to green
					pixelData[15:11] <= 5'b00000;	// red pixel data
					pixelData[10: 5] <= 6'b111111;	// green pixel data
					pixelData[4:0] <= 5'b00000;	// set pixel data to zero
				end else begin
					// set the pixel data to black
					pixelData[15:11] <= 5'b0;	// red pixel data
					pixelData[10: 5] <= 6'b0;	// green pixel data
					pixelData[4:0] <= 5'b0;	// set pixel data to zero
			
				end
				maze_tracker <= maze_tracker + 11'd1;
		
		end

		if (charXCord == 8 && charYCord == 8) begin
					
			if (xAddr < (WIDTH-8)) begin
				
				// move character width
				xCharOrigin <= xCharOrigin + 5'd8;
				
				// reset character x coordinate
				charXCord <= 4'b0;
				// reset character y coordinate
				charYCord <= 4'b0;
				
			end else begin
				// move character width
				xCharOrigin <= 5'd0;
				yCharOrigin <= yCharOrigin + 6'd8;
					
				if (yAddr < (HEIGHT-8)) begin
					yAddr <= yCharOrigin + 6'd8;
					xAddr <= 5'd0;
				end

				// reset character x coordinate
				charXCord <= 4'b0;
				// reset character y coordinate
				charYCord <= 4'b0;
				
			end

			// reset x address
			// alternate pixel colors between black and white
			if (maze_wire[maze_tracker] == 0) begin

				// set color to green
				pixelData[15:11] <= 5'b00000;	// red pixel data
				pixelData[10: 5] <= 6'b111111;	// green pixel data
				pixelData[4:0] <= 5'b00000;	// set pixel data to zero

			end else begin
				// set color to black
				pixelData[15:11] <= 5'b0;	// red pixel data
				pixelData[10: 5] <= 6'b0;	// green pixel data
				pixelData[4:0] <= 5'b0;	// set pixel data to zero
			end
			
			maze_tracker <= maze_tracker + 11'd1;
			
			if (xAddr < (WIDTH-8)) begin
				xAddr <= xCharOrigin + 5'd8;
				yAddr <= yCharOrigin;
			end 
				 
		end else if (charXCord == 8) begin
				xAddr <= xCharOrigin;		// place x coordinate cursor at x origin of character
			
				// reset character x coordinate to origin
				charXCord <= 4'b0;
				yAddr <= charYCord + yCharOrigin;
				charYCord <= charYCord + 4'b1;
		end else begin
				if (xAddr < (WIDTH)) begin
					xAddr <= charXCord + xCharOrigin;
					charXCord <= charXCord + 4'b1;
				end
		end
			
	end else if (pixelReady && (xAddr == (WIDTH-1))) begin

	end
	
	
end


assign led_bus = maze_wire[(width*height)-1:(width*height)-11];

endmodule
