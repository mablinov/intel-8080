library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;
use work.i8080_memory_sim_util.all;

entity i8080_core_inst_NOP_tb is
end;

architecture tb of i8080_core_inst_NOP_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '1';

	signal fin: i8080_core_in := I8080_CORE_IN_DEFAULT;
	signal fout: i8080_core_out := I8080_CORE_OUT_DEFAULT;
begin
	clk <= not clk after p/2;

	cpu: entity work.i8080_core(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		fin => fin,
		fout => fout
	);

	mem: entity work.i8080_memory_sim(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		fin => fin,
		fout => fout
	);
end;

