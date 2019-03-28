
// This is the control module for cpu
// It takes four 5-bit opcode and decode correspondingly 
module pipeline_decoder(
	input clk,
	input reset,
	//input opcode
	input [4:0] opcode [1:4], 
	
	// control signals for each stages 

	// stage 1 Fetch 
	output logic PCSrc, //0 for pc+2, 1 br
	output logic pc_enable,
	output logic [1:0]br_sel, // 0 = always br(no condition) , 1 = branch if Z == 1, 2 = branch if N == 1
	// stage 2 RegFile Read


	// Stage 3 Execute
	output logic NZ, 		// should update NZ
	output logic ALUOp,		// 0 for add, 1 for sub
	output logic BrSrc,		// 0 for rd1, 1 for pc + offset  
	output logic BSrc, 		// ALU data_b source selector. 0 for Ry, 1 for imm_ext
	output logic ExtSel, 	// 0 for imm8, 1 for imm11

	output logic MemWrite, // write enable to mem
	output logic MemRead,

	// Stage 4 RegFile Write
	output logic RegWrite,	// write enable to regitor files
	output logic RegDst,	// 0 for Rx, 1 for R7
	output logic [2:0] WBSrc // Write Back Source selector
							//000 for mem read reg, 001 for alu output, 010 for [Ry], 011 for imm8, 100 for {imm8,[rx][7:0]}
	
);

	// stage 1 Fetch opcode[2]
	always_comb begin
		// branch instruction disable pc_enable for part 1
		if ( opcode[2][3] == 1'b1 ) begin
			pc_enable = 1'b0;
			PCSrc = 1'b1;
	 	end else begin
		 	pc_enable = 1'b1;
			PCSrc = 1'b0;
		end 
	end 

	// stage 2 RegFile Read opcode[2]
	

	// Stage 3 Execute opcode[3]
	always_comb begin

		// NZ
		if ( !opcode[3][3] & !opcode[3][2] & (opcode[3][1] | opcode[3][0] ) ) NZ = 1'b1;
		else NZ = 1'b0;

		// ALUOp
		if ( !opcode[3][3] & !opcode[3][1] & opcode[3][0] ) ALUOp = 1'b0;
		else ALUOp = 1'b1;

		// BSrc
		// opcode bit 4 is high, alu data_b input = imm8 ext
		if ( opcode[3][4] ) BSrc = 1'b1;
		else BSrc = 1'b0;

		// ExtSel
		// opcode bit 3 is high, use imm11
		if ( opcode[3][3] ) ExtSel = 1'b1;
		else ExtSel = 1'b0;

		// BrSrc
		if ( opcode[3][4] ) BrSrc = 1'b0;
		else BrSrc = 1'b1;

		
	end 

	// Stage 4 RegFile Write opcode[4]
	always_comb begin

		// RegWrite
		if ( !opcode[4][3] & !(opcode[4][1] & opcode[4][0]) ) RegWrite = 1'b1;
	    else RegWrite = 1'b0;

		// RegWrite
		if ( opcode[4][3] ) RegDst = 1'b1;
	    else RegDst = 1'b0;

		// WBSrc
		if ( opcode[4] == 5'b00000 ) WBSrc = 3'b010;
	    else if ( opcode[4] == 5'b00100 ) WBSrc = 3'b000;
		else if ( opcode[4] == 5'b10000 ) WBSrc = 3'b011;
		else if ( opcode[4] == 5'b10110 ) WBSrc = 3'b100;
		else WBSrc = 3'b001;

	end 

endmodule