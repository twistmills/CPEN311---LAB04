// Testbench for s_memory_init


module s_memory_init_tb(
	input clk,
	input reset,
	input start,
	
	output reg [7:0] address,
	output reg [7:0] data,
	
	output write_enable,
	output finish
); 
	
	
s_memory_init MUT(
	.clk(clk),
	.reset(reset),
	.address(address),
	.data(data),
	.write_enable(write_enable),
	.start(start),
	.finish(sinish)
); 

endmodule 
