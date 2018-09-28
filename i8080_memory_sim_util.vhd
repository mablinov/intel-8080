library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package i8080_memory_sim_util is
	subtype byte is std_logic_vector(7 downto 0);
	
	type i8080_mem_blk is array (natural range <>) of byte;
	type i8080_port_blk is array (natural range <>) of byte;
	
	constant i8080_mem_blk_default: i8080_mem_blk(0 to 255) := (
		others => (others => '0')
	);
	constant i8080_port_blk_default: i8080_port_blk(0 to 255) := (
		others => (others => '0')
	);

end package;

