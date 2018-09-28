library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mm_device_util.all;

entity ssd_mm_device is
	port (
		clk: in std_logic;
		i: in mm_iface_in;
		o: out mm_iface_out := mm_iface_out_default;
		
		b3, b2, b1, b0: out std_logic_vector(7 downto 0) := X"00"
	);
end entity;
	
architecture rtl of ssd_mm_device is
	signal b3i, b2i, b1i, b0i: std_logic_vector(7 downto 0) := X"00";
begin
	b3 <= b3i;
	b2 <= b2i;
	b1 <= b1i;
	b0 <= b0i;

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
		
		regce_ctrl_proc: process (clk, i.en, i.we, i.port_en, rdy) is
		begin
			if rising_edge(clk) then
				rdy(0) <= i.en and i.port_en and (not i.we);
				rdy(1) <= rdy(0);
			end if;
		end process;
		
		regce <= rdy(0);
		o.ready <= rdy(1);

		read_ctrl: process (clk, regce, addr, b3i, b2i, b1i, b0i) is
			variable addr_low: std_logic_vector(7 downto 0) := X"00";
		begin
			-- Use the saved address
			addr_low := addr(7 downto 0);
		
			if rising_edge(clk) then
				if regce = '1' then
					case addr_low is
					when X"03" =>
						o.d <= b3i;
					when X"02" =>
						o.d <= b2i;
					when X"01" =>
						o.d <= b1i;
					when X"00" =>
						o.d <= b0i;
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
				case addr_low is
				when X"03" =>
					b3i <= i.d;
				when X"02" =>
					b2i <= i.d;
				when X"01" =>
					b1i <= i.d;
				when X"00" =>
					b0i <= i.d;
				when others =>
					null;
				end case;
			end if;
		end if;
	end process;
	
end architecture;

