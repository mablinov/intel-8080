set sources { reg_mux_test.vhd }

set constraints "constraints.xdc"
set top_ent reg_mux_test
set part xc7a100tcsg324-1
set outputDir bit

read_vhdl $sources
read_xdc $constraints

