module decoder_core_control(
	input clk,
//	input [23:0] secret_key,
//	output [23:0] shuffle_secret_key,
	
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
	//output [23:4] successful_secret_key   // Might need to pass back the secret key unless we keep track globally 
	
	);

logic [10:0] state;

// states, add count to state once finalized
localparam IDLE            = 11'b0000_00000_00;
localparam START_INIT      = 11'b0001_00001_01;
localparam WAIT_INIT       = 11'b0010_00000_01;
localparam START_SHUFFLE   = 11'b0011_00010_10;
localparam WAIT_SHUFFLE    = 11'b0100_00000_10;
localparam START_DECODE    = 11'b0101_00100_11;
localparam WAIT_DECODE     = 11'b0110_00000_11;
localparam DECODE_FAIL     = 11'b0111_01000_00;
localparam DECODE_FINISH   = 11'b1000_10000_00;

assign init_start = state[2];
assign shuffle_start = state[3];
assign decode_start = state[4];
assign finish = state[6];
assign s_source = state[1:0];
assign failed = decode_failed;

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
		
		DECODE_FAIL: 
		
			state <= IDLE;
		
		DECODE_FINISH: state <= IDLE;
		
		
		default: state <= IDLE;
		
		
	
	
	endcase
endmodule
