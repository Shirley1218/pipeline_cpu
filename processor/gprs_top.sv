// register file top module

module gprs_top(

	input clk,
	input reset,
	
	// input ports
	input [2:0] rs1, // read register 1
	input [2:0] rs2, // read register 2
	input [2:0] ws,  // write register
	input [15:0] wd,  // write data
	
	
	// output ports
	output logic [15:0] rd1, // read data 1
	output logic [15:0] rd2, // read data 2
	
	// Control signal
	input we,				// Reg Write
	output logic [7:0][15:0] regfile
);

	// regfile RAM
	//reg [15:0] regfile [7:0];
	
	logic [7:0] ws_addr;
	
	// rf_decode write reg address
	ram_decoder ram_decoder1(
		.i_addr(ws),
		.o_addr(ws_addr)
	);
	
	always_ff @(posedge clk or posedge reset) begin
		if(reset) begin
			regfile <= '{default:0};
		end 
		else if(we) begin	
			regfile[ws] <= wd;
		end
	end

	// mem read
	
	reg_file_read rf_rd1(
		.regfile(regfile),
		.reg_addr(rs1),
		.reg_out(rd1)
	);
	
	reg_file_read rf_rd2(
		.regfile(regfile),
		.reg_addr(rs2),
		.reg_out(rd2)
	);
	
endmodule

module reg_file_read(
	input [7:0][15:0] regfile,
	input [2:0]				reg_addr,
	output logic [15:0]	reg_out
	);
always_comb begin
	case(reg_addr)
		3'd0:reg_out = regfile[0]; 	// R0
		3'd1:reg_out = regfile[1]; 	// R1
		3'd2:reg_out = regfile[2]; 	// R2
		3'd3:reg_out = regfile[3]; 	// R3
		3'd4:reg_out = regfile[4]; 	// R4
		3'd5:reg_out = regfile[5]; 	// R5
		3'd6:reg_out = regfile[6]; 	// R6
		3'd7:reg_out = regfile[7]; 	// R7
		default:reg_out = 16'd0;	
	endcase
end
endmodule

module ram_decoder
# (parameter IN_WIDTH = 3,
	parameter OUT_WIDTH = 8
	)
	(
	input  [IN_WIDTH-1:0]		i_addr,
	output logic [OUT_WIDTH-1:0] 		o_addr
	);

	always_comb begin
		for (int i = 0; i < OUT_WIDTH; i++) begin 
			o_addr[i] = (i == i_addr);
		end
	end 
endmodule
