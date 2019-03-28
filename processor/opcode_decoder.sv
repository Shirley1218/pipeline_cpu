
// This is the control module for cpu
// It takes a 5-bit opcode and set the coresponding control signal
module opcode_decoder(
	input clk,
	input reset,
	//input opcode
	input [4:0] opcode,
	
	// output signals
	output logic BrSrc,// 0 for rd1, 1 for pc + offset  
	output logic ALUOp,// 0 for add, 1 for sub
	output logic RegWrite,// write enable to regitor files
	output logic MemWrite, // write enable to mem
	output logic BSrc,//0 for rd2, 1 for imm_ext
	output logic RegDst,// 0 for Rx, 1 for R7
	output logic [2:0] WBSrc,//000 for memory, 001 for alu output, 010 for pc+2, 011 for [Ry], 100 for imm8, 101 for {imm8,[rx][7:0]}
	output logic PCSrc,//0 for pc+2, 1 br
	output logic ExtSel, //0 for imm8, 1 for imm11
	output logic NZ, //should update NZ
	//output logic mem_sel, //0 for reading instruction, 1 for reading other memory
	output logic pc_enable,
	output logic MemRead,
	output logic [1:0]br_sel, // 0 = always br(no condition) , 1 = branch if Z == 1, 2 = branch if N == 1
	//output logic lock_instruction,
	output logic regfile_read_single
);
enum int unsigned
{
    IDLE,
    WAIT,
    FETCH,
    LOAD,
    LOAD_WAIT_MEM,
    LOAD_WAIT_VALID,
    STORE
} state, nextstate;

always_ff @(posedge clk or posedge reset) begin 
	if(reset) begin
		 state <= IDLE;
	end else begin
		 state <= nextstate;
	end
end


always_comb begin
	ALUOp = 1'b0;
	RegWrite = 1'b0;
	MemWrite = 1'b0;
	BSrc = 1'b0;
	RegDst = 1'b0;
	WBSrc = 3'b001;
	PCSrc = 1'b0;
	ExtSel = 1'b0;
	NZ = 1'b0;
	pc_enable = 1'b1;
	MemRead = 1'b0;
	br_sel = 2'b00;
	BrSrc = 1'b0;
	nextstate = WAIT;
	if(state == WAIT) begin
		pc_enable = 1'b0;
		else nextstate = FETCH;
		br_sel = 2'b11;
		PCSrc = 1'b1;
		MemRead = 1'b1;
	end
	if(state == IDLE) begin
		pc_enable = 1'b0;
		nextstate = WAIT;
	end
	else if(state == REG_WRITE) begin
		nextstate = FETCH;
		case(opcode)
			5'b00000: begin//mv
				RegWrite = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b011;
			end
			5'b00001:begin//add
				RegWrite = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b001;
			end
			5'b00010:begin//sub
				RegWrite = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b001;
			end
			5'b00100:begin//ld
				RegWrite = 1'b1;
				RegDst = 1'b0;
			end
			5'b10000:begin//mvi
				RegWrite = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b100;
			end
			5'b10001:begin//addi
				RegWrite = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b001;
			end
			5'b10010:begin//subi
				RegWrite = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b001;
			end
			5'b10110:begin//mvhi
				RegWrite = 1'b1;
				RegDst = 1'b0;
				WBSrc = 3'b101;
			end
			default: begin
				ALUOp = 1'b0;
				RegWrite = 1'b0;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegDst = 1'b0;
				WBSrc = 3'b001;
				PCSrc = 1'b1;
				ExtSel = 1'bx;
				NZ = 1'b0;
				BSrc = 1'b0;
				pc_enable = 1'b0;
				ld = 1'b0;
				st = 1'b0;
				BrSrc = 1'b0;
				BrCond = 2'b00;
			end
		endcase
	end
	else if(state == FETCH) begin 
		pc_enable = 1'b1;
		nextstate = REG_READ;
	end
	else if(state == EXECUTE) begin // ALU result, mem ld st
		pc_enable = 1'b1;
		nextstate = REG_WRITE;
		case(opcode)
			5'b00001:begin//add
				BSrc = 1'b0;
				ALUOp = 1'b0;
				NZ = 1'b1;
			end
			5'b00010:begin//sub
				BSrc = 1'b0;
				ALUOp = 1'b1;
				NZ = 1'b1;
			end
			5'b00011:begin//cmp
				ALUOp = 1'b1;
				BSrc = 1'b0;
				NZ = 1'b1;
			end
			5'b00100:begin//ld
				BSrc = 1'b0;
				MemRead = 1'b1;
			end
			5'b00101:begin//st
				BSrc = 1'b0;
				MemWrite = 1'b1;
			end
			5'b10001:begin//addi
				ALUOp = 1'b0;
				BSrc = 1'b1;
				ExtSel = 1'b0;
				NZ = 1'b1;
			end
			5'b10010:begin//subi
				ALUOp = 1'b1;
				BSrc = 1'b1;
				ExtSel = 1'b0;
				NZ = 1'b1;
			end
			5'b10011:begin//cmpi
				ALUOp = 1'b1;
				BSrc = 1'b1;
				ExtSel = 1'b0;
				NZ = 1'b1;
			end
			5'b10110:begin//mvhi
				ALUOp = 1'b0;
				ExtSel = 1'b0;
				BSrc = 1'b1;
			end 
			default: begin
				NZ = 1'b0;
				MemWrite = 1'b0;
				MemRead = 1'b0;
			end
		endcase
	end
	else if(state == REG_READ) begin
		nextstate = EXECUTE;
	end

end
endmodule