onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/reset
add wave -noupdate /tb/o_pc_addr
add wave -noupdate /tb/o_pc_rd
add wave -noupdate /tb/i_pc_rddata
add wave -noupdate /tb/o_ldst_addr
add wave -noupdate /tb/o_ldst_rd
add wave -noupdate /tb/o_ldst_wr
add wave -noupdate /tb/i_ldst_rddata
add wave -noupdate /tb/o_ldst_wrdata
add wave -noupdate -expand /tb/o_tb_regs
add wave -noupdate /tb/mem
add wave -noupdate /tb/tstate
add wave -noupdate -childformat {{{/tb/dut/inst_ipipe[1]} -radix hexadecimal} {{/tb/dut/inst_ipipe[2]} -radix hexadecimal} {{/tb/dut/inst_ipipe[3]} -radix hexadecimal} {{/tb/dut/inst_ipipe[4]} -radix hexadecimal}} -expand -subitemconfig {{/tb/dut/inst_ipipe[1]} {-height 15 -radix hexadecimal} {/tb/dut/inst_ipipe[2]} {-height 15 -radix hexadecimal} {/tb/dut/inst_ipipe[3]} {-height 15 -radix hexadecimal} {/tb/dut/inst_ipipe[4]} {-height 15 -radix hexadecimal}} /tb/dut/inst_ipipe
add wave -noupdate /tb/dut/inst_ipipe_valid
add wave -noupdate -expand /tb/dut/opcode_i_pipe
add wave -noupdate /tb/dut/Rx_reg
add wave -noupdate /tb/dut/Rx_reg2
add wave -noupdate /tb/dut/Ry_reg
add wave -noupdate /tb/dut/Ry_reg2
add wave -noupdate /tb/dut/wd
add wave -noupdate /tb/dut/rd1
add wave -noupdate /tb/dut/rd2
add wave -noupdate /tb/dut/pc_in
add wave -noupdate /tb/dut/pc_nxt
add wave -noupdate /tb/dut/pc_out
add wave -noupdate /tb/dut/alu_out
add wave -noupdate /tb/dut/imm8_ext
add wave -noupdate /tb/dut/imm11_ext
add wave -noupdate /tb/dut/alu_out_reg
add wave -noupdate /tb/dut/zero_reg
add wave -noupdate /tb/dut/neg_reg
add wave -noupdate /tb/dut/imm8_reg
add wave -noupdate /tb/dut/imm8_ext_reg
add wave -noupdate /tb/dut/RegDst
add wave -noupdate /tb/dut/WBSrc
add wave -noupdate /tb/dut/RegWrite
add wave -noupdate /tb/dut/ExtSel
add wave -noupdate /tb/dut/BSrc
add wave -noupdate /tb/dut/BrSrc
add wave -noupdate /tb/dut/ALUOp
add wave -noupdate /tb/dut/NZ
add wave -noupdate /tb/dut/br_sel
add wave -noupdate /tb/dut/pc_enable
add wave -noupdate /tb/dut/PCSrc
add wave -noupdate /tb/dut/ws
add wave -noupdate /tb/dut/rs1
add wave -noupdate /tb/dut/rs2
add wave -noupdate /tb/dut/mem_in
add wave -noupdate /tb/dut/mvhi_out
add wave -noupdate /tb/dut/alu_zero
add wave -noupdate /tb/dut/alu_neg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {111 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {236 ps}
