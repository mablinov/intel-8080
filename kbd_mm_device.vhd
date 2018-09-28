library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;
use work.mm_device_util.all;

entity kbd_mm_device is
	port (
		clk: in std_logic;
		i: in mm_iface_in;
		o: out mm_iface_out := mm_iface_out_default;
		
		ps2_keycode: in ps2_keycode_T;
		ps2_make: in std_logic;
		ps2_err: in std_logic
	);
end entity;
	
architecture rtl of kbd_mm_device is
	signal ps2_keycode_byte: std_logic_vector(7 downto 0) := X"00";
	signal ps2_make_byte: std_logic_vector(7 downto 0) := X"00";
	signal ps2_err_byte: std_logic_vector(7 downto 0) := X"00";
begin
	ps2_keycode_byte <= std_logic_vector(
		to_unsigned(ps2_keycode_T'pos(ps2_keycode), 8));
	ps2_make_byte <= "0000" & "000" & ps2_make;
	ps2_err_byte <= "0000" & "000" & ps2_err;

	read_signal_ctrl: block
		signal rdy: std_logic_vector(0 to 1) := "00";
		
		signal addr: std_logic_vector(15 downto 0) := X"0000";
		signal regce: std_logic := '0';
	begin
		
		register_addr: process (clk, i) is
		begin
			if rising_edge(clk) then
				if (i.en and i.port_en and (not i.we)) = '1' then
					addr <= i.addr;
				end if;
			end if;
		end process;
		
		regce_ctrl_proc: process (clk, i.en, i.port_en, i.we, rdy) is
		begin
			if rising_edge(clk) then
				rdy(0) <= i.en and i.port_en and (not i.we);
				rdy(1) <= rdy(0);
			end if;
		end process;
		
		regce <= rdy(0);
		o.ready <= rdy(1);

		read_ctrl: process (clk, regce, addr, ps2_keycode_byte, ps2_make_byte,
			ps2_err_byte)
		is
			variable addr_low: std_logic_vector(7 downto 0) := X"00";
		begin
			-- Use the saved address
			addr_low := addr(7 downto 0);
		
			if rising_edge(clk) then
				if regce = '1' then
					case addr_low is
					when X"80" =>
						o.d <= ps2_keycode_byte;
					when X"81" =>
						o.d <= ps2_make_byte;
					when X"82" =>
						o.d <= ps2_err_byte;
					when X"83" =>
						o.d <= X"00";
					when others =>
						null;
					end case;
				end if;
			end if;
		end process;
	end block;
	
	write_ctrl: process (clk, i) is
		variable addr_low: std_logic_vector(7 downto 0) := X"00";
	begin
		addr_low := i.addr(7 downto 0);
	
		if rising_edge(clk) then
			if (i.en and i.port_en and i.we) = '1' then
				-- This device cannot be written to.
				null;
				
			end if;
		end if;
	end process;
	
end architecture;

