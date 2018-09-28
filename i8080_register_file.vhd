library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_register_file is
	port (
		clk: in std_logic;
		
		cs: in register_file_control_signals;
		
		di: in std_logic_vector(7 downto 0);
		do: out std_logic_vector(7 downto 0) := X"00"
	);
end entity;

architecture rtl of i8080_register_file is
	type rf_T is array
		(register_file_select range
			register_file_select'left to register_file_select'right) of
			std_logic_vector(7 downto 0);
	signal rf: rf_T := (others => (others => '0'));
begin

	rf_ctrl: process (clk, cs, di) is
	begin
		if rising_edge(clk) then
			if cs.en = '1' then
				if cs.wren = '0' then
					do <= rf(cs.sel);
				else
					rf(cs.sel) <= di;
				end if;
			end if;
		end if;
	end process;

end architecture;

