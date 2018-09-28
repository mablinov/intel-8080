library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_nb_inst_nop_tb is
end;

architecture behavioural of i8080_nb_inst_nop_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '1';
	
	signal cpu_m_en, cpu_mem_op_done: std_logic := '0';
begin
	clk <= not clk after p/2;

	testbench: process
	begin
		wait for 2*p;
		
		cpu_m_en <= '1';
		wait for p;
		cpu_m_en <= '0';
		wait;
		
	end process;

	uut: entity work.i8080_northbridge(inst_NOP)
	port map (
		clk => clk, en => '1', reset => '0',
		
		cpu_di => X"00",
		cpu_do => open,
		cpu_addr => X"0000",
		cpu_m_en => cpu_m_en,
		cpu_m_wren => '0',
		cpu_mem_op_done => cpu_mem_op_done
	);
end architecture;

