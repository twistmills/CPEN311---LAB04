// Module to execute part 2 of decryption algorithm
module shuffle_memory_with_key(

input clk,
input start,
output finish,

input [23:0] secret_key,

output [7:0] shuffle_data,
output [7:0] shuffle_address,
output shuffle_wren,
input [7:0] shuffle_q,

output [7:0] secret_key_byte_debug
);

assign secret_key_byte_debug = secret_key_byte;

// Algotithm 
// j = 0
// for i = 0 to 255 {
// j = (j + s[i] + secret_key[i mod keylength] ) //keylength is 3 in our impl.
// swap values of s[i] and s[j]
// }


// Internal values used in algorithm
logic [7:0] j;
logic [7:0] i;
logic [7:0] f;
logic [7:0] s_at_i;
logic [7:0] s_at_j;
logic [6:0] state;
logic [6:0] last_state;
logic [7:0] secret_key_byte;

localparam max_address = 8'hFF;
localparam key_length = 8'h03;


// State declaration
localparam IDLE            = 7'b0000_00;
localparam INIT            = 7'b0001_00;
localparam SET_I_ADDR      = 7'b0010_00;
localparam READ_S_AT_I     = 7'b0011_00;
localparam MATH            = 7'b0100_00;
localparam SET_J_ADDR      = 7'b0101_00;
localparam READ_S_AT_J     = 7'b0110_00;
localparam WRITE_I         = 7'b0111_01;
localparam SET_I_WR_ADDR   = 7'b1000_00;
localparam WRITE_J         = 7'b1001_01;
localparam INCREMENT_CHECK = 7'b1010_00;
localparam FINISH          = 7'b1011_10;
localparam WAIT_STATE      = 7'b1100_00;

assign shuffle_wren = state[0];
assign finish = state[1];

// Compute byte of secret key to be used
always_ff @(*) begin
	case(i % key_length)
		2'b00: secret_key_byte = secret_key[23:16];
		2'b01: secret_key_byte = secret_key[15:8];
		2'b10: secret_key_byte = secret_key[7:0];
		default: secret_key_byte = 8'b0;
	endcase
end


// Execute part 2 of algorithm
always @ (posedge clk) begin

	last_state <= state;
 case(state)
	
	IDLE: if (start) state <= INIT;
	
	INIT: begin
		i <= 8'b0;
		j <= 8'b0;
		state <= SET_I_ADDR;
	end
	
	// Wait state provides an extra clock period before reading data from memory
	WAIT_STATE: begin
		if (last_state == SET_I_ADDR) state <= READ_S_AT_I;
		else if (last_state == SET_J_ADDR) state <= READ_S_AT_J;
		else state <= IDLE;
	end
	
	SET_I_ADDR: begin
		shuffle_address <= i;
		state <= WAIT_STATE;
	end
	
	READ_S_AT_I: begin;
		s_at_i <= shuffle_q;
		state <= MATH;
	end
	
	MATH: begin
		j <= (j + s_at_i + secret_key_byte);
		state <= SET_J_ADDR;
	end
	
	SET_J_ADDR: begin
		shuffle_address <= j;
		state <= WAIT_STATE;
	end
	
	READ_S_AT_J: begin
		s_at_j <= shuffle_q;
		state <= WRITE_I;
		shuffle_data <= s_at_i;
	end
	
	WRITE_I: begin		
		state <= SET_I_WR_ADDR;
	end
	
	SET_I_WR_ADDR: begin
		shuffle_address <= i;
		state <= WRITE_J;
		shuffle_data <= s_at_j;
	end
	
	WRITE_J: begin
				state <= INCREMENT_CHECK;
	end
	
	INCREMENT_CHECK: begin
		if (i == max_address)
			state <= FINISH;
		else begin
			i <= i + 8'h01;
			state <= SET_I_ADDR;
		end
	end
	
	FINISH: state <= IDLE;
	
	default: state <= IDLE;

 endcase
end

endmodule