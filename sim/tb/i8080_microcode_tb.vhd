library ieee;
use ieee.std_logic_1164.all;

use work.i8080_util.all;

entity i8080_microcode_tb is
end entity;

architecture tb of i8080_microcode_tb is
	signal current_ui: microinstruction := fetch_inst_0;
	signal cs: cpu_control_signals := CPU_CONTROL_SIGNALS_DEFAULT;

begin

	stimulus: process
		constant p: time := 10 ns;
		variable cui: microinstruction := microinstruction'left;
	begin
		for i in microinstruction loop
			current_ui <= i;
			wait for p;
		end loop;
		
		report "Simulation complete." severity note;
		wait;
	end process;

	uut: entity work.i8080_microcode(rtl)
	port map (
		current_ui => current_ui,
		cs => cs
	);

end architecture;

