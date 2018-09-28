set sources {
	../../../txt_util/txt_util.vhd \
	../../../signals/debouncer.vhd \
	../../../signals/strobe_if_changed.vhd \
	../../../ssd/ssd_ctrl.vhd \
	../../../ps2/ps2_util.vhd \
	../../../ps2/ps2_bit_rx_strobe.vhd \
	../../../ps2/ps2_shifter.vhd \
	../../../ps2/ps2_byte_parser.vhd \
	../../../ps2/ps2_interface.vhd \
	../../../ps2/ps2_interface_test.vhd \
	../../../ram/ramb64x1.vhd \
	../../../ram/ramb64x8.vhd \
	../../../glyph/glyph_util.vhd \
	../../../vga/vga_util.vhd \
	../../../vga/vga_pixel_clock.vhd \
	../../../vga/vga_hstate_fsm.vhd \
	../../../vga/vga_vstate_fsm.vhd \
	../../../vga/vga_state_fsm.vhd \
	../../../vga/vga_text_frame_counter.vhd \
	../../../vga/character_address_unit.vhd \
	../../../vga/video_pipeline.vhd \
	../../i8080_util.vhd \
	../../i8080_alu_util.vhd \
	../../i8080_alu.vhd \
	../../i8080_register_file.vhd \
	../../i8080_microcode_util.vhd \
	../../i8080_microcode.vhd \
	../../i8080_microcode_controller.vhd \
	../../i8080_core.vhd \
	../../mm_device_util.vhd \
	../../mm_device_arbiter.vhd \
	../../sysmem_device.vhd \
	../../vgamem_device.vhd \
	../../ssd_mm_device.vhd \
	../../kbd_mm_device.vhd \
	../../i8080_system_test.vhd \
}

set constraints "constraints.xdc"
set top_ent i8080_system_test
set part xc7a100tcsg324-1
set outputDir bit

read_vhdl $sources
read_xdc $constraints
