
// Module to initialize the S memory with data 00 -> FF

module s_memory_init(

	input wire clk,
	input wire reset,
	input wire start,
	
	output wire finish,	
	output wire [7:0] address,
	output wire [7:0] data
);

localparam IDLE  = 2'b01;
localparam START = 2'b10;
localparam count_total = 8'hFF;

// modify finish??
assign finish = state[0]; 
assign address = count;
assign data = count;

logic [7:0] count;
logic [1:0] state;

always_ff @ (posedge clk or posedge reset) begin
	if (reset) begin
		state <= IDLE;
		count <= 8'b0;
	end else begin
		case (state)
			IDLE: begin
				if (start) begin
					count <= 8'b0;
					state <= START;
				end else begin
					state <= IDLE;
				end
			end
			
			START: begin
				if (count == count_total) begin
					count <= 8'b0;
					state <= IDLE;
				end else begin
					count <= count + 8'b1;
					state <= START;
				end
			end
			
			default: begin
				state <= IDLE;
			end
		endcase
	end
end

endmodule
	

