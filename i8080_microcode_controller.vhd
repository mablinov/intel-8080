library ieee;
use ieee.std_logic_1164.all;

use work.i8080_util.all;

entity i8080_microcode_controller is
	port (
		clk, en, reset: in std_logic;
		inst_byte: in std_logic_vector(7 downto 0);
		cpuinfo: in ucode_ctrl_cpuinfo;
		cs: out cpu_control_signals := CPU_CONTROL_SIGNALS_DEFAULT
	);
end entity;

architecture rtl of i8080_microcode_controller is
	signal current_ui, next_ui: microinstruction := fetch_inst_0;
	signal csi: cpu_control_signals := CPU_CONTROL_SIGNALS_DEFAULT;
begin
	cs <= csi;

	register_next_microinstruction: process (clk, en, reset, next_ui) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				current_ui <= fetch_inst_0;
			
			elsif en = '1' then			
				current_ui <= next_ui;
				
			end if;
		end if;
	end process;

	select_next_microinstruction: process (csi, cpuinfo, current_ui, inst_byte) is
	begin
		case csi.uc.op is
		when Jump_next_when_read_complete =>
			if cpuinfo.read_done = '1' then
				next_ui <= get_next_ui(current_ui);
			else
				next_ui <= current_ui;
			end if;
		
		when Jump_next =>
			next_ui <= get_next_ui(current_ui);
			
		when Jump_fetch_inst_0 =>
			-- TODO: add interrupt handling here
			next_ui <= fetch_inst_0;
		
		when Jump_fetch_inst_0_COND =>
			-- Jump to fetch inst 0 if cond bit is NOT satisfied
			if cpuinfo.cond then
				next_ui <= get_next_ui(current_ui);
			else
				next_ui <= fetch_inst_0;
			end if;
		
		when Jump_inst_byte =>
			next_ui <= get_ucode_routine(inst_byte, get_inst(inst_byte));
			-- FIXME: maybe refactor code so that we dont bring the binary
			-- inst byte here, just the enum. Remove the double function,
			-- if worth it...
			
		when Try_jump_to_int_handler =>
			if cpuinfo.int = '1' and cpuinfo.ie = '1' then
				next_ui <= inst_HW_INT_0;
			else
				next_ui <= get_next_ui(current_ui);
			end if;
		
		end case;
	end process;

	microcode_inst: entity work.i8080_microcode(rtl)
	port map (
		current_ui => current_ui,
		inst_byte => inst_byte,
		cs => csi
	);

end architecture;

