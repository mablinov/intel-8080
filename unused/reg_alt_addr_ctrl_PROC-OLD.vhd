		reg_alt_addr_ctrl: process (clk, en, reset, cs.a.aa_load,
			bc, de, hl, reg_sp, reg_temp) is
		begin
			if rising_edge(clk) then
				if reset = '1' then
					reg_alt_addr <= X"0000";
			
				elsif en = '1' then
					case cs.a.aa_load is
					when LoadBC =>
						reg_alt_addr <= bc;
				
					when LoadDE =>
						reg_alt_addr <= de;
					
					when LoadHL =>
						reg_alt_addr <= hl;
					
					when LoadSP =>
						reg_alt_addr <= reg_sp;
				
					when LoadTEMP =>
						reg_alt_addr <= reg_temp;
				
					when LoadRESET =>
						assert false report "NOT IMPLEMENTED" severity Failure;
				
					when None =>
						null;
				
					end case;
				end if;
			end if;
		end process;