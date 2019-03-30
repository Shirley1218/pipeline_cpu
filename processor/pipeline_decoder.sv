
// This is the control module for cpu
// It takes four 5-bit opcode and decode correspondingly 
module pipeline_decoder(
	input clk,
	input reset,
	//input opcode
	input [4:0] opcode [1:4], 
	input hold_in_decode_state,
	
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
		if(hold_in_decode_state) begin
			PCSrc = 1'b1;
			pc_enable = 1'b0;
		end else if ( opcode[2][3] == 1'b1 ) begin
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

		if(opcode[4] == 5'b11111) begin
			RegWrite = 1'b0;
			RegDst = 1'b0;//dont care
			WBSrc = 3'b000;

		end else begin
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

	end 

endmodule

module dependency_helper(
	input clk,
	input reset,
	input logic [15:0]	inst_ipipe	[1:4],
	input [4:0] opcode [1:4], 
	output hold_in_decode_state
	);
	logic [2:0] rx_wr;
	logic [2:0] ry_wr;
	logic [2:0] rx_rd; 
	logic [2:0] ry_rd; 

	logic [2:0] valid;

	assign rx_wr = inst_ipipe[3][7:5];
	assign ry_wr = inst_ipipe[3][10:8];
	assign rx_rd = inst_ipipe[2][7:5];
	assign ry_rd = inst_ipipe[2][10:8];

	typedef enum { n_z, rf, mem_ry} resource;

	logic [2:0] reading_src;//each bit represent need for each resource
	logic [2:0] writing_dst;
	logic [1:0] reading_reg; // reading_reg[1] for rx ,reading_reg[0] for ry

	always_comb begin
		case (opcode[3])
			5'b00000 :  writing_dst = 3'b010;
			5'b00001 :  writing_dst = 3'b010;
			5'b00010 :  writing_dst = 3'b010;

			5'b00011 :  writing_dst = 3'b100; //cmp
			5'b00100 :  writing_dst = 3'b010;
			5'b00101 :  writing_dst = 3'b001;	//st

			5'b10000 :  writing_dst = 3'b010;		//mvi
			5'b10001 :  writing_dst = 3'b110;
			5'b10010 :  writing_dst = 3'b110;
			5'b10011 :  writing_dst = 3'b100;	//cmpi
			5'b10110 :  writing_dst = 3'b010;	//mvhi

			default : writing_dst = 3'b000;
		endcase

	end

	always_comb begin
		reading_reg = 2'b00;
		case (opcode[2])
			5'b00000 :  begin reading_src = 3'b010; reading_reg = 2'b01; end
			5'b00001 :  begin reading_src = 3'b010; reading_reg = 2'b11; end
			5'b00010 :  begin reading_src = 3'b010; reading_reg = 1'b11; end

			5'b00011 :  begin reading_src = 3'b010; reading_reg = 1'b11; end//cmp
			5'b00100 :  reading_src = 3'b001;
			5'b00101 :  begin reading_src = 3'b010;	reading_reg = 2'b10; end//st

			5'b10000 :  reading_src = 3'b000;		//mvi
			5'b10001 :  begin reading_src = 3'b010;	reading_reg = 2'b10; end
			5'b10010 :  begin reading_src = 3'b010;	reading_reg = 2'b10; end
			5'b10011 :  begin reading_src = 3'b010;	reading_reg = 2'b10; end	//cmpi
			5'b10110 :  reading_src = 3'b000;	//mvhi

			default : reading_src = 3'b000;
		endcase

	end

	logic rx_valid, ry_valid;

	always_comb begin
		valid[0] = ~(writing_dst[0] & reading_src[0]);

		rx_valid = reading_reg[1] ? (rx_wr != rx_rd) : 1'b1;
		ry_valid = reading_reg[0] ? (rx_wr != ry_rd) : 1'b1;

		if(writing_dst[1] & reading_src[1]) begin
			if(inst_ipipe[4] == 16'd0)begin 
				valid [1] = 1'b1;
			end else valid[1] = rx_valid & ry_valid;
		end
		else valid[1] = 1'b1;

		if(writing_dst[2] & reading_src[2]) valid[2] = ry_wr != ry_rd;
		else valid[2] = 1'b1;
	end

	logic hold;
	assign hold = (~(valid[0] & valid[1] &valid[2]));

	reg [1:0] stalled;
	always_ff @(posedge clk or posedge reset) begin 
		if(reset) begin
			stalled <= 2'b00;
		end else begin
			stalled[0] <= hold;
			stalled[1] <= stalled[0];
		end
	end

	assign hold_in_decode_state = hold | stalled[0];

endmodule
