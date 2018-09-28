set sources {
	../../txt_util.vhd \
\
	../../util_8080.vhd \
	../../get_inst_test.vhd \
}

set constraints "constraints.xdc"
set top_ent get_inst_test
set part xc7a100tcsg324-1
set outputDir bit

read_vhdl $sources
read_xdc $constraints

