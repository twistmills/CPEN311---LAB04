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
logic [3:0] state;
logic [7:0] secret_key_byte;

localparam max_address = 8'hFF;
localparam key_length = 3;

localparam IDLE            = 0000_00;
localparam INIT            = 0001_00;
localparam READ_S_AT_I     = 0010_00;
localparam MATH            = 0011_00;
localparam READ_S_AT_J     = 0100_00;
localparam WRITE_I         = 0101_10;
localparam WRITE_J         = 0110_10;
localparam INCREMENT_COUNT = 0111_00;
localparam CHECK_COUNT     = 1000_00;
localparam FINISH          = 1001_01;

assign shuffle_wren = state[1];
assign finish = state[0];

always_comb
	case(i % key_length)
		2'b00: secret_key_byte = secret_key[23:16];
		2'b01: secret_key_byte = secret_key[15:8];
		2'b10: secret_key_byte = secret_key[7:0];
	endcase

always @ (posedge clk)

 case(state)
	
	IDLE: if (start) state <= READ_S_AT_I;
	
	INIT: begin
		i <= 8'b0;
		state <= READ_S_AT_I;
	end
	
	READ_S_AT_I: begin;
		shuffle_address <= i;
		s_at_i <= shuffle_q;
	end
	
	MATH: begin
		//j <= j + shuffle_q + secret_key[(current_address % key_length)]
		j <= (j + s_at_i + secret_key_byte);
	end
	
	READ_S_AT_J: begin
		shuffle_address <= j;
		s_at_j <= shuffle_q;
	end
	
	WRITE_I: begin
	   //shuffle_address <= j already set
		shuffle_data <= s_at_j;
	end
	WRITE_J: begin
		shuffle_address <= i;
		shuffle_data <= s_at_i;
		
	end
	
	INCREMENT_COUNT: i <= i + 8'h01;
	
	CHECK_COUNT: begin
		if (i == max_address)
			state <= FINISH;
		else state <= READ_S_AT_I;
	end
	
	FINISH: state <= IDLE;

 endcase


endmodule