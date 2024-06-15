
// Module to initialize the S memory with data 00 -> FF

module s_memory_init(

	input wire clk,
	input wire reset, // not used
	input wire start,
	
	output wire finish,	
	output wire [7:0] address,
	output wire [7:0] data
);

localparam IDLE   = 2'b00;
localparam START  = 2'b01;
localparam FINISH = 2'b10;
localparam count_total = 8'hFF;

// Assign relevant outputs
assign finish = state[1]; 
assign address = count;
assign data = count;

logic [7:0] count;
logic [1:0] state;

always_ff @ (posedge clk) begin

	case (state)
		IDLE: begin
			if (start) begin
				count <= 8'b0;
				state <= START;
			end else begin
				state <= IDLE;
			end
		end
		
		// Iterate through s memory filling data with it's address
		START: begin
			if (count == count_total) begin
				count <= 8'b0;
				state <= FINISH;
			end else begin
				count <= count + 8'b1;
				state <= START;
			end
		end
		
		FINISH: state <= IDLE;
		
		default: begin
			state <= IDLE;
		end
	endcase
	
end

endmodule
	

