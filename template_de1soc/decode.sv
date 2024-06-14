module decode(
	input clk,
	input fail_sensitive,
	
	input start,
	output finish,
	output fail,
	
	output [7:0] decode_data,
	output decode_wren,
	output [7:0] decode_address,
	input [7:0] decode_q,
	
	output [7:0] encrypted_addr,
	input [7:0] encrypted_data,
	
	output [7:0] decrypted_addr,
	output [7:0] decrypted_data
	

);

parameter message_length = 5'd32;
parameter message_length_true = 5'd31;

logic [7:0] i, j, f, k, s_at_i, s_at_j, s_at_f, decrypted_byte;
logic [7:0] state, last_state;
/*
i = 0, j=0
for k = 0 to message_length-1 { // message_length is 32 in our implementation
i = i+1
j = j+s[i]
swap values of s[i] and s[j]
f = s[ (s[i]+s[j]) ]
decrypted_output[k] = f xor encrypted_input[k] // 8 bit wide XOR function
}
*/

localparam IDLE                 = 8'b00000_000;
localparam INIT                 = 8'b00001_000;
localparam INC_I                = 8'b10100_000;
localparam SET_I_ADDR           = 8'b00010_000;
localparam WAIT_STATE           = 8'b00011_000;
localparam READ_I_VALUE         = 8'b00100_000;
localparam SET_J_VALUE          = 8'b00101_000;
localparam SET_J_ADDR           = 8'b00110_000;
localparam READ_J_VALUE         = 8'b00111_000;
localparam WRITE_I_AT_J         = 8'b01000_001;
localparam SET_I_WR_ADDR        = 8'b01001_000;
localparam WRITE_J_AT_I         = 8'b01010_001;
localparam CALC_F_ADDR          = 8'b01011_000;
localparam SET_F_ADDR           = 8'b01100_000;
localparam READ_F_VALUE         = 8'b01101_000;
localparam DECRYPT_BYTE         = 8'b01110_000;
localparam CHECK_RESULT         = 8'b01111_000;
localparam WRITE_DECRYPTED_BYTE = 8'b10000_000;
localparam INC_K_CHECK          = 8'b10001_000;
localparam FINISH               = 8'b10010_010;
localparam FAIL                 = 8'b10011_100;
//localparam WAIT_STATE_2         = 8'b11111_000;


assign fail = state[2];
assign finish = state[1];
assign decode_wren = state[0];


always_ff @ (posedge clk) begin
	last_state <= state;
	case(state)
	
		IDLE: begin
			if (start) state <= INIT;
			else state <= IDLE;
		end
			
		INIT: begin
			i <= 8'b0;
			j <= 8'b0;
			k <= 8'b0;
			s_at_i <= 8'b0;
			s_at_j <= 8'b0; 
			s_at_f <= 8'b0;
			//f <= 8'b0;
			state <= INC_I;
		
		end
		
		INC_I: begin
			encrypted_addr <= k;
			decrypted_addr <= k;
			i <= i + 8'h01;
			state <= SET_I_ADDR;
		end
		
		
		SET_I_ADDR: begin
			decode_address <= i;
			state <= WAIT_STATE;
		end
			
		WAIT_STATE: begin
			if (last_state == SET_I_ADDR) state <= READ_I_VALUE;
			else if (last_state == SET_J_ADDR) state <= READ_J_VALUE;
			else if (last_state == SET_I_WR_ADDR) state <= WRITE_J_AT_I;
			else if (last_state == SET_F_ADDR) state <= READ_F_VALUE;
			else if (last_state == WRITE_DECRYPTED_BYTE) state <= INC_K_CHECK;
			else if (last_state == READ_I_VALUE) state <= SET_J_VALUE;
			else state <= IDLE;
		end
		
		READ_I_VALUE: begin
			s_at_i <= decode_q;
			state <= SET_J_VALUE;
		end
		
		SET_J_VALUE: begin
			j <= j + s_at_i;
			state <= SET_J_ADDR;
		
		end
			
		
		SET_J_ADDR: begin
			decode_address <= j;
			state <= WAIT_STATE;
		
		end
		
		//WAIT_STATE_
		
		READ_J_VALUE: begin
			s_at_j <= decode_q;
			decode_data <= s_at_i;
			state <= WRITE_I_AT_J;
		
		end
		
		WRITE_I_AT_J: begin
			
			state <= SET_I_WR_ADDR;
		
		end
		
		SET_I_WR_ADDR: begin
			decode_address <= i;
			state <= WAIT_STATE;
			decode_data <= s_at_j;
		
		end
		
		//WAIT_STATE
		
		WRITE_J_AT_I: begin
			
			state <= CALC_F_ADDR;
		
		end
		
		CALC_F_ADDR: begin
			f <= (s_at_i + s_at_j);
			state <= SET_F_ADDR;
		
		end
		
		SET_F_ADDR: begin
			decode_address <= f;
			state <= WAIT_STATE;
		
		end
		
		//waitstate:
		
		READ_F_VALUE: begin
			s_at_f <= decode_q;
			state <= DECRYPT_BYTE;
		
		end
		
		DECRYPT_BYTE: begin
			decrypted_byte <= (s_at_f ^ encrypted_data);
			state <= CHECK_RESULT;
		
		end
		
		CHECK_RESULT: begin
			if (fail_sensitive) begin
				if (decrypted_byte == 8'd32 | ((decrypted_byte >= 8'd97) & (decrypted_byte <= 8'd122)))
					state <= WRITE_DECRYPTED_BYTE;
				else 
					state <= FAIL;
			end
			
			else state <= WRITE_DECRYPTED_BYTE;
			
		end
		
		WRITE_DECRYPTED_BYTE: begin
			decrypted_data <= decrypted_byte;
			state <= WAIT_STATE;
		
		end
			
		
		INC_K_CHECK: begin
			if (k == message_length_true) state <= FINISH;
			else begin
				k <= k + 8'h01;
				state <= INC_I;
			end
		
		end
		
		FINISH: state <= IDLE;
		
		FAIL: state <= IDLE;
		

	
	endcase



end



endmodule