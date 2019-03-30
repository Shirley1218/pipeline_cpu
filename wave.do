onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb/dut/o_pc_addr
add wave -noupdate -radix hexadecimal /tb/i_pc_rddata
add wave -noupdate -radix hexadecimal /tb/dut/my_pc/i_addr
add wave -noupdate -radix hexadecimal /tb/dut/my_pc/pc_out
add wave -noupdate -radix hexadecimal /tb/dut/pc_cache
add wave -noupdate /tb/dut/my_pc/enable
add wave -noupdate -radix hexadecimal -childformat {{{/tb/dut/inst_ipipe[1]} -radix hexadecimal} {{/tb/dut/inst_ipipe[2]} -radix hexadecimal} {{/tb/dut/inst_ipipe[3]} -radix hexadecimal} {{/tb/dut/inst_ipipe[4]} -radix hexadecimal}} -expand -subitemconfig {{/tb/dut/inst_ipipe[1]} {-height 15 -radix hexadecimal} {/tb/dut/inst_ipipe[2]} {-height 15 -radix hexadecimal} {/tb/dut/inst_ipipe[3]} {-height 15 -radix hexadecimal} {/tb/dut/inst_ipipe[4]} {-height 15 -radix hexadecimal}} /tb/dut/inst_ipipe
add wave -noupdate /tb/dut/hold_in_decode_state
add wave -noupdate /tb/dut/helper/reading_count
add wave -noupdate /tb/dut/helper/reading_src
add wave -noupdate /tb/dut/helper/writing_dst
add wave -noupdate /tb/dut/helper/valid
add wave -noupdate /tb/dut/helper/rx_rd
add wave -noupdate /tb/dut/helper/ry_rd
add wave -noupdate /tb/dut/helper/rx_wr
add wave -noupdate /tb/dut/helper/ry_wr
add wave -noupdate -radix hexadecimal /tb/dut/rd1
add wave -noupdate -radix hexadecimal /tb/dut/rd2
add wave -noupdate -radix hexadecimal /tb/dut/rs1
add wave -noupdate -radix hexadecimal /tb/dut/rs2
add wave -noupdate -radix hexadecimal /tb/dut/Rx_reg
add wave -noupdate -radix hexadecimal /tb/dut/Rx_reg2
add wave -noupdate -radix hexadecimal /tb/dut/Ry_reg
add wave -noupdate -radix hexadecimal /tb/dut/Ry_reg2
add wave -noupdate -expand /tb/dut/opcode_i_pipe
add wave -noupdate -radix hexadecimal -childformat {{{/tb/dut/gprs/regfile[7]} -radix hexadecimal} {{/tb/dut/gprs/regfile[6]} -radix hexadecimal} {{/tb/dut/gprs/regfile[5]} -radix hexadecimal} {{/tb/dut/gprs/regfile[4]} -radix hexadecimal} {{/tb/dut/gprs/regfile[3]} -radix hexadecimal} {{/tb/dut/gprs/regfile[2]} -radix hexadecimal} {{/tb/dut/gprs/regfile[1]} -radix hexadecimal} {{/tb/dut/gprs/regfile[0]} -radix hexadecimal}} -expand -subitemconfig {{/tb/dut/gprs/regfile[7]} {-height 15 -radix hexadecimal} {/tb/dut/gprs/regfile[6]} {-height 15 -radix hexadecimal} {/tb/dut/gprs/regfile[5]} {-height 15 -radix hexadecimal} {/tb/dut/gprs/regfile[4]} {-height 15 -radix hexadecimal} {/tb/dut/gprs/regfile[3]} {-height 15 -radix hexadecimal} {/tb/dut/gprs/regfile[2]} {-height 15 -radix hexadecimal} {/tb/dut/gprs/regfile[1]} {-height 15 -radix hexadecimal} {/tb/dut/gprs/regfile[0]} {-height 15 -radix hexadecimal}} /tb/dut/gprs/regfile
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 198
configure wave -valuecolwidth 164
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
WaveRestoreZoom {0 ps} {222 ps}
