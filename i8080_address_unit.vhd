library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_address_unit is
	port (
		clk: in std_logic;
		cs: in address_control_signals;
		
		b, c, d, e, h, l: in std_logic_vector(7 downto 0);
		pc, sp: in std_logic_vector(15 downto 0);
		
		addr: out std_logic_vector(15 downto 0)
	);
end entity;

architecture pipeline_2_cycle of i8080_address_unit is
	signal bc, de, hl: std_logic_vector(15 downto 0) := X"0000";
	
	signal pc_to_hl_muxed:
		std_logic_vector(15 downto 0) := X"0000";
	signal sp_muxed:
		std_logic_vector(15 downto 0) := X"0000";

	signal addr_pre_offset: std_logic_vector(15 downto 0) := X"0000";
	signal addr_post_offset: std_logic_vector(15 downto 0) := X"0000";
begin
	-- Inputs
	bc <= b & c;
	de <= d & e;
	hl <= h & l;

	-- Outputs
	addr <= addr_post_offset;

	register_offset: process(clk, addr_pre_offset, cs.offset) is
	begin
		if rising_edge(clk) then
			addr_post_offset <= std_logic_vector(
				unsigned(addr_pre_offset) +
				to_unsigned(cs.offset, addr_pre_offset'length)
			);
		end if;
	end process;

	reg_mux_level_1: process(clk, cs.mode, pc_to_hl_muxed, sp_muxed) is
	begin
		if rising_edge(clk) then
		
			if cs.mode = ADDRMODE_PC
				or cs.mode = ADDRMODE_BC
				or cs.mode = ADDRMODE_DE
				or cs.mode = ADDRMODE_HL
			  then
				addr_pre_offset <= pc_to_hl_muxed;
			
			elsif cs.mode = ADDRMODE_SP
			  then
				addr_pre_offset <= sp_muxed;
				
			end if;
			
		end if;
	end process;

	reg_mux_level_0: process (pc, bc, de, hl, sp, cs.mode)
	is
	begin
		-- Limit muxes to 4 inputs
		case cs.mode is
			-- First mux
			when ADDRMODE_PC => pc_to_hl_muxed <= pc;
			when ADDRMODE_BC => pc_to_hl_muxed <= bc;
			when ADDRMODE_DE => pc_to_hl_muxed <= de;
			when ADDRMODE_HL => pc_to_hl_muxed <= hl;
			
			-- Second mux
			when ADDRMODE_SP => sp_muxed <= sp;

		end case;
		
	end process;
end architecture;

