module immN_ext(
	input 			imm11, // 1 if input is imm1
	input [15:0] 	in,
	output [15:0] 	out
);
	logic [15:0] imm_8_ext;
	logic [15:0] imm_11_ext;
	sign_ext imm8_(
		.in(in[15:8]),
		.out(imm_8_ext)
	);

	sign_ext #(11) imm11_ (
		.in(in[15:5]),
		.out(imm_11_ext)
	);

	assign out = imm11 ? imm_11_ext : imm_8_ext;
endmodule


module sign_ext #(parameter IN_SIZE = 8, parameter OUT_SIZE = 16)
(
	input [IN_SIZE-1:0] in,
	output [OUT_SIZE-1:0] out
);
	assign out[IN_SIZE-1:0] = in;
	assign out[OUT_SIZE-1:IN_SIZE] = {32{in[IN_SIZE-1]}};
	
endmodule
