library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_address_unit_tb is
end entity;

architecture tb of i8080_address_unit_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '1';
	
	signal cs: address_control_signals := ADDRESS_CONTROL_SIGNALS_DEFAULT;
	signal addr: std_logic_vector(15 downto 0) := X"0000";
begin

	clk <= not clk after p/2;

	testbench: process is
	begin

		cs.mode <= ADDRMODE_PC;	
		wait for 4*p;

		cs.mode <= ADDRMODE_BC;
		wait for 4*p;

		cs.mode <= ADDRMODE_DE;
		wait for 4*p;

		cs.mode <= ADDRMODE_HL;
		wait for 4*p;

		cs.mode <= ADDRMODE_SP;
		wait for 4*p;

		report "Done";
		wait;
	end process;

	uut: entity work.i8080_address_unit(pipeline_2_cycle)
	port map (
		clk => clk,
		cs => cs,
		
		b => X"de",
		c => X"ad",
		d => X"be",
		e => X"ef",
		h => X"12",
		l => X"34",
		pc => X"5678",
		sp => X"9abc",

		addr => addr
	);

end architecture;

