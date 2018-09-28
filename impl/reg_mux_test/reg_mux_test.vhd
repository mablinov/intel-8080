library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_mux_test is
	port (
		clk: in std_logic;
		di: in std_logic_vector(7 downto 0);
		
		sel: in std_logic_vector(2 downto 0);
		cken: in std_logic;
		
		sel_ld: in std_logic_vector(2 downto 0);
		cken_ld: in std_logic;
		
		do: out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of reg_mux_test is
	subtype byte is std_logic_vector(7 downto 0);
	type reg_file_T is array (natural range <>) of byte;
	
	signal reg_file: reg_file_T(0 to 8) := (others => (others => '0'));
begin
	main: process (clk, sel, di, cken, reg_file, sel_ld, cken_ld)
		variable idx: natural range 0 to 8 := 0;
		variable src_idx: natural range 0 to 8 := 0;
	begin
		idx := to_integer(unsigned(sel));
		src_idx := to_integer(unsigned(sel_ld));
	
		if rising_edge(clk) then
			if cken = '1' and cken_ld = '0' then
				reg_file(idx) <= di;
			elsif cken = '0' and cken_ld = '1' then
				reg_file(src_idx) <= reg_file(idx);
			end if;

		end if;
		
		do <= reg_file(idx);
	end process;
end;
