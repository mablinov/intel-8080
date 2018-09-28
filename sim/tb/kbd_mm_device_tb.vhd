library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;
use work.mm_device_util.all;

entity kbd_mm_device_tb is
end;

architecture tb of kbd_mm_device_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '1';
	
	signal i: mm_iface_in := mm_iface_in_default;
	signal o: mm_iface_out := mm_iface_out_default;

		
	signal ps2_keycode: ps2_keycode_T := PS2_KEY_UNKNOWN;
	signal ps2_make: std_logic := '0';
	signal ps2_err: std_logic := '0';
begin

	clk <= not clk after p/2;

	testbench: process
	begin
		ps2_keycode <= PS2_KEY_6;
		ps2_make <= '1';
		ps2_err <= '1';
		wait for 5*p;
		
		i.addr <= X"0080";
		i.d <= X"00";
		i.en <= '1';
		i.port_en <= '1';
		wait for p;

		i.addr <= X"0081";
		i.d <= X"00";
		i.en <= '1';
		i.port_en <= '1';
		wait for p;
		
		i.addr <= X"0082";
		i.d <= X"00";
		i.en <= '1';
		i.port_en <= '1';
		wait for p;
		
		i.addr <= X"0083";
		i.d <= X"00";
		i.en <= '1';
		i.port_en <= '1';
		wait for p;

		i.addr <= X"0000";
		i.d <= X"00";
		i.en <= '0';
		i.port_en <= '0';
		wait;
	end process;
	
	uut: entity work.kbd_mm_device(rtl)
	port map (
		clk => clk,
		i => i,
		o => o,
		
		
		ps2_keycode => ps2_keycode,
		ps2_make => ps2_make,
		ps2_err => ps2_err
	);

end architecture;

