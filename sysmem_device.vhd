library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mm_device_util.all;

entity sysmem_device is
	port (
		clk: in std_logic;
		i: in mm_iface_in;
		o: out mm_iface_out := mm_iface_out_default
	);
end entity;
	
architecture rtl of sysmem_device is
	signal regce: std_logic := '0';
begin

	read_signal_ctrl: block
		signal rdy: std_logic_vector(0 to 1) := "00";
	begin
		regce_ctrl_proc: process (clk, i.en, i.we, rdy) is
		begin
			if rising_edge(clk) then
				rdy(0) <= i.en and (not i.we);
				rdy(1) <= rdy(0);
			end if;
		end process;
		
		regce <= rdy(0);
		o.ready <= rdy(1);
		
	end block;

	ramb64x8_inst: entity work.ramb64x8(structural)
	port map (
		CLKA => clk,
		ADDRA => i.addr,
		DIA => i.d,
		DOA => o.d,
		
		ENA => i.en,
		REGCEA => regce,
		RSTRAMA => '0',
		RSTREGA => '0',
		WEA => i.we,
		
		CLKB => clk,
		ADDRB => X"0000",
		DIB => X"00",
		DOB => open,
		
		ENB => '0',
		REGCEB => '0',
		RSTRAMB => '0',
		RSTREGB => '0',
		WEB => '0'
	);

end architecture;

