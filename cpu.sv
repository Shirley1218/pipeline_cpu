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


localparam		PIPELINE_STAGE = 4;
logic [15:0]	inst_ipipe				[1:PIPELINE_STAGE];
logic [0:0]		inst_ipipe_valid		[1:PIPELINE_STAGE];
logic [4:0]		opcode_i_pipe			[1:PIPELINE_STAGE];
logic [15:0]	Rx_reg;
logic [15:0]	Ry_reg;
logic [15:0]	Ry_reg2;		// Ry from 2 stage ago 
logic [15:0]	wd;
logic [15:0]	rd1;
logic [15:0]	rd2;
logic [15:0]	pc_in;
logic [15:0]	pc_nxt;
logic [15:0]	pc_out;
logic [15:0]	alu_out;
logic [15:0] 	imm8_ext;
logic [15:0] 	imm11_ext;
// execution reg
logic [15:0]	alu_out_reg;
logic			zero_reg;
logic 			neg_reg;
logic [7:0] 	imm8_reg;
logic [15:0] 	imm8_ext_reg;

logic		RegDst;
logic [2:0]		WBSrc;
logic		RegWrite;
logic		ExtSel;
logic		BSrc;
logic		BrSrc;
logic		ALUOp;
logic		NZ;
logic [1:0]		br_sel;
logic		pc_enable;
logic		PCSrc;


// implement the cpu pipeline
always_ff @(posedge clk or posedge reset) begin 
	
	if(reset) begin
		for(int i=1; i<=PIPELINE_STAGE; i++) begin
			inst_ipipe[i] <= '0;
		end
		for(int i=1; i<=PIPELINE_STAGE; i++) begin
			inst_ipipe_valid[i] <= '0;
		end
	end else begin

		// Pipeline Stage 1: Fetch
		inst_ipipe[1] <= i_pc_rddata;
		inst_ipipe_valid[1] <= '1;
		for(int i=2; i<=PIPELINE_STAGE; i++) begin
			inst_ipipe[i] <= inst_ipipe[i-1];
		end
	
	end
end

always_comb begin
	for(int i=1; i<=PIPELINE_STAGE; i++) begin
		opcode_i_pipe[i] = inst_ipipe[i][4:0];
	end
end

logic [2:0] ws;
assign ws = RegDst ? 3'b111 : inst_ipipe[4][7:5];

logic [2:0] rs1,rs2;
//logic regfile_read_single; // = 1 if inst_ipipe[4] only use Rx, if so, read Ry from inst_ipipe[4]
							// = 0 if inst_ipipe[4] use both Rx and Ry
assign rs1 = inst_ipipe[1][7:5];
assign rs2 = inst_ipipe[1][10:8];
 
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
	.we(RegWrite),				// Reg Write
	.regfile(o_tb_regs)
);

assign o_ldst_wrdata = Rx_reg;
assign o_ldst_addr = Rx_reg;

pc my_pc(
    .clk(clk),
    .reset(reset),
    .enable(pc_enable), // enable branch , next pc_out = in + 2
    .i_addr(pc_in),
    .pc_out(pc_out),
	.pc_nxt(pc_nxt)
);

pipeline_decoder control_path0(
	.clk(clk),
	.reset(reset),
	.opcode(opcode_i_pipe),
	// stage 1 Fetch 
	.PCSrc(PCSrc),			//1 for br, 0 for pc+2
	.pc_enable(pc_enable),	//update pc or not
	.br_sel(br_sel),
	// stage 2 RegFile Read

	// Stage 3 Execute
	.NZ(NZ), //should update NZ
	.ALUOp(ALUOp),// 0 for add, 1 for sub
	.BrSrc(BrSrc),// 0 for rd1, 1 for pc + offset  
	.BSrc(BSrc),//0 for rd2, 1 for imm_ext
	.ExtSel(ExtSel), //0 for imm8, 1 for imm11
	.MemWrite(o_ldst_wr), // write enable to mem
	.MemRead(o_ldst_rd),

	// Stage 4 RegFile Write
	.RegWrite(RegWrite),// write enable to regitor files
	.WBSrc(WBSrc),//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8
	.RegDst(RegDst)// 0 for Rx, 1 for R7
);

//assign pc_in = PCSrc ? br : pc_nxt;
assign pc_in = pc_nxt;

logic [15:0] mem_in;
//assign mem_in = inst_ipipe[PIPELINE_DEPTH];
logic [15:0] mvhi_out;
assign mvhi_out = {imm8_reg,Rx_reg[7:0]};

sign_ext imm8_sign_ext(
	.in(inst_ipipe[3][15:8]),
	.out(imm8_ext)
);
sign_ext #(11) imm11_sign_ext
(
	.in(inst_ipipe[3][15:5]),
	.out(imm11_ext)
);

six_one_mux sel_to_wd
(
	.data_in1(mem_in),
	.data_in2(alu_out_reg),
	.data_in3(Ry_reg2),
	.data_in4(imm8_ext_reg),
	.data_in5(mvhi_out),
	.data_in6(),
	.sel(WBSrc),
	.mux_out(wd)
);


// four_one_mux #(1) sel_to_br
// (
// 	.data_in1(1'b1),
// 	.data_in2(zero),
// 	.data_in3(neg),
// 	.data_in4(1'b0), 
// 	.sel(br_sel), // 0 = always br(no condition) , 1 = branch if Z == 1, 2 = branch if N == 1
// 	.mux_out(br_cond)
// );
//assign br = br_cond ? ( BrSrc ? pc_nxt + imm_ext * 2 : rd1 ): pc_nxt; // branch to pc + imm if condition meet

// stage 3 alu op
alu_16 my_alu(
    .data_in_a(Rx_reg),
    .data_in_b(BSrc ? imm_ext : Ry_reg),
    .sub(ALUOp),
    .alu_out(alu_out),
    .zero(alu_zero),
    .neg(alu_neg)
);

// Stage 2 reg
always_ff @ (posedge clk or posedge reset) begin
	if(reset) begin
		Rx_reg <= '0;
		Ry_reg <= '0;
		Ry_reg2 <= '0;
	end else begin
		Rx_reg <= rd1;
		Ry_reg <= rd2;
		Ry_reg2 <= Ry_reg;
	end
end

// Stage 3 regs
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
	imm8_reg <= inst_ipipe[3];
	imm8_ext_reg <= imm8_ext;
end
endmodule