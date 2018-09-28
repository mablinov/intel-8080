library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_northbridge is
	port (
		clk, en, reset: in std_logic;
		
		cpu_di: in std_logic_vector(7 downto 0);
		cpu_do: out std_logic_vector(7 downto 0) := X"00";
		cpu_addr: in std_logic_vector(15 downto 0);
		cpu_m_en: in std_logic;
		cpu_m_wren: in std_logic;
		cpu_port_en: in std_logic;
		
		cpu_mem_op_done: out std_logic := '0'
	);
end;

