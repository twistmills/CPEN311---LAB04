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

logic [23:0] secret_key;
//assign secret_key = secret_key_count;

logic clk;
assign clk = CLOCK_50;

logic reset_n;
assign reset_n = SW[3];


SevenSegmentDisplayDecoder sseg0(.ssOut(HEX0), .nIn(secret_key[3:0]));
SevenSegmentDisplayDecoder sseg1(.ssOut(HEX1), .nIn(secret_key[7:4]));
SevenSegmentDisplayDecoder sseg2(.ssOut(HEX2), .nIn(secret_key[11:8]));
SevenSegmentDisplayDecoder sseg3(.ssOut(HEX3), .nIn(secret_key[15:12]));
SevenSegmentDisplayDecoder sseg4(.ssOut(HEX4), .nIn(secret_key[19:16]));
SevenSegmentDisplayDecoder sseg5(.ssOut(HEX5), .nIn(secret_key[23:20]));

logic fail_crack_00, fail_crack_01, fail_crack_02, fail_crack_03;
logic finish_crack_00, finish_crack_01, finish_crack_02, finish_crack_03;
logic start_crack = 1'b1;


rc4_decryptor CORE00(
	.clk(clk),
	.start(start_crack),
	.finish(finish_crack_00),
	.fail(fail_crack_00),
	.secret_key(secret_key),
	);

rc4_decryptor_01 CORE01(
	.clk(clk),
	.start(start_crack),
	.finish(finish_crack_01),
	.fail(fail_crack_01),
	.secret_key((secret_key+24'd1)),
	);
	
rc4_decryptor_02 CORE02(
	.clk(clk),
	.start(start_crack),
	.finish(finish_crack_02),
	.fail(fail_crack_02),
	.secret_key((secret_key+24'd2)),
	);
	
rc4_decryptor_03 CORE03(
	.clk(clk),
	.start(start_crack),
	.finish(finish_crack_03),
	.fail(fail_crack_03),
	.secret_key((secret_key+24'd3)),
	);


	
logic keep_going;

	
initial begin 
	secret_key <= 24'h000000;
	state <= IDLE;
end

logic [6:0] state;

parameter max_key = 24'h3FFFFF;

localparam IDLE          = 7'b000_0000;
localparam START_CRACK   = 7'b001_0001;
localparam WAIT_CRACK    = 7'b010_1000;
localparam INCREMENT_KEY = 7'b011_0000;
localparam FINISH        = 7'b100_0010;
localparam NO_KEY_FOUND  = 7'b101_0100;

assign start_crack = state[0];
assign LEDR[0] = state[1]; // found key
assign LEDR[9] = state[2]; // no key found

logic fail_flag_00,fail_flag_01,fail_flag_02,fail_flag_03; 

always_ff @ (posedge clk) begin
	
	case(state)
		IDLE: begin
			if (!KEY[0]) state <= START_CRACK;
			else state <= IDLE;
		
		end
		
		START_CRACK: state <= WAIT_CRACK;
		
		WAIT_CRACK: begin

			if (finish_crack_00) begin
				state <= FINISH;
				secret_key <= secret_key + 24'd0;
			end
			
			if (finish_crack_01) begin
				state <= FINISH;
				secret_key <= secret_key + 24'd1;
			end
			if (finish_crack_02) begin
				state <= FINISH;
				secret_key <= secret_key + 24'd2;
			end
		   if (finish_crack_03) begin
				state <= FINISH;
				secret_key <= secret_key + 24'd3;
			end
			
			
			if(fail_crack_00) fail_flag_00 <= 1'b1;
			if(fail_crack_01) fail_flag_01 <= 1'b1;
			if(fail_crack_02) fail_flag_02 <= 1'b1;
		   if(fail_crack_03) fail_flag_03 <= 1'b1;
			
			else if (fail_flag_00 && fail_flag_01 && fail_flag_02 && fail_flag_03) begin
				state <= INCREMENT_KEY;
				fail_flag_00 <= 1'b0;
				fail_flag_01 <= 1'b0;
				fail_flag_02 <= 1'b0;
				fail_flag_03 <= 1'b0;
			end
			
			else state <= WAIT_CRACK;
		
		end
		INCREMENT_KEY: begin
			if (secret_key < max_key) begin
				secret_key <= secret_key + 24'd4;
				state <= START_CRACK;
			end
			else state <= NO_KEY_FOUND;
		end
		
		FINISH: state <= FINISH;
		
		NO_KEY_FOUND: state <= NO_KEY_FOUND;
		
		default: state <= IDLE;

	endcase

end


endmodule





////logic [23:0] secret_key = 24'h000249;
//logic [23:0] secret_key;
//
//logic clk;
//assign clk = CLOCK_50;
//
//logic reset_n;
//assign reset_n = SW[3];
//
//logic [6:0]ssOut;
//logic [3:0]nIn;
//
//SevenSegmentDisplayDecoder sseg0(.ssOut(HEX0), .nIn(secret_key[3:0]));
//SevenSegmentDisplayDecoder sseg1(.ssOut(HEX1), .nIn(secret_key[7:4]));
//SevenSegmentDisplayDecoder sseg2(.ssOut(HEX2), .nIn(secret_key[11:8]));
//SevenSegmentDisplayDecoder sseg3(.ssOut(HEX3), .nIn(secret_key[15:12]));
//SevenSegmentDisplayDecoder sseg4(.ssOut(HEX4), .nIn(secret_key[19:16]));
//SevenSegmentDisplayDecoder sseg5(.ssOut(HEX5), .nIn(secret_key[23:20]));
//	
//logic [7:0] s_q;
//logic [7:0] s_address;
//logic [7:0] s_data;
//logic s_wren;
//	
//s_memory s_memory_inst(
//	.clock(clk),
//	.address(s_address),
//	.data(s_data),
//	.wren(s_wren),
//	.q(s_q));
//
//	
//logic [7:0] d_address;
//logic [7:0] d_data;
//	
//decrypted_memory d_memory_inst(
//	.clock(clk),
//	.address(d_address),
//	.data(d_data),
//	.wren(1'b1),
//	.q());
//	
//logic [7:0] e_address;
//logic [7:0] e_q;
//	
//encrypted_memory e_memory_inst(
//	.clock(clk),
//	.address(e_address),
//	.data(),
//	.wren(1'b0),
//	.q(e_q));
//
//logic init_start;
//logic init_finish;
//logic [7:0] init_address;
//logic [7:0] init_data;
//	
//s_memory_init s_mem_init_inst(
//	.clk(clk),
//	.start(init_start),
//	.reset(1'b0),
//	.finish(init_finish),
//	.address(init_address),
//	.data(init_data));
//	
//logic shuffle_start;
//logic shuffle_finish;
//logic [7:0] shuffle_data;
//logic [7:0] shuffle_address;
//logic [7:0] shuffle_q;
//logic shuffle_wren;
//logic [23:0] shuffle_secret_key;
//	
//shuffle_memory_with_key shuffle_mem_inst(
//	.clk(clk),
//	.start(init_finish),
//	.finish(shuffle_finish),
//	.secret_key(secret_key),
//	.shuffle_data(shuffle_data),
//	.shuffle_address(shuffle_address),
//	.shuffle_wren(shuffle_wren),
//	.shuffle_q(shuffle_q)
//);
//
//// decode module will go here
//logic decode_start;
//logic decode_finish;
//logic decode_fail;
//logic fail_sensitive;
//logic [7:0] decode_data;
//logic [7:0] decode_address;
//logic [7:0] decode_q;
//logic decode_wren;
//
//decode decode_inst(
//	.clk(clk),
//	.start(decode_start),
//	.finish(decode_finish),
//	.fail(decode_fail),
//	.fail_sensitive(1'b1),
//	.decode_data(decode_data),
//	.decode_wren(decode_wren),
//	.decode_address(decode_address),
//	.decode_q(decode_q),
//	.encrypted_addr(e_address),
//	.encrypted_data(e_q),
//	.decrypted_addr(d_address),
//	.decrypted_data(d_data)
//);
//
//
//
//
//
//logic [1:0] s_source;
//
//shared_s_access shared_access_inst(
//	.source(s_source),
//	.s_address(s_address),
//	.s_data(s_data),
//	.s_wren(s_wren),
//	.s_q(s_q),
//	.init_address(init_address),
//	.init_data(init_data),
//	.shuffle_address(shuffle_address),
//	.shuffle_data(shuffle_data),
//	.shuffle_wren(shuffle_wren),
//	.shuffle_q(shuffle_q),
//	.decode_address(decode_address),
//	.decode_q(decode_q),
//	.decode_wren(decode_wren),
//	.decode_data(decode_data));
//
//logic core_start;
//logic core_finish;
//logic core_fail;	
//	
//decoder_core_control decoder_core_inst(
//	.clk(clk),
//	//.secret_key(secret_key),
//	//.shuffle_secret_key(shuffle_secret_key),
//	.s_source(s_source),
//	.start(1'b1),
//	.finish(core_finish),
//	.failed(core_fail),
//	.init_start(init_start),
//	.init_finish(init_finish),
//	.shuffle_start(shuffle_start),
//	.shuffle_finish(shuffle_finish),
//	.decode_start(decode_start),
//	.decode_finish(decode_finish),
//	.decode_failed(decode_fail)
//	//output [23:4] successful_secret_key   // Might need to pass back the secret key unless we keep track globally 
//	
//	);




