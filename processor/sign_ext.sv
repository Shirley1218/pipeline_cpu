module sign_ext #(parameter IN_SIZE = 8, parameter OUT_SIZE = 16)
(
	input [IN_SIZE-1:0] in,
	output [OUT_SIZE-1:0] out
);
	assign out[IN_SIZE-1:0] = in;
	assign out[OUT_SIZE-1:IN_SIZE] = {32{in[IN_SIZE-1]}};
	
endmodule
