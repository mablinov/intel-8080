library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_core is
	port (
		clk, en, reset: in std_logic;
		fin: in i8080_core_in;
		fout: out i8080_core_out := I8080_CORE_OUT_DEFAULT
	);
end;

architecture rtl of i8080_core is
	signal cs: cpu_control_signals := CPU_CONTROL_SIGNALS_DEFAULT;
	signal cpuinfo: ucode_ctrl_cpuinfo := (
		read_done => '0',
		cond => false,
		int => '0',
		ie => '0'
	);
	
	-- Output address register
	signal addr: std_logic_vector(15 downto 0) := X"0000";
	-- Output buffer for 16 bit loads so we dont clobber addr above mid instruction
	signal addr_buffer: std_logic_vector(15 downto 0) := X"0000";
	
	-- Data input register
	signal reg_di: std_logic_vector(7 downto 0) := X"00";
	-- Data output register
	signal reg_do: std_logic_vector(7 downto 0) := X"00";
	
	
	-- Interrupt enable
	signal reg_ie: std_logic := '0';
	
	-- Instruction register
	signal reg_ir: std_logic_vector(7 downto 0) := X"00";
	-- Program counter
	signal reg_pc: std_logic_vector(15 downto 0) := X"0000";

	-- Temporary register for indirect loads
	signal reg_temp: std_logic_vector(15 downto 0) := X"0000";

	signal reg_flags: std_logic_vector(7 downto 0) := X"00";

	-- Register file interface
	signal rf_di, rf_do: std_logic_vector(7 downto 0) := X"00";
	
	-- ALU interface
	signal alu_result: std_logic_vector(7 downto 0) := X"00";
	signal alu_lhs, alu_rhs: std_logic_vector(7 downto 0) := X"00";
	signal flags: i8080_flags := ('0', '1', '0', '1', '0');

	signal rp_tmp: std_logic_vector(15 downto 0) := X"0000";

	signal curr_cc: i8080_cond_code;
	signal curr_cc_value: boolean;
	
	signal reg_pc_buffer: std_logic_vector(15 downto 0) := X"0000";

	-- Helper signals (not used)
	signal curr_inst: inst_type := INST_NOP;
begin
	curr_inst <= get_inst(reg_ir);

	curr_cc <= get_cond_code(reg_ir);
	curr_cc_value <= eval_cond_code(curr_cc, flags);

	cpuinfo.read_done <= fin.ready;
	cpuinfo.cond <= curr_cc_value;
	cpuinfo.ie <= reg_ie;
	cpuinfo.int <= fin.int;

	fout.addr <= addr;
	fout.do <= reg_do;
	fout.port_en <= cs.m.port_en;
	fout.intack <= cs.uc.intack;
	fout.ie <= reg_ie;

	reg_ie_ctrl: process (clk, reset, cs.r.ie) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg_ie <= '0';
			
			else
				case cs.r.ie is
					when ENABLE =>
						reg_ie <= '1';
					when DISABLE =>
						reg_ie <= '0';
					when NONE =>
						null;
				end case;
			
			end if;
		end if;
	end process;

	reg_pc_buffer_ctrl: process (clk, cs.r.pc_buffer, reg_di) is
	begin
		if rising_edge(clk) then
			case cs.r.pc_buffer is
				when PC_BUFFER_LOAD_DATA_IN_LOW =>
					reg_pc_buffer(7 downto 0) <= reg_di;
				
				when PC_BUFFER_LOAD_DATA_IN_HIGH =>
					reg_pc_buffer(15 downto 8) <= reg_di;
				
				when NONE =>
					null;
			end case;
		end if;
	end process;

	rp_op_ctrl: process (clk, cs.r.rp, rf_do, rp_tmp) is
	begin
		if rising_edge(clk) then
			case cs.r.rp is
				when LOAD_RF_DO_HIGH =>
					rp_tmp(15 downto 8) <= rf_do;
				
				when LOAD_RF_DO_LOW =>
					rp_tmp(7 downto 0) <= rf_do;
				
				when RP_OP_INC =>
					rp_tmp <= std_logic_vector(unsigned(rp_tmp) + 1);
				
				when RP_OP_DEC =>
					rp_tmp <= std_logic_vector(unsigned(rp_tmp) - 1);
				
				when RP_OP_NONE =>
					null;
				
				when others =>
					assert false report "Unhandled case in rp_op_ctrl proc"
						severity Failure;
			end case;
		end if;
	end process;


	reg_do_ctrl: process (clk, cs.r.do, reg_di, rf_do, alu_result, flags, reg_pc)
	is
	begin
		if rising_edge(clk) then
			case cs.r.do is
				when LOAD_DI =>
					reg_do <= reg_di;
				
				when LOAD_RF =>
					reg_do <= rf_do;
				
				when LOAD_ALU =>
					reg_do <= alu_result;
				
				when LOAD_FLAGS =>
					reg_do <= get_flags_byte(flags);
				
				when LOAD_PC_LOW =>
					reg_do <= reg_pc(7 downto 0);
					
				when LOAD_PC_HIGH =>
					reg_do <= reg_pc(15 downto 8);
				
				when NONE =>
					null;
			end case;
		end if;
	end process;

	output_addr_ctrl: process (clk, reset, cs.a, rf_do, addr, reg_pc, reg_di) is
		function compute_addr_offset(addr: std_logic_vector(15 downto 0);
			offset: i8080_addr_offset_T) return std_logic_vector is
		begin
			return std_logic_vector(unsigned(addr) + to_unsigned(offset, addr'length));
		end function;
	begin
		if rising_edge(clk) then

			if reset = '1' then
				addr <= X"0000";
		
			else
				case cs.a.load is
					when LOAD_PC =>
						addr <= reg_pc;
				
					when LOAD_OFFSET =>
						addr <= compute_addr_offset(addr, cs.a.offset);
				
					when LOAD_RF_L =>
						addr(7 downto 0) <= rf_do;
				
					when LOAD_RF_H =>
						addr(15 downto 8) <= rf_do;
					
					when LOAD_DATA_IN =>
						addr(15 downto 8) <= reg_di;
						addr(7 downto 0) <= reg_di;
					
					when LOAD_DATA_IN_L =>
						addr(7 downto 0) <= reg_di;
					
					when LOAD_DATA_IN_H =>
						addr(15 downto 8) <= reg_di;
					
					when LOAD_BUFFER =>
						addr <= addr_buffer;
					
					when NONE =>
						null;
				end case;
			end if;
			
		end if;
	end process;
	
	addr_buffer_ctrl: process (clk, reset, cs.a.loadbuf, reg_di) is
	begin
		if rising_edge(clk) then
		
			if reset = '1' then
				addr_buffer <= X"0000";
			
			else
				case cs.a.loadbuf is
					when LOAD_DATA_IN_L =>
						addr_buffer(7 downto 0) <= reg_di;
					
					when LOAD_DATA_IN_H =>
						addr_buffer(15 downto 8) <= reg_di;
					
					when NONE =>
						null;
					
					when others =>
						null;
						assert false report "Invalid state for addr_buffer"
							severity Failure;
						
				end case;
			end if;
		end if;
	end process;
	
	-- Memory access controller
	mem_ctrl: process (cs.m.op) is
	begin
		case cs.m.op is
			when Idle =>
				fout.en <= '0';
				fout.wren <= '0';
		
			when Read =>
				fout.en <= '1';
				fout.wren <= '0';
		
			when Write =>
				fout.en <= '1';
				fout.wren <= '1';
		end case;
	end process;

	-- Data input register controller
	reg_di_ctrl: process (clk, reset, cs.r.di_ce, fin.di) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg_di <= X"00";
				
			elsif cs.r.di_ce = '1' then
				reg_di <= fin.di;
			
			end if;
		end if;
	end process;
		

	-- Instruction register controller
	reg_inst_ctrl: process (clk, reset, cs.r.ir_ce, reg_di) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg_ir <= X"00";
				
			elsif cs.r.ir_ce = '1' then
				reg_ir <= reg_di;
			
			end if;
		end if;
	end process;

	reg_pc_ctrl: process (clk, en, reset, cs.r.pc, reg_pc, reg_ir,
		rf_do, reg_di, reg_pc_buffer
	)
	is
		variable nia: std_logic_vector(15 downto 0) := X"0000";
		
		function get_nia(
			reg_pc: std_logic_vector(15 downto 0);
			reg_ir: std_logic_vector(7 downto 0)) return std_logic_vector
		is
			variable inst: inst_type := INST_NOP;
			variable inst_arg_count: natural := 0;
		begin
			inst := get_inst(reg_ir);
			inst_arg_count := get_inst_args(inst);
			
			return std_logic_vector(
				unsigned(reg_pc) + to_unsigned(inst_arg_count + 1, reg_pc'length)
			);
		end function;
	begin
		if rising_edge(clk) then
		
			if reset = '1' then
				reg_pc <= X"0000";
			
			else
				case cs.r.pc is
					when PC_LOAD_NIA =>
						reg_pc <= get_nia(reg_pc, reg_ir);
					
					when PC_LOAD_RF_LOW =>
						reg_pc(7 downto 0) <= rf_do;
					
					when PC_LOAD_RF_HIGH =>
						reg_pc(15 downto 8) <= rf_do;
					
					when PC_LOAD_DATA_IN_LOW =>
						reg_pc(7 downto 0) <= reg_di;
					
					when PC_LOAD_DATA_IN_HIGH =>
						reg_pc(15 downto 8) <= reg_di;
					
					when PC_LOAD_DATA_IN_COND_LOW =>
						if curr_cc_value then
							reg_pc(7 downto 0) <= reg_di;
						end if;
					
					when PC_LOAD_DATA_IN_COND_HIGH =>
						if curr_cc_value then
							reg_pc(15 downto 8) <= reg_di;
						end if;
					
					when PC_LOAD_BUFFER =>
						reg_pc <= reg_pc_buffer;
					
					when PC_LOAD_RESET_VECTOR =>
						reg_pc <= get_reset_vector_address(reg_ir);
					
					when NONE =>
						null;
				
				end case;
			
			end if;
		end if;
	end process;
	
	alu_input_select_L: process (cs.alu.lsel, rf_do) is
	begin
		case cs.alu.lsel is
			when ALU_INPUT_RF_DO =>
				alu_lhs <= rf_do;
			
			when others =>
				assert false report "Unhandled L case option in alu_input_select_L"
					severity Failure;
		end case;
	end process;
	
	alu_input_select_R: process (cs.alu.rsel, rf_do, reg_di) is
	begin
		case cs.alu.rsel is
			when ALU_INPUT_RF_DO =>
				alu_rhs <= rf_do;
			
			when ALU_INPUT_DATA_IN =>
				alu_rhs <= reg_di;
			
			when others =>
				assert false report "Unhandled R case option in alu_input_select_R"
					severity Failure;
		end case;
		
	end process;
	
	alu_inst: entity work.i8080_alu(rtl)
	port map (
		clk => clk,
		cs => cs.alu,
		
		lhs => alu_lhs, rhs => alu_rhs,
		result => alu_result,
		flags => flags
	);
	
	rf_di_select: process (cs.r.rf.sel_input_class, rf_do, reg_di, alu_result) is
	begin
		case cs.r.rf.sel_input_class is
			when RF_SEL_SELF =>
				rf_di <= rf_do;
				
			when RF_SEL_DATA_IN =>
				rf_di <= reg_di;
				
			when RF_SEL_ALU =>
				rf_di <= alu_result;
			
			when RF_SEL_RPOP_HIGH =>
				rf_di <= rp_tmp(15 downto 8);
			
			when RF_SEL_RPOP_LOW =>
				rf_di <= rp_tmp(7 downto 0);
			
		end case;
	end process;
	
	register_file: entity work.i8080_register_file(rtl)
	port map (
		clk => clk,
		cs => cs.r.rf,
		
		di => rf_di,
		do => rf_do
	);
	
	ucode_ctrl: entity work.i8080_microcode_controller(rtl)
	port map (
		clk => clk, en => en, reset => reset,
		inst_byte => reg_ir,
		cpuinfo => cpuinfo,
		cs => cs
	);

end architecture;

