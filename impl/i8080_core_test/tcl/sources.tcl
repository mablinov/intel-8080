set sources {
	../../../txt_util/txt_util.vhd \
	../../../ram/ramb64x1.vhd \
	../../../ram/ramb64x8.vhd \
	../../../signals/debouncer.vhd \
	../../../signals/strobe_if_changed.vhd \
	../../../ssd/ssd_ctrl.vhd \
	../../i8080_util.vhd \
	../../i8080_alu_util.vhd \
	../../i8080_alu.vhd \
	../../i8080_register_file.vhd \
	../../i8080_microcode_util.vhd \
	../../i8080_microcode.vhd \
	../../i8080_microcode_controller.vhd \
	../../i8080_core.vhd \
	../../i8080_core_test.vhd \
}

set constraints "constraints.xdc"
set top_ent i8080_core_test
set part xc7a100tcsg324-1
set outputDir bit

read_vhdl $sources
read_xdc $constraints
