
// Module to initialize the S memory with data 00 -> FF

module s_memory_init(

	input wire clk,
	input wire reset,
	input wire start,
	
	output wire finish,	
	output wire [7:0] address,
	output wire [7:0] data
);

localparam IDLE   = 2'b00;
localparam START  = 2'b01;
localparam FINISH = 2'b10;
localparam count_total = 8'hFF;

// modify finish??
assign finish = state[1]; 
assign address = count;
assign data = count;

logic [7:0] count;
logic [1:0] state;

always_ff @ (posedge clk) begin
//	if (reset) begin
//		state <= IDLE;
//		count <= 8'b0;
//	end else begin
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
	

