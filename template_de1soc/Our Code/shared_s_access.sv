module shared_s_access

# (
parameter M = 8
)

(
input [1:0] source,

// S Memory ports
output [(M-1):0] s_address,
output [(M-1):0]  s_data,
output logic s_wren,
input [(M-1):0] s_q,

// Interaction with init module
input [(M-1):0] init_address, 
input [(M-1):0] init_data,

// Interaction with shuffle module
input [(M-1):0] shuffle_address, shuffle_data,
input shuffle_wren,
output [(M-1):0] shuffle_q,

// Interaction with the decode module
input [(M-1):0] decode_address,
input [(M-1):0] decode_data,
input decode_wren,
output [(M-1):0] decode_q // May not need

);


// Setup states 
localparam INIT     = 2'b01;
localparam SHUFFLE  = 2'b10;
localparam DECODE   = 2'b11;

// Set output assignments
assign decode_q  = s_q;
assign shuffle_q = s_q;

// Control which section of decryption core has assess to s memory dependant on state of decoder_core_control
always @(*)
begin
	
	case(source)
		INIT: begin
			
			// initialization only write to memory and never needs to read data
			s_data    = init_data;
			s_address = init_address;
			s_wren    = 1'b1;
			
		end
		
		// Shuffle reads and writes to s memory
		SHUFFLE: begin
			s_data    = shuffle_data;
			s_address = shuffle_address;
			s_wren    = shuffle_wren;
			
		end
		
		// Decode reads and writes to s memory
		DECODE: begin
			s_data    = decode_data;
			s_address = decode_address;
			s_wren    = decode_wren;
			
			
		end
		
		// If value invalid, which it should never be, disable writing to s memory
		default: begin
			s_data    = 8'b0;
			s_address = 8'b0;
			s_wren    = 1'b0;
		end
	endcase
end

endmodule

