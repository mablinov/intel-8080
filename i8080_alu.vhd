library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;
use work.i8080_alu_util.all;

entity i8080_alu is
	port (
		clk: in std_logic;
		cs: in alu_control_signals;
		
		lhs, rhs: in std_logic_vector(7 downto 0);
		result: out std_logic_vector(7 downto 0) := X"00";
		flags: out i8080_flags := ('0', '1', '0', '1', '0')
	);
end entity;

architecture rtl of i8080_alu is
	signal reg_lhs, reg_rhs: std_logic_vector(7 downto 0) := X"00";
	signal reg_result: std_logic_vector(7 downto 0) := X"00";
	
	signal flagr: i8080_flags := ('0', '1', '0', '1', '0');
begin

	result <= reg_result;
	flags <= flagr;

	alu_ctrl: process (clk, reg_lhs, reg_rhs, flagr, cs) is
		variable lr_sum: signed(7 downto 0) := X"00";
		variable lr_sub: signed(7 downto 0) := X"00";
		
		variable add_result: signed(7 downto 0) := X"00";
		variable adc_result: signed(7 downto 0) := X"00";

		variable sub_result: signed(7 downto 0) := X"00";
		variable sbb_result: signed(7 downto 0) := X"00";

		variable carry_flag_slv: std_logic_vector(7 downto 0) := X"00";
		variable carry_flag_slv_inv: std_logic_vector(7 downto 0) := X"00";

		variable add_lhs: signed(7 downto 0) := X"00";
		variable add_rhs: signed(7 downto 0) := X"00";

		variable sub_lhs: signed(7 downto 0) := X"00";
		variable sub_rhs: signed(7 downto 0) := X"00";

		variable lhs_nibble_low: unsigned(3 downto 0) := X"0";
		variable lhs_nibble_high: unsigned(3 downto 0) := X"0";
		
		variable daa_aux_carry: std_logic := '1';
		variable daa_carry: std_logic := '0';
		variable daa_intermediate: unsigned(7 downto 0) := X"00";
		variable daa_result: unsigned(7 downto 0) := X"00";
		
		variable inc_result: unsigned(7 downto 0) := X"00";
		variable dec_result: unsigned(7 downto 0) := X"00";
	begin
		carry_flag_slv := "0000000" & flagr.carry;
		carry_flag_slv_inv := "0000000" & not flagr.carry;
	
		add_lhs := signed(reg_lhs);
		add_rhs := signed(reg_rhs);
		
		sub_lhs := signed(reg_lhs);
		sub_rhs := - signed(reg_rhs);
	
		lr_sum := add_lhs + add_rhs;
		lr_sub := sub_lhs + sub_rhs;

		add_result := lr_sum;
		adc_result := lr_sum + signed(carry_flag_slv);

		sub_result := lr_sub;
		sbb_result := lr_sub - signed(carry_flag_slv);

		-- DAA comb logic
		lhs_nibble_low := unsigned(reg_lhs(3 downto 0));
		
		if lhs_nibble_low > 9 or flagr.aux_carry = '1' then
			daa_intermediate := unsigned(reg_lhs) + 6;
			daa_aux_carry := get_aux_carry(unsigned(reg_lhs), to_unsigned(6, 8),
				daa_intermediate);
		else
			daa_intermediate := unsigned(reg_lhs);
			daa_aux_carry := '0';
		end if;
		
		lhs_nibble_high := daa_intermediate(7 downto 4);
		
		if lhs_nibble_high > 9 or flagr.carry = '1' then
			daa_result := daa_intermediate + unsigned'("01100000");
			daa_carry := get_carry(daa_intermediate, unsigned'("01100000"),
				daa_result);
		else
			daa_result := unsigned(daa_intermediate);
			daa_carry := '0';
		end if;
		
		inc_result := unsigned(reg_rhs) + 1;
		dec_result := unsigned(reg_rhs) - 1;

		if rising_edge(clk) then
			case cs.op is

				when ALU_OP_SET_SZP_FLAGS =>
					flagr.sign <= get_sign(reg_result);
					flagr.zero <= get_zero(reg_result);
					flagr.parity <= get_parity(reg_result);
			
				when ALU_OP_ADD =>
					reg_result <= std_logic_vector(add_result);

					flagr.carry <= get_carry(reg_lhs, reg_rhs, add_result);
					flagr.aux_carry <= get_aux_carry(reg_lhs, reg_rhs, add_result);

				when ALU_OP_ADC =>
					reg_result <= std_logic_vector(adc_result);

					flagr.carry <= get_carry(reg_lhs, reg_rhs, adc_result);
					flagr.aux_carry <= get_aux_carry(reg_lhs, reg_rhs, adc_result);
				
				when ALU_OP_SUB =>
					reg_result <= std_logic_vector(sub_result);

					flagr.carry <= not get_carry(sub_lhs, sub_rhs, sub_result);
					flagr.aux_carry <= get_aux_carry(sub_lhs, sub_rhs, sub_result);
					
				when ALU_OP_SBB =>
					reg_result <= std_logic_vector(sbb_result);
				
					flagr.carry <= not get_carry(sub_lhs, sub_rhs, sbb_result);
					flagr.aux_carry <= get_aux_carry(sub_lhs, sub_rhs, sbb_result);
				
				when ALU_OP_ADD_NOFLAGS =>
					reg_result <= std_logic_vector(add_result);
				
				when ALU_OP_CMA => -- For the complement accumulator instruction.
					reg_result <= not reg_lhs;
				
				when ALU_OP_STC =>
					flagr.carry <= '1';
				
				when ALU_OP_CMC =>
					flagr.carry <= not flagr.carry;
				
				
				when ALU_OP_RLC => -- Rotate accumulator left
					flagr.carry <= reg_lhs(7);
					
					reg_result <= reg_lhs(6 downto 0) & reg_lhs(7);
				
				when ALU_OP_RRC => -- Rotate accumulator right
					flagr.carry <= reg_lhs(0);
					
					reg_result <= reg_lhs(0) & reg_lhs(7 downto 1);
				
				when ALU_OP_RAL => -- Rotate accumulator left through carry
					flagr.carry <= reg_lhs(7);
					
					reg_result <= reg_lhs(6 downto 0) & flagr.carry;
				
				when ALU_OP_RAR => -- Rotate accumulator right through carry
					flagr.carry <= reg_lhs(0);
					
					reg_result <= flagr.carry & reg_lhs(7 downto 1);
				
				when ALU_OP_DAA =>
					-- We trigger on aux_carry because after an ADD of 0x9 + 0x11
					-- we get 0x4 which is less than 9 but should logically
					-- cause a rollover.
					
					reg_result <= std_logic_vector(daa_result);
					
					flagr.carry <= daa_carry;
					flagr.aux_carry <= daa_aux_carry;
				
				when ALU_OP_INC =>
					reg_result <= std_logic_vector(inc_result);

					-- NOTE: INC does not affect carry flag.
					-- flagr.carry <= get_carry(unsigned(reg_rhs), to_unsigned(1, 8), inc_result);
					flagr.aux_carry <= get_aux_carry(unsigned(reg_rhs), to_unsigned(1, 8), inc_result);

				
				when ALU_OP_DEC =>
					reg_result <= std_logic_vector(dec_result);

					-- NOTE: DEC does not affect carry flag.
					-- flagr.carry <= get_carry(unsigned(reg_rhs), to_unsigned(1, 8), dec_result);
					flagr.aux_carry <= get_aux_carry(unsigned(reg_rhs), to_unsigned(1, 8), dec_result);
				
				when ALU_OP_NONE =>
					null;
				
				when ALU_OP_AND =>
					reg_result <= reg_lhs and reg_rhs;
					-- From the docs: "The carry bit is reset to zero."
					flagr.carry <= '0';
				
				when ALU_OP_XOR =>
					reg_result <= reg_lhs xor reg_rhs;
					-- From the docs: "The carry bit is reset to zero."
					flagr.carry <= '0';
				
				when ALU_OP_OR =>
					reg_result <= reg_lhs or reg_rhs;
					-- From the docs: "The carry bit is reset to zero."
					flagr.carry <= '0';
				
				when ALU_OP_CPI =>
					-- Simulate a subtraction, but write accumulator to result
					-- unchanged.
					reg_result <= std_logic_vector(sub_result);
					
					flagr.carry <= not get_carry(sub_lhs, sub_rhs, sub_result);
					flagr.aux_carry <= get_aux_carry(sub_lhs, sub_rhs, sub_result);
				
				when ALU_DAD_LOW =>
					reg_result <= std_logic_vector(add_result);

					flagr.carry <= get_carry(reg_lhs, reg_rhs, add_result);
				
				when ALU_DAD_HIGH =>
					reg_result <= std_logic_vector(adc_result);

					flagr.carry <= get_carry(reg_lhs, reg_rhs, adc_result);

				when ALU_OP_LOAD_FLAGS =>
					flagr <= get_flags_from_byte(reg_rhs);

				when others =>
					assert false report "alu_ctrl proc: unimplemented operand"
						severity Failure;
			end case;
		end if;
		
		
	end process;
	
	reg_init_ctrl: process (clk, cs.lhs_ce, cs.rhs_ce, lhs, rhs) is
	begin
		if rising_edge(clk) then
			if cs.lhs_ce = '1' then
				reg_lhs <= lhs;
			end if;
			
			if cs.rhs_ce = '1' then
				reg_rhs <= rhs;
			end if;
		end if;
	end process;
	
end architecture;

