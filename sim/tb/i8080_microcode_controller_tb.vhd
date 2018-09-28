library ieee;
use ieee.std_logic_1164.all;

use work.i8080_util.all;

entity i8080_microcode_controller_tb is
end;

architecture tb of i8080_microcode_controller_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '1';

	signal inst_byte: std_logic_vector(7 downto 0) := X"00";
	signal cs: cpu_control_signals := CPU_CONTROL_SIGNALS_DEFAULT;

	signal cpuinfo: ucode_ctrl_cpuinfo := (
		read_done => '0'
	);
begin
	clk <= not clk after p/2;

	uut: entity work.i8080_microcode_controller(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		inst_byte => inst_byte,
		cs => cs,
		cpuinfo => cpuinfo
	);

end;
