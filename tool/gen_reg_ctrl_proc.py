template = \
"""	reg_{}_ctrl: process (clk, en, reset, cs.r.{}, reg_db) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg_{} <= X"00";
			
			elsif en = '1' then
				case cs.r.{} is
					when Databus =>
						reg_{} <= reg_db;
					
					when None =>
						null;
				end case;
			end if;
		end if;
	end process;"""

regs = ["db", "pc", "ir", "a", "flags", "b", "c", "d", "e", "h", "l", "sp_high", "sp_low"]

for i in regs:
	print(template.format(i, i, i, i, i))

