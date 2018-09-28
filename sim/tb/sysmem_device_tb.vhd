library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mm_device_util.all;

entity sysmem_device_tb is
end;

architecture tb of sysmem_device_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '1';
	
	signal i: mm_iface_in := mm_iface_in_default;
	signal o: mm_iface_out := mm_iface_out_default;
begin

	clk <= not clk after p/2;

	testbench: process
	begin
		wait for 5*p;
		
		i.addr <= X"0001";
		i.d <= X"FF";
		i.en <= '1';
		i.we <= '1';
		wait for p;

		i.addr <= X"0000";
		i.d <= X"00";
		i.en <= '0';
		i.we <= '0';
		wait for 2*p;
		
		i.addr <= X"0001";
		i.d <= X"00";
		i.en <= '1';
		i.we <= '0';
		wait for p;
		
		i.addr <= X"0000";
		i.d <= X"00";
		i.en <= '0';
		i.we <= '0';

		wait;
	end process;
	
	uut: entity work.sysmem_device(rtl)
	port map (
		clk => clk,
		i => i,
		o => o
	);

end architecture;

