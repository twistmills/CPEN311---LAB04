// Module controls the flow of the decryption algortihm from initialization, shuffle and decode

module decoder_core_control(
	input clk,
	
	output [1:0] s_source,
	
	input start,
	output finish,
	output failed,
	
	output init_start,
	input init_finish,
	
	output shuffle_start,
	input shuffle_finish,
	
	output decode_start,
	input decode_finish,
	input decode_failed
	
	);

logic [10:0] state;

// State declarations
localparam IDLE            = 11'b0000_00000_00;
localparam START_INIT      = 11'b0001_00001_01;
localparam WAIT_INIT       = 11'b0010_00000_01;
localparam START_SHUFFLE   = 11'b0011_00010_10;
localparam WAIT_SHUFFLE    = 11'b0100_00000_10;
localparam START_DECODE    = 11'b0101_00100_11;
localparam WAIT_DECODE     = 11'b0110_00000_11;
localparam DECODE_FAIL     = 11'b0111_01000_00;
localparam DECODE_FINISH   = 11'b1000_10000_00;

// State dependant outputs
assign init_start = state[2];
assign shuffle_start = state[3];
assign decode_start = state[4];
assign finish = state[6];
assign s_source = state[1:0];
assign failed = state[5];

// Flow control of decode algorithm
always_ff @ (posedge clk)

	case(state)
		IDLE: if (start) state <= START_INIT;
		
		START_INIT: state <= WAIT_INIT;
		
		WAIT_INIT: begin
		 if (init_finish) state <= START_SHUFFLE;
		 else state <= WAIT_INIT;
		
		end
		
		START_SHUFFLE: state <= WAIT_SHUFFLE;
		
		WAIT_SHUFFLE: begin
			if (shuffle_finish) state <= START_DECODE;
			else state <= WAIT_SHUFFLE;
		end
			
		START_DECODE: state <= WAIT_DECODE;
		
		WAIT_DECODE: begin
			if (decode_finish) state <= DECODE_FINISH;
			else if (decode_failed) state <= DECODE_FAIL;
			else state <= WAIT_DECODE;
		
		end
		
		DECODE_FAIL: begin
			if (start) state <= START_INIT;
			else state <= DECODE_FAIL;
		
		end
		
		DECODE_FINISH: begin
			if (start) state <= IDLE;
			else state <= DECODE_FINISH;
		
		end
		default: state <= IDLE;
		
		
	
	
	endcase
endmodule
