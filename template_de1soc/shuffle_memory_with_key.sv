module shuffle_memory_with_key(


input clk,
input start,
output finish,

input [23:0] secret_key,

output [7:0] shuffle_data,
output [7:0] shuffle_address,
output shuffle_wren,
input [7:0] shuffle_q


);


// Algotithm 
// j = 0
// for i = 0 to 255 {
// j = (j + s[i] + secret_key[i mod keylength] ) //keylength is 3 in our impl.
// swap values of s[i] and s[j]
// }

logic [7:0] j;
logic [7:0] i;
logic [7:0] f;
logic [7:0] s_at_i;
logic [7:0] s_at_j;
logic [4:0] state;
logic [7:0] secret_key_byte;

localparam max_address = 8'hFF;
localparam key_length = 3;

localparam IDLE            = 5'b0000_0;
localparam INIT            = 5'b0001_0;
localparam READ_S_AT_I     = 5'b0010_0;
localparam MATH            = 5'b0011_0;
localparam READ_S_AT_J     = 5'b0100_0;
localparam WRITE_I         = 5'b0101_1;
localparam WRITE_J         = 5'b0110_1;
localparam INCREMENT_CHECK = 5'b0111_0;
localparam FINISH          = 5'b1000_0;

assign shuffle_wren = state[0];
assign finish = state[4];

always_ff @(posedge clk) begin
	case(i % key_length)
		2'b00: secret_key_byte = secret_key[23:16];
		2'b01: secret_key_byte = secret_key[15:8];
		2'b10: secret_key_byte = secret_key[7:0];
		default: secret_key_byte = 8'b0;
	endcase
end
	
always @ (posedge clk)

 case(state)
	
	IDLE: if (start) state <= INIT;
	
	INIT: begin
		i <= 8'b0;
		j <= 8'b0;
		state <= READ_S_AT_I;
	end
	
	READ_S_AT_I: begin;
		shuffle_address <= i;
		s_at_i <= shuffle_q;
		state <= MATH;
	end
	
	MATH: begin
		//j <= j + shuffle_q + secret_key[(current_address % key_length)]
		j <= (j + s_at_i + secret_key_byte);
		shuffle_address <= j;
		state <= READ_S_AT_J;
	end
	
	READ_S_AT_J: begin
		s_at_j <= shuffle_q;
		state <= WRITE_I;
	end
	
	WRITE_I: begin
	   //shuffle_address <= j already set
		shuffle_data <= s_at_i;
		state <= WRITE_J;
	end
	WRITE_J: begin
		shuffle_address <= i;
		shuffle_data <= s_at_j;
		//shuffle_data <= 8'h69;
		state <= INCREMENT_CHECK;
	end
	
	INCREMENT_CHECK: begin
		if (i == max_address)
			state <= FINISH;
		else begin
			i <= i + 8'h01;
			state <= READ_S_AT_I;
		end
	end
	
	FINISH: state <= IDLE;
	
	default: state <= IDLE;

 endcase


endmodule