module LT24Top (
    //
    // Global Clock/Reset
    // - Clock
    input              clock,
    // - Global Reset
    input              globalReset,
	 
	 //input gen_start_sw,
	 
	 //input		[3:0]							player_direction,
	 
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
	 
	output	[6:0]		segout_0,
	output	[6:0]		segout_1,
	output	[6:0]		segout_2,
	output	[6:0]		segout_3,
	output	[6:0]		segout_4,
	output	[6:0]		segout_5,
	
	inout ps2_clk,
	inout ps2_data
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
reg			pixelWrite ;

localparam WIDTH = 240;
localparam HEIGHT = 320;

// Maze making variables

localparam height = 40;
localparam width = 30;

//reg [(width * height)-1:0] maze_wire_reg;
//wire [(width * height)-1:0] maze_wire;
//wire gen_start;
//reg reset;
//wire gen_end;
//reg gen_end_reg;
reg [10:0] maze_tracker;
wire maze_address_data;

wire reset;
//assign maze_wire_reg = maze_wire

wire	[7:0] player_x;
wire	[7:0]	player_y;


//wire [3:0]	player_direction_neg;

wire [3:0] direction;

wire timer_end;

wire [7:0]	mazes_complete;

wire [7:0]	score_segs;

SevenSegTimer # (
	.MINS(1),
	.SECS(0),
	.CLK_F(50000000)
) timer (
	.clock(clock),
	.reset(reset),
	.timer_end(timer_end),
	.segout_0(segout_0),
	.segout_1(segout_1),
	.segout_2(segout_2),
	.segout_3(segout_3)
	
);

wire ready;
directions dir (
	.clock(clock),
	.reset(reset),
	.ps2_clk(ps2_clk),
	.ps2_data(ps2_data),
	
	.direction(direction)
 );
 
Maze_Game # (
	.WIDTH  (width  ),
	.HEIGHT (height )
) maze_game(
	//.gen_start  			(gen_start				),
	//.seed					(11'b10101010101		),
	.player_direction		(direction),
	.reset					(reset					),
	.clock					(clock					),
	.timer_end				(timer_end				),
	.maze_address 			(maze_tracker			),
	.maze_address_data	(maze_address_data	),
	.player_x				(player_x				),
	.player_y				(player_y				),
	.mazes_complete		(mazes_complete		)		
	//.gen_end					(gen_end					)
);


// Display score on seven segs
	NBitBinary_BCD # (
		.WIDTH	(8),
		.DIGITS	(2)
	) sec_bcd (
		.binary	(mazes_complete	),
		.bcd		(score_segs			)
	);

	SevenSeg	seg4	(
		.hex_in	(score_segs	[3:0]	),
		.seg_out	(segout_4			)
	);
	
	SevenSeg	seg5	(
		.hex_in	(score_segs	[7:4]	),
		.seg_out	(segout_5			)
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
    .pixelWrite  (1'b1 ),
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

wire [5:0] pixelAddress;
wire [15: 0] floor_pixelInfo;
wire [15: 0] wall_pixelInfo;
wire [15: 0] character_pixelInfo;

floor_rom floor_data(
	.clock		  (clock),
	.address		  (pixelAddress),
	.q				  (floor_pixelInfo)
);

wall_rom wall_data(
	.clock		  (clock),
	.address		  (pixelAddress),
	.q				  (wall_pixelInfo)
);

character_rom character_data(
	.clock		  (clock),
	.address		  (pixelAddress),
	.q				  (character_pixelInfo)
);

assign pixelAddress = ((xAddr % 8)+((yAddr % 8)*8));

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


always @(posedge clock) begin
	
	case(state)
		// Do nothing
		A : begin
			//increment_maze_tracker <= 1'b0;
			increment_cursor <= 1'b0;
			maze_tracker <= 0;

			if (resetApp == 1'b1) begin
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
						
					if (timer_end == 1'b0) begin
					
						if (player_x == xAddr / 8 && player_y == yAddr / 8) begin
							
							// draw character
							
							if (character_pixelInfo != 16'h07E0) begin
								
								//pixelData <= character_pixelInfo;
								
								// change character hair to blonde
								if (character_pixelInfo == 16'h0) begin
									pixelData <= 16'hFFE0;
								end else begin
									pixelData <= character_pixelInfo;
								end
								
							end else begin		// color is green
								
								// draw a floor pixel in its place
								pixelData <= wall_pixelInfo;

							end
				
						end
						
						else if (maze_address_data == 1'b1) begin
							// Draw wall
							pixelData <= floor_pixelInfo;
							
						end else begin
							
							// check if its the end of the maze
							if ( maze_tracker == ((width*height)-2)) begin
								// draw the exit (green pixels)
								pixelData <= 16'h07E0;
							end else begin
								// draw floor
								pixelData <= wall_pixelInfo;
							end
						end
						
					end 
					
					// Timer has ended - draw black screen
					else begin
						pixelData <= 16'd0;
						
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
//assign player_direction_neg = ~player_direction;
//assign gen_start = ~gen_start_sw;

endmodule
