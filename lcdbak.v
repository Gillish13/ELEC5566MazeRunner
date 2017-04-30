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

	localparam A = 3'b000;
	localparam B = 3'b001;
	localparam C = 3'b010;
	localparam D = 3'b011;
	localparam E = 3'b100;
	localparam F = 3'b101;
	localparam G = 3'b110;
	
	reg [2:0]	state;
	reg [2:0]	next_state;
	
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
//wire [(width * height)-1:0] maze_wire;
reg gen_start;
//reg reset;
wire gen_end;
reg gen_end_reg;
reg [10:0] maze_tracker;
wire maze_address_data;

wire reset;
//assign maze_wire_reg = maze_wire

Maze_Maker # (
	.WIDTH  (width  ),
	.HEIGHT (height )
) maze_maker(
	.gen_start  			(1'b0						),
	.seed						(11'b10101010101		),
	.reset					(reset					),
	.clock					(clock					),
	.maze_address 			(maze_tracker			),
	.maze_address_data	(maze_address_data	),
	.gen_end					(gen_end					)
);



LT24Display #(
    .WIDTH       (240        ),
    .HEIGHT      (320        ),
    .CLOCK_FREQ  (50000000   )
) Display (
    .clock       (clock      ),
    .globalReset (reset			),
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



// Wait to get data

always @(state or gen_end) begin
	case(state)
		// Initilize
		A : begin
			// Do initialising stuff here
			
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
			
			next_state <= C;
		end
		
		// Request data
		B : begin
			
			maze_tracker = maze_tracker + 11'd1;
			
			next_state <= C;
		end
		
		// Wait
		C : begin
			next_state <= D;
		end
		
		// Draw data
		D : begin
		
			// first confirm that the LCD is ready to receive data
			if (pixelReady && (xAddr <(WIDTH)) && (yAddr < (HEIGHT)) && maze_tracker < (width*height)) begin
			
				// check if its the first character to be drawn
				if (startChar == 0) begin
					// ensure this happens only once
					startChar <= 1'b1;
				
					if (maze_address_data == 1'b1) begin
						// Draw wall
						
						// set the pixel data to black
						pixelData[15:11] <= 5'b0;	// red pixel data
						pixelData[10: 5] <= 6'b0;	// green pixel data
						pixelData[4:0] <= 5'b0;	// set pixel data to zero
					end else begin
						// Draw floor
						
						// set color to green
						pixelData[15:11] <= 5'b00000;	// red pixel data
						pixelData[10: 5] <= 6'b111111;	// green pixel data
						pixelData[4:0] <= 5'b00000;	// set pixel data to zero
					end
					
					// increment the maze_tracker
					next_state <= B;
				end
			
				// check if the end of a character is reached
				if (charXCord == 8 && charYCord == 8) begin
				
					/**
					
					// check if this is NOT the last character on x-axis
					if (xAddr < (WIDTH-8)) begin
				
						// move character width
						xCharOrigin <= xCharOrigin + 5'd8;
						
						// reset character x coordinate
						charXCord <= 4'b0;
						// reset character y coordinate
						charYCord <= 4'b0;
						
						// increment maze_tracker
						next_state <= B;
						
					end else begin
						// move character width
						xCharOrigin <= 5'd0;
						yCharOrigin <= yCharOrigin + 6'd8;
						
						// check if this is NOT the end of the screen
						if (yAddr < (HEIGHT-8)) begin
							yAddr <= yCharOrigin + 6'd8;
							xAddr <= 5'd0;
							
							// increment mazetracker
							next_state <= B;
						end else begin
							// frame is complete
							next_state <= E;
						end
		
						// reset character x coordinate
						charXCord <= 4'b0;
						// reset character y coordinate
						charYCord <= 4'b0;
						
					end
					
					// determine the color of the character
					if (maze_address_data == 1'b1) begin
						// Draw wall
						
						// set the pixel data to black
						pixelData[15:11] <= 5'b0;	// red pixel data
						pixelData[10: 5] <= 6'b0;	// green pixel data
						pixelData[4:0] <= 5'b0;	// set pixel data to zero
					end else begin
						// Draw floor
						
						// set color to green
						pixelData[15:11] <= 5'b00000;	// red pixel data
						pixelData[10: 5] <= 6'b111111;	// green pixel data
						pixelData[4:0] <= 5'b00000;	// set pixel data to zero
					end
					
					if (xAddr < (WIDTH-8)) begin
						xAddr <= xCharOrigin + 5'd8;
						yAddr <= yCharOrigin;
					end 
					
					
					**/
					
					next_state <= E;
					
				end 
				// check is at the end of character x-axis
				else if (charXCord == 8) begin
					xAddr <= xCharOrigin;		// place x coordinate cursor at x origin of character
				
					// reset character x coordinate to origin
					charXCord <= 4'b0;
					yAddr <= charYCord + yCharOrigin;
					charYCord <= charYCord + 4'b1;
					
					//next_state <= D;
				end
				// otherwise just increment the pixels on the x-axis
				else begin
					// ensure x-address is within bounds
					if (xAddr < (WIDTH)) begin
						xAddr <= charXCord + xCharOrigin;
						charXCord <= charXCord + 4'b1;
					end	
					
					//next_state <= D;
				end
			
			end 
		end
		
		// End
		E : begin
			if (gen_end == 1'b1) begin
				next_state <= E;
			end
			else begin
				next_state <= F;
			end
		end
		
		// Wait until generation has finished
		F : begin
			if (gen_end == 1'b1) begin
				next_state <= A;
			end
			else begin
				next_state <= F;
			end
		end
		
		G : begin
			next_state <= G;
		end
		
	endcase
end

	// Change state of the state machine
	always @(posedge clock or posedge reset) begin
		if (reset) begin
			state <= F;
		end else begin
			state <= next_state;
		end
	end

assign led_bus[9] = gen_end;
assign led_bus[2:0] = state;
assign reset = ~globalReset;

endmodule
