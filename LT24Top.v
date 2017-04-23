module LT24Top (
    //
    // Global Clock/Reset
    // - Clock
    input              clock,
    // - Global Reset
    input              globalReset,
	 
	 input gen_start_sw,
	 
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
	//reg [2:0]	next_state;
	
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

localparam height = 40;
localparam width = 30;

//reg [(width * height)-1:0] maze_wire_reg;
//wire [(width * height)-1:0] maze_wire;
wire gen_start;
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
	.gen_start  			(gen_start				),
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

reg increment_cursor;

// X Counter
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        xAddr <= 8'b0;
    end else if (pixelReady && increment_cursor == 1'b1) begin
        if (xAddr < (WIDTH-1)) begin
            xAddr <= xAddr + 8'd1;
        end else begin
            xAddr <= 8'b0;
        end
    end
end

// Y Counter
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        yAddr <= 9'b0;
    end else if (pixelReady && (xAddr == (WIDTH-1)) && increment_cursor == 1'b1) begin
        if (yAddr < (HEIGHT-1)) begin
            yAddr <= yAddr + 9'd1;
        end else begin
            yAddr <= 9'b0;
        end
    end
end

// Maze tracker counter + registers
//reg increment_maze_tracker;

/*
always @(posedge clock or posedge resetApp) begin
	if (resetApp) begin
		maze_tracker <= 11'd0;
	end else if (increment_maze_tracker == 1'b1) begin
		maze_tracker <= (xAddr / 8) + (width * (yAddr/ 8));
	end
end
*/

always @(posedge clock) begin
	case(state)
		// Do nothing
		A : begin
			//increment_maze_tracker <= 1'b0;
			increment_cursor <= 1'b0;
			maze_tracker <= 0;

			if (resetApp == 1'b1 && gen_end == 1'b1) begin
				state <= C;
			end else begin
				state <= A;
			end
		end
		
		// Request data
		B : begin
			if (xAddr < WIDTH - 1 && yAddr < HEIGHT - 1) begin
				maze_tracker <= ((xAddr + 1) / 8) + (width * ((yAddr + 1) / 8));
			end else if (yAddr < HEIGHT - 1) begin
				maze_tracker <= (width * ((yAddr + 1) / 8));
			end else begin
				maze_tracker <= 0;
			end
			
			state <= E;
		end
		
		// Wait to recieve data
		E : begin
			state <= F;
		end
		
		F : begin
			state <= G;
		end
		
		G : begin
			state <= C;
		end
		
		// Wait to recieve data + begin to increment cursor
		C : begin
			increment_cursor <= 1'b1;
			state <= D;
		end
		
		// Draw pixel if ready + stop incrementing the cursor + begin requesting maze data
		D : begin
			
			if (pixelReady == 1'b1) begin
				increment_cursor <= 1'b0;
				//increment_maze_tracker <= 1'b1;
				
				// Draw pixel
				if (xAddr < (WIDTH - 1) && yAddr < (HEIGHT - 1)) begin
				

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
					
					
					state <= B;
				end else begin
					state <= B;
				end
			end else begin
				// Keep in this state until pixel is ready to be drawn
				state <= D;
			end
		end
		
	endcase
end

assign reset = ~globalReset;
assign gen_start = ~gen_start_sw;

endmodule
