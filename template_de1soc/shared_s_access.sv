module shared_s_access #(

#(
parameter N = 32,
parameter M = 8

)

(
output reg [(N-1):0] output_arguments,
output start_target_state_machine,
input target_state_machine_finished,
input sm_clk,
input logic start_request_a,
input logic start_request_b,
output logic finish_a,
output logic finish_b,
output logic reset_start_request_a,
output logic reset_start_request_b,
input [(N-1):0] input_arguments_a,
input [(N-1):0] input_arguments_b,
output reg [(M-1):0] received_data_a,
output reg [(M-1):0] received_data_b,
input reset,
input [M-1:0] in_received_data
);

logic select_b_output_parameters;
logic register_data_a_enable;
logic register_data_b_enable;
logic [10:0] state;

// Setup states 
localparam check_start_a     = 11'b0000_0000000;
localparam give_start_a      = 11'b0001_1100000;
localparam wait_for_finish_a = 11'b0010_0000000;
localparam register_data_a   = 11'b0011_0000010;
localparam give_finish_a     = 11'b0100_0001000;
localparam check_start_b     = 11'b1000_0000000;
localparam give_start_b      = 11'b1001_1010000;
localparam wait_for_finish_b = 11'b1010_0000000;
localparam register_data_b   = 11'b1011_0000001;
localparam give_finish_b      = 11'b1100_0000100;

// Set output assignments 
always_comb
begin
	select_b_output_parameters = state[10];
	start_target_state_machine = state[6];
	reset_start_request_a      = state[5];
	reset_start_request_b      = state[4];
	finish_a                   = state[3];
	finish_b                   = state[2];
	register_data_a_enable     = state[1];
	register_data_b_enable     = state[0];
	
	
	
	if (select_b_output_parameters) 
		output_arguments = input_arguments_b;
	else
		output_arguments = input_arguments_a;

end

// Store data on rising edge of enable 'a' data signal
always_ff @ (posedge register_data_a_enable)

	received_data_a <= in_received_data;

// Store data on rising edge of enable 'b' data signal
always_ff @ (posedge register_data_b_enable)
	
	received_data_b <= in_received_data;


// State machine as per handout diagram	
always_ff @ (posedge sm_clk or posedge reset)

	if (reset)
		state <= check_start_a;
	else

		case(state) 
		
		
			//States for interacting with module 'a'
			check_start_a: state <= (start_request_a) ? give_start_a : check_start_b;
			
			give_start_a: state <= wait_for_finish_a;
			
			wait_for_finish_a: if (target_state_machine_finished) state <= register_data_a;
	
			register_data_a:state <= give_finish_a;
			
			give_finish_a: state <= check_start_b;
			
			//States for interacting with module 'b'
			check_start_b: state <= (start_request_b) ? give_start_b : check_start_a;
			
			give_start_b: state <= wait_for_finish_b;
			
			wait_for_finish_b: if (target_state_machine_finished) state <= register_data_b;
			
			register_data_b: state <= give_finish_b;
			
			give_finish_b: state <= check_start_a;
		
			default: state <= check_start_a;
		
		
		endcase
	

endmodule

