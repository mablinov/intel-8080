library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_address_unit is
	port (
		clk, en, reset: in std_logic;
		
		pc, bc, de, hl, sp, temp: in std_logic_vector(15 downto 0);
		reset: in std_logic_vector(2 downto 0);
		cs_a: in address_control_signals;
		
		addr: out std_logic_vector(15 downto 0)
	);
end entity;

architecture behavioural of i8080_address_unit is
	signal reg_alt_addr: std_logic_vector(15 downto 0) := X"0000";
begin

	addr_ctrl: process (pc, reg_alt_addr, cs_a.mode, cs_a.offset) is
	begin
		case cs_a.mode is
		when PC =>
			addr <= std_logic_vector(
				unsigned(pc) + to_unsigned(cs_a.offset, 15)
			);
		when AltAddr =>
			addr <= std_logic_vector(
				unsigned(reg_alt_addr) + to_unsigned(cs_a.offset, 15)
			);
		end case;
	end process;


	reg_alt_addr_ctrl: process (clk, en, reset, cs_a.aa_load,
		bc, de, hl, sp, temp) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg_alt_addr <= X"0000";
			
			elsif en = '1' then
				case aa_load is
				when BC =>
					reg_alt_addr <= bc;
				
				when DE =>
					reg_alt_addr <= de;
					
				when HL =>
					reg_alt_addr <= hl;
					
				when SP =>
					reg_alt_addr <= sp;
				
				when TEMP =>
					reg_alt_addr <= temp;
				
				when RESET =>
					assert false report "NOT IMPLEMENTED" severity Failure;
				
				when None =>
					null;
				
				end case;
			end if;
		end if;
	end process;

end architecture;

