set top_ent "i8080_core_inst_LXI_tb"
set wcfg_name "i8080_core_inst_LXI_tb"

if {[current_sim] eq ""} {
	puts "No simulation object is open."
} else {
	puts "Have a simulation object open, closing current..."
	close_sim
}

# Avoid the awk error
if {[catch {exec make $top_ent} issue]} {
	puts "Caught make error: "
	puts "Issue: $issue"
}

xsim xil_defaultlib.$top_ent

# Open the wave configuration file
open_wave_config xil_defaultlib.$wcfg_name.wcfg


