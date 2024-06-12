module shared_s_access

# (
parameter M = 8
)

(
input clk, 
input [1:0] source,

// S Memory ports
output [(M-1):0] s_address,
output [(M-1):0]  s_data,
output logic s_wren,
input [(M-1):0] s_q,

// Interaction with init module
input [(M-1):0] init_address, 
input [(M-1):0] init_data,
//input init_wren;
//output init_q; // May not need

// Interaction with shuffle module
input shuffle_start,
input [(M-1):0] shuffle_address, shuffle_data,
input shuffle_wren,
output shuffle_q,

// Interaction with the decode module
input [(M-1):0] decode_address,
//input [(M-1):0] decode_data;
//input decode_wren;
output decode_q // May not need

);


// Setup states 
localparam INIT     = 2'b01;
localparam SHUFFLE  = 2'b10;
localparam DECODE   = 2'b11;

// Set output assignments 
always_comb
begin
	
	case(source)
		INIT: begin
			
			s_data    = init_data;
			s_address = init_address;
			s_wren    = 1'b1;
			
		end
		SHUFFLE: begin
			s_data    = shuffle_data;
			s_address = shuffle_address;
			s_wren    = shuffle_wren;
			shuffle_q = s_q;
			
		end
		DECODE: begin
			s_address = decode_address;
			s_wren    = 1'b0;
			decode_q  = s_q;
			
			
		end
		default: begin
			s_data    = 8'b0;
			s_address = 8'b0;
			s_wren    = 1'b0;
		end
	endcase
end

endmodule

