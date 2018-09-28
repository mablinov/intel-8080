library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_register_file_tb is
end entity;

architecture tb of i8080_register_file_tb is
	constant p: time := 10 ns;

	signal clk: std_logic := '1';
	signal cs: registerfile_control_signals :=
		REGISTERFILE_CONTROL_SIGNALS_DEFAULT;
	signal do: std_logic_vector(7 downto 0) := X"00";
	signal di: std_logic_vector(7 downto 0) := X"00";
begin

	clk <= not clk after p/2;

	testbench: process is
	begin
		wait for 2*p;
		
		di <= X"22";
		cs.rf_sel <= RF_A;
		cs.en <= '1';
		cs.wren <= '1';
		
		wait for p;
		
		di <= X"ff";
		cs.rf_sel <= RF_B;
		
		wait for p;
		
		di <= X"00";
		cs.wren <= '0';
		
		wait for p;
		
		cs.rf_sel <= RF_A;
		
		wait for p;
		
		cs.en <= '0';
		
		wait;
	end process;

	uut: entity work.i8080_register_file(rtl)
	port map (
		clk => clk,
		
		cs => cs,
		
		di => di,
		do => do
	);
end architecture;

