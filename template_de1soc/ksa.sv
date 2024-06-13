module ksa (

input [9:0] SW,
input CLOCK_50,
input [3:0] KEY,
output [9:0] LEDR,
output [6:0] HEX0,
output [6:0] HEX1,
output [6:0] HEX2,
output [6:0] HEX3,
output [6:0] HEX4,
output [6:0] HEX5

);


logic clk;
assign clk = CLOCK_50;

logic reset_n;
assign reset_n = SW[3];

logic [6:0]ssOut;
logic [3:0]nIn;

SevenSegmentDisplayDecoder sseg(
	.ssOut(ssOut),
	.nIn(nIn));
	
logic [7:0] s_q;
logic [7:0] s_address;
logic [7:0] s_data;
logic s_wren;
	
s_memory s_memory_inst(
	.clock(clk),
	.address(s_address),
	.data(s_data),
	.wren(1'b1),
	.q(s_q));

	
s_memory_init s_mem_init_inst(
	.clk(clk),
	.start(1'b1),
	.reset(1'b0),
	.finish(init_finish),
	.address(s_address),
	.data(s_data));

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
input [(M-1):0] shuffle_address, shuffle_data,
input shuffle_wren,
output [(M-1):0] shuffle_q,

// Interaction with the decode module
input [(M-1):0] decode_address,
//input [(M-1):0] decode_data;
//input decode_wren;
output [(M-1):0] decode_q // May not need

);

shared_s_access shared_access_inst(
	.source(),
	.s_address(),
	.s_data(),
	.s_wren(),
	.s_q(),
	.init_address(),
	.init_data(),
	.shuffle_address(),
	.shuffle_data(),
	.shuffle_wren(),
	.shuffle_q(),
	.decode_address(),
	.decode_q());


endmodule

