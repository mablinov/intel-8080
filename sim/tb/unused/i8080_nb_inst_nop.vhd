library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

architecture inst_NOP of i8080_northbridge is
	signal m_en_pline: std_logic_vector(0 to 1) := "00";
begin
	m_en_pline_ctrl_proc: process (clk, en, reset, cpu_m_en, m_en_pline) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				m_en_pline <= "00";
			
			elsif en = '1' then
				m_en_pline(0) <= cpu_m_en;
				m_en_pline(1) <= m_en_pline(0);
			
			end if;
		end if;
	end process;
	
	m_rq_ctrl_proc: process (clk, en, reset, m_en_pline) is
	begin
		if m_en_pline(1) = '1' then
			cpu_do <= X"00";
			cpu_mem_op_done <= '1';
		else
			cpu_do <= X"00";
			cpu_mem_op_done <= '0';
		end if;
	end process;
end;

