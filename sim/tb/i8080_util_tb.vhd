library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

use work.txt_util.all;

entity i8080_util_tb is
end;

architecture behavioural of i8080_util_tb is
begin
	process
		variable i_slv: std_logic_vector(7 downto 0) := (others => '0');
	begin
		report "TOTAL_INST_COUNT = " & natural'image(
			TOTAL_INST_COUNT) severity note;

		for i in 0 to 2 ** 8 - 1 loop
			i_slv := std_logic_vector(to_unsigned(i, 8));
			
			print("get_inst(" & str(i_slv) & ") = "
				& inst_type'image(get_inst(i_slv)));
		end loop;
		wait;
	end process;
end architecture;

