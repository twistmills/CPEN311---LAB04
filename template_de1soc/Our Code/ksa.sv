module ksa (

input [9:0] SW,
input CLOCK_50,
input [3:0] KEY,
output [9:0] LEDR,
output [6:0] HEX0,
output [6:0] HEX1,
output [6:0] HEX2,
output [6:0] HEX3,
output [6:0] HEX4,
output [6:0] HEX5

);

// Change numer of cores and file location here
parameter file_location = "./secret_messages/msg_4_for_task3/message.mif";
parameter num_cores = 4;

parameter max_key = 24'h4FFFFF;

// Internal values used during execution
logic [23:0] secret_key = 24'h000000;
logic [23:0] final_secret_key;
logic [5:0] state = IDLE;
logic [(num_cores-1):0] fail_crack;
logic [(num_cores-1):0] finish_crack;
logic start_crack;
logic [7:0] cracked_core = 8'b11111111;  // Set as default value 

logic clk;
assign clk = CLOCK_50;

// Not used
logic reset_n;
assign reset_n = SW[3];

logic [7:0] LED;
assign LEDR[7:0] = LED;

assign start_crack = state[0];


assign LEDR[9] = state[1]; // crack finished
assign LEDR[8] = state[2]; // crack failed, no key found


// Dynamically instatiate RC4 decryption cores
genvar i;
generate
  for (i = 0; i < num_cores; i++) begin : rc4_crack_gen
		rc4_decryptor #(
			 .core_num(i),
			 .file_location(file_location)
		) rc4_crack_inst (
			 .clk(clk),
			 .start(start_crack),
			 .finish(finish_crack[i]),
			 .fail(fail_crack[i]),
			 .secret_key(secret_key + i)
		);
  end
endgenerate


localparam IDLE          = 6'b000_000;
localparam START_CRACK   = 6'b001_001;
localparam WAIT_CRACK    = 6'b010_000;
localparam INCREMENT_KEY = 6'b011_000;
localparam FINISH        = 6'b100_010;
localparam NO_KEY_FOUND  = 6'b101_100;


// Set LEDs once crack has finished
always_comb begin
	if (state[1])
		LED = cracked_core;
	else
		LED = 0;
end

// State machine controlling increment of attempted secret_key
always_ff @ (posedge clk) begin
	
	case(state)
	
		// Wait until KEY0 pressed to start crack
		IDLE: begin
			if (!KEY[0]) state <= START_CRACK;
			else state <= IDLE;
		
		end
		
		START_CRACK: state <= WAIT_CRACK;
		
		WAIT_CRACK: begin
			if (|finish_crack) state <= FINISH;
			else if (&fail_crack) state <= INCREMENT_KEY;
			else state <= WAIT_CRACK;
		
		end
		
		INCREMENT_KEY: begin
			if (secret_key < max_key) begin
				secret_key <= secret_key + num_cores;
				state <= START_CRACK;
			end
			else state <= NO_KEY_FOUND;
		end
		
		// Once crack finished, stay in this state
		FINISH: begin
			secret_key <= final_secret_key;
			state <= FINISH;
		end
		
		// If no valid key found, stay in this state
		NO_KEY_FOUND: begin
			state <= NO_KEY_FOUND;
		end
		
		default: state <= IDLE;

	endcase
	
end	


	// Identify the core that finished and compute the final secret key
always_ff @(posedge clk) begin
	  if (state == FINISH & cracked_core > num_cores) begin 
			for (int i = 0; i < num_cores; i++) begin
				 if (finish_crack[i]) begin
					  cracked_core <= i;
					  final_secret_key <= secret_key + i;
					  break;
				 end
			end
	  end
 end


// SevenSeg interaction module
SevenSegmentDisplayDecoder sseg0(.ssOut(HEX0), .nIn(secret_key[3:0]));
SevenSegmentDisplayDecoder sseg1(.ssOut(HEX1), .nIn(secret_key[7:4]));
SevenSegmentDisplayDecoder sseg2(.ssOut(HEX2), .nIn(secret_key[11:8]));
SevenSegmentDisplayDecoder sseg3(.ssOut(HEX3), .nIn(secret_key[15:12]));
SevenSegmentDisplayDecoder sseg4(.ssOut(HEX4), .nIn(secret_key[19:16]));
SevenSegmentDisplayDecoder sseg5(.ssOut(HEX5), .nIn(secret_key[23:20]));
 
 
 
 
 

endmodule







