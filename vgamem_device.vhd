library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mm_device_util.all;

entity vgamem_device is
	port (
		clk: in std_logic;
		i: in mm_iface_in;
		o: out mm_iface_out := mm_iface_out_default;
		
		addr: out std_logic_vector(15 downto 0) := X"0000";
		do: out std_logic_vector(7 downto 0) := X"00";
		di: in std_logic_vector(7 downto 0);
		en, we, regce: out std_logic := '0'
	);
end entity;

architecture rtl of vgamem_device is
--	signal regce: std_logic := '0';
	signal real_addr: std_logic_vector(15 downto 0) := X"0000";
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

	real_addr <= std_logic_vector(unsigned(i.addr) -
		unsigned(std_logic_vector'(X"8000")));

	addr <= real_addr;
	do <= i.d;
	o.d <= di;
	en <= i.en;
	we <= i.we;
--	regce <= regce;

end architecture;

