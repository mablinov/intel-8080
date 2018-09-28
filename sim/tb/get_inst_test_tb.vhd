library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity get_inst_test_tb is
end entity;

architecture tb of get_inst_test_tb is
	constant p: time := 10 ns;

	signal clk: std_logic := '1';
	signal inst_byte: std_logic_vector(7 downto 0) := (others => '0');
	signal inst_class: std_logic_vector(5 downto 0) := (others => '0');
begin
	clk <= not clk after p/2;

	testbench: process
	begin
		wait for p;
		
		inst_byte <= X"a2";
		wait for p;
		inst_byte <= X"00";
		wait;
		
		report "Simulation complete" severity note;
	end process;

	uut: entity work.get_inst_test(rtl)
	port map (
		clk => clk,
		inst_byte => inst_byte,
		inst_class => inst_class
	);
end architecture;
