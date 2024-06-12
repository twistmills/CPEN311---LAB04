
// Module to initialize the S memory with data 00 -> FF

module s_memory_init(
	clk,
	reset,
	address,
	data,
	write_enable;
	start,
	finish);
	
	
	
input wire clk;
input wire reset;
input wire state;

output wire finish, write_enable;
output [7:0] address, data;

localparam IDLE  = 2'b01;
localparam START = 2'b10;

localparam count_total = 8'hFF;

assign finish <= state[0]
assign address <= count;
assign data <= count;
assign write_enable <= state[1];

logic [7:0] count;
logic [1:0] state;

always_ff @ (posedge clk or posedge reset)

	if (reset)
		state <= IDLE;
		count <= 0;
		
	else begin
		
		case(state)
			
			IDLE: begin
				if (start) begin
					count <= 0;
					state <= START;
				end
				else state <= IDLE;
			end
			
			START: begin
				if (count == count_total) begin
					count <= 0;
					state <= IDLE;
				end
				else begin
					count <= count + 8'h01;
					state <= START;
				end
			
			end
			default: state <= IDLE;
			
		endcase
	end
	
endmodule
	

