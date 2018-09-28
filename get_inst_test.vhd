library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util_8080.all;

entity get_inst_test is
	port (
		clk: in std_logic;
		inst_byte: in std_logic_vector(7 downto 0);
		inst_class: out std_logic_vector(5 downto 0)
	);
end;

architecture behavioural of get_inst_test is
	function slv(ic: inst_type) return std_logic_vector is
		variable ic_num: natural range 0 to TOTAL_INST_COUNT - 1 := 0;
		variable ret: std_logic_vector(5 downto 0);
	begin
		ic_num := inst_type'pos(ic);
		ret := std_logic_vector(to_unsigned(ic_num, 6));
		
		return ret;
	end function;
	
	signal current_class: inst_type := INST_NOP;
begin
	inst_class <= slv(current_class);

	process (clk, inst_byte) is
	begin
		if rising_edge(clk) then
			current_class <= get_inst(inst_byte);
		end if;
	end process;
end architecture;

