module cpu
(
	input clk,
	input reset,
	
	output [15:0] o_pc_addr,
	output o_pc_rd,
	input [15:0] i_pc_rddata,
	
	output [15:0] o_ldst_addr,
	output o_ldst_rd,
	output o_ldst_wr,
	input [15:0] i_ldst_rddata,
	output [15:0] o_ldst_wrdata,
	
	output [7:0][15:0] o_tb_regs
);

localparam		PIPELINE_DEPTH = 1;
localparam		PIPELINE_STAGE = 1;
logic [15:0]	inst_ipipe				[1:PIPELINE_DEPTH];
logic [0:0]		inst_ipipe_valid		[1:PIPELINE_STAGE];
logic [4:0]		opcode_i_pipe			[1:PIPELINE_DEPTH];
logic [15:0]	Rx_ipipe				[1:PIPELINE_DEPTH];
logic [15:0]	Ry_ipipe				[1:PIPELINE_DEPTH];
logic [2:0] 	write_src_ipipe			[1:PIPELINE_DEPTH];

// execution reg
logic [15:0]	alu_out_reg;
logic			zero_reg;
logic 			neg_reg;

// implement the cpu pipeline
always_ff @(posedge clk or posedge reset) begin 
	
	if(reset) begin
		for(int i=1; i<=PIPELINE_DEPTH; i++) begin
			inst_ipipe[i] <= '0;
			Rx_ipipe[i] <= '0;
			Ry_ipipe[i] <= '0; 
		end
		for(int i=1; i<=PIPELINE_STAGE; i++) begin
			inst_ipipe_valid[i] <= '0;
		end
	end else begin

		// Pipeline Stage 1: Fetch
		inst_ipipe[1] <= i_pc_rddata;
		inst_ipipe_valid[1] <= '1;
		// for(int i=2; i<=PIPELINE_DEPTH; i++) begin
		// 	inst_ipipe[i] <= inst_ipipe[i-1];
		// end
		
		// Pipeline Stage 2: Reg File Read
		if(regfile_read_valid) inst_ipipe_valid[2] <= '1;
		else inst_ipipe_valid[2] <= '0;
		Rx_ipipe[1] <= rd1;
		Ry_ipipe[1] <= rd2;

		// Pipeline Stage 3: Execute
		if(execute_valid) inst_ipipe_valid[3] <= '1;
		else inst_ipipe_valid[3] <= '0;

		// Pipeline Stage 4: Reg File Write
		if(RegWrite) inst_ipipe_valid[4] <= '1;
		else inst_ipipe_valid[4] <= '0;


	end
end

always_comb begin
	for(int i=1; i<=PIPELINE_DEPTH; i++) begin
		opcode_i_pipe[i] = inst_ipipe[4:0][i];
	end
end

logic [2:0] ws;
assign ws = RegDst ? 3'b111 : inst_ipipe[PIPELINE_DEPTH][7:5];

logic [2:0] rs1,rs2;
//logic regfile_read_single; // = 1 if inst_ipipe[4] only use Rx, if so, read Ry from inst_ipipe[4]
							// = 0 if inst_ipipe[4] use both Rx and Ry
assign rs1 = inst_ipipe[PIPELINE_DEPTH][7:5];
assign rs2 = inst_ipipe[PIPELINE_DEPTH][10:8];
 
gprs_top gprs(

	.clk(clk),
	.reset(reset),	
	// input ports
	.rs1(rs1), // read register 1
	.rs2(rs2), // read register 2
	.ws(ws),  // write register
	.wd(wd),  // write data
	// output ports
	.rd1(rd1), // read data 1
	.rd2(rd2), // read data 2
	
	// Control signal
	.we(inst_ipipe_valid[4]),				// Reg Write
	.regfile(o_tb_regs)
);

assign o_ldst_wrdata = Rx_ipipe[PIPELINE_DEPTH];
assign o_ldst_addr = mem_sel ? Ry_ipipe[PIPELINE_DEPTH] : pc_out;
assign o_ldst_wr = write_valid; //todo

pc my_pc(
    .clk(clk),
    .reset(reset),
    .enable(pc_enable), // enable branch , next pc_out = in + 2
    .i_addr(pc_in),
    .pc_out(pc_out),
	.pc_nxt(pc_nxt)
);

opcode_decoder control_path0(
	.clk(clk),
	.reset(reset),
	//input opcode
	.opcode(opcode_i_pipe[PIPELINE_DEPTH]),
	// output signals
	.BrSrc(BrSrc),// 0 for rd1, 1 for pc + offset  
	.ALUOp(ALUOp),// 0 for add, 1 for sub
	.RegWrite(RegWrite),// write enable to regitor files
	.MemWrite(o_ldst_wr), // write enable to mem
	.MemRead(o_ldst_rd),
	.RegDst(RegDst),// 0 for Rx, 1 for R7
	.WBSrc(WBSrc),//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
	.PCSrc(PCSrc),//1 for br, 0 for pc+2
	.ExtSel(ExtSel), //0 for imm8, 1 for imm11
	.NZ(NZ), //should update NZ
	.mem_sel(mem_sel),//0 for reading instruction, 1 for reading other memory
	.BSrc(BSrc),//0 for rd2, 1 for imm_ext
	.pc_enable(pc_enable),//update pc or not
	.br_sel(br_sel),
	.lock_instruction(lock_instruction),
	.regfile_read_single(regfile_read_single)
);

assign pc_in = PCSrc ? br : pc_nxt;

logic [15:0] imm_ext;
logic [7:0] imm8;
logic [15:0] imm_8_ext;
assign imm8 = inst_ipipe[PIPELINE_DEPTH][15:8];
logic [10:0] imm11;
logic [15:0] imm_11_ext;
assign imm11 = inst_ipipe[PIPELINE_DEPTH][15:5];
//logic [15:0] mem_in;
//assign mem_in = inst_ipipe[PIPELINE_DEPTH];
//logic [15:0] mvhi_out;
//assign mvhi_out = {imm8,rd1[7:0]};

sign_ext imm8_(
	.in(imm8),
	.out(imm_8_ext)
);

sign_ext #(11) imm11_ (
	.in(imm11),
	.out(imm_11_ext)
);

assign imm_ext = ExtSel ? imm_11_ext : imm_8_ext;
six_one_mux sel_to_wd
(
	.data_in1(mem_in),
	.data_in2(alu_out),
	.data_in3(pc_out),
	.data_in4(rd2),
	.data_in5(imm_ext),
	.data_in6(mvhi_out),
	.sel(WBSrc),
	.mux_out(wd)
);


four_one_mux #(1) sel_to_br
(
	.data_in1(1'b1),
	.data_in2(zero),
	.data_in3(neg),
	.data_in4(1'b0), 
	.sel(br_sel), // 0 = always br(no condition) , 1 = branch if Z == 1, 2 = branch if N == 1
	.mux_out(br_cond)
);
assign br = br_cond ? ( BrSrc ? pc_nxt + imm_ext * 2 : rd1 ): pc_nxt; // branch to pc + imm if condition meet


alu_16 my_alu(
    .data_in_a(Rx_ipipe[1]),
    .data_in_b(BSrc ? imm_ext : Ry_ipipe[1]),
    .sub(ALUOp),
    .alu_out(alu_out),
    .zero(alu_zero),
    .neg(alu_neg)
);


// always_ff @ (posedge clk or posedge reset) begin
// 	if(reset) begin
// 		zero <= 1'b0;
// 		neg <= 1'b0;
// 	end
// 	else if(NZ)begin
// 		zero <= alu_zero;
// 		neg <= alu_neg;
// 	end
// 	else begin
// 		zero <= zero;
// 		neg <= neg;
// 	end
// end

always_ff @ (posedge clk or posedge reset) begin
	if(reset) begin
		zero_reg <= 1'b0;
		neg_reg <= 1'b0;
	end else if(NZ) begin
		zero_reg <= alu_zero;
		neg_reg <= alu_neg;
	end else begin
		zero_reg <= zero_reg;
		neg_reg <= neg_reg;
	end
	alu_out_reg <= alu_out;
end

endmodule

