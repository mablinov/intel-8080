library ieee;
use ieee.std_logic_1164.all;

use work.i8080_util.all;

package i8080_microcode_util is
	function get_rf_sel_LXI_low(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_LXI_high(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_MVI_R(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_rf_sel_MOV_RR_src(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_MOV_RR_dest(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_MOV_RM_src(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_MOV_MR_dest(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_rf_sel_LDAX_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_LDAX_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_STAX_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_STAX_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_rf_sel_INR(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_DCR(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_alu_op_ALU_IMMED(inst_byte: std_logic_vector(7 downto 0))
		return alu_operation;

	function get_rf_sel_INX_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_INX_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_rf_sel_DCX_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_DCX_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_rf_sel_DAD_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_DAD_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_r_do_sel_PUSH_L(inst_byte: std_logic_vector(7 downto 0))
		return reg_do_load_type;
	function get_r_do_sel_PUSH_H(inst_byte: std_logic_vector(7 downto 0))
		return reg_do_load_type;

	function get_rf_sel_PUSH_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_PUSH_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_rf_sel_POP_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;
	function get_rf_sel_POP_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

	function get_rf_wren_POP_H(inst_byte: std_logic_vector(7 downto 0))
		return std_logic;

	function get_alu_op_POP_H(inst_byte: std_logic_vector(7 downto 0))
		return alu_operation;

	function get_rf_wren_CPI_IMMED(inst_byte: std_logic_vector(7 downto 0))
		return std_logic;

	function get_rf_sel_ALU_R(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select;

end package;

package body i8080_microcode_util is
	function get_rf_sel_LXI_low(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_C;
			when "01" => sel := RF_E;
			when "10" => sel := RF_L;
			when "11" => sel := RF_SP_L;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_LXI_low"
					severity Failure;
		end case;
		
		return sel;
	end function;


	function get_rf_sel_LXI_high(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_B;
			when "01" => sel := RF_D;
			when "10" => sel := RF_H;
			when "11" => sel := RF_SP_H;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_LXI_high"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
	function get_rf_sel_MVI_R(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 3);
		
		case bitfield is
			when "000" => sel := RF_B;
			when "001" => sel := RF_C;
			when "010" => sel := RF_D;
			when "011" => sel := RF_E;
			when "100" => sel := RF_H;
			when "101" => sel := RF_L;
			when "110" =>
				assert false report "Bitfield corresponding to M fed to get_rf_sel_MVI_R"
					severity Failure;
			when "111" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_MVI_R"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
	function get_rf_sel_MOV_RR_src(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(2 downto 0);
		
		case bitfield is
			when "000" => sel := RF_B;
			when "001" => sel := RF_C;
			when "010" => sel := RF_D;
			when "011" => sel := RF_E;
			when "100" => sel := RF_H;
			when "101" => sel := RF_L;
			when "110" =>
				assert false report
					"Bitfield corresponding to M fed to get_rf_sel_MOV_RR_src"
						severity Failure;
			when "111" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_MOV_RR_src"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_sel_MOV_RR_dest(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 3);
		
		case bitfield is
			when "000" => sel := RF_B;
			when "001" => sel := RF_C;
			when "010" => sel := RF_D;
			when "011" => sel := RF_E;
			when "100" => sel := RF_H;
			when "101" => sel := RF_L;
			when "110" =>
				assert false report
					"Bitfield corresponding to M fed to get_rf_sel_MOV_RR_dest"
						severity Failure;
			when "111" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_MOV_RR_dest"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_sel_MOV_RM_src(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(2 downto 0);
		
		case bitfield is
			when "000" => sel := RF_B;
			when "001" => sel := RF_C;
			when "010" => sel := RF_D;
			when "011" => sel := RF_E;
			when "100" => sel := RF_H;
			when "101" => sel := RF_L;
			when "110" =>
				assert false report
					"Bitfield corresponding to M fed to get_rf_sel_MOV_RM_src"
						severity Failure;
			when "111" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_MOV_RM_src"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_sel_MOV_MR_dest(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 3);
		
		case bitfield is
			when "000" => sel := RF_B;
			when "001" => sel := RF_C;
			when "010" => sel := RF_D;
			when "011" => sel := RF_E;
			when "100" => sel := RF_H;
			when "101" => sel := RF_L;
			when "110" =>
				assert false report
					"Bitfield corresponding to M fed to get_rf_sel_MOV_MR_dest"
						severity Failure;
			when "111" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_MOV_MR_dest"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
	function get_rf_sel_LDAX_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable b: std_logic := '0';
	begin
		b := inst_byte(4);
		
		case b is
			when '0' => -- LOW of BC
				return RF_C;
			when '1' => -- LOW of DE
				return RF_E;
			when others =>
				assert false report "Invalid bit submitted to get_rf_sel_LDAX_L"
					severity Failure;
				return RF_C;
		end case;
	end function;
	
	function get_rf_sel_LDAX_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable b: std_logic := '0';
	begin
		b := inst_byte(4);
		
		case b is
			when '0' => -- HIGH of BC
				return RF_B;
			when '1' => -- HIGH of DE
				return RF_D;
			when others =>
				assert false report "Invalid bit submitted to get_rf_sel_LDAX_H"
					severity Failure;
				return RF_B;
		end case;
	end function;
	
	function get_rf_sel_STAX_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable b: std_logic := '0';
	begin
		b := inst_byte(4);
		
		case b is
			when '0' => -- LOW of BC
				return RF_C;
			when '1' => -- LOW of DE
				return RF_E;
			when others =>
				assert false report "Invalid bit submitted to get_rf_sel_STAX_L"
					severity Failure;
				return RF_C;
		end case;
	end function;
	
	function get_rf_sel_STAX_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable b: std_logic := '0';
	begin
		b := inst_byte(4);
		
		case b is
			when '0' => -- HIGH of BC
				return RF_B;
			when '1' => -- HIGH of DE
				return RF_D;
			when others =>
				assert false report "Invalid bit submitted to get_rf_sel_STAX_H"
					severity Failure;
				return RF_B;
		end case;
	end function;

	function get_rf_sel_INR(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 3);
		
		case bitfield is
			when "000" => sel := RF_B;
			when "001" => sel := RF_C;
			when "010" => sel := RF_D;
			when "011" => sel := RF_E;
			when "100" => sel := RF_H;
			when "101" => sel := RF_L;
			when "110" =>
				assert false report
					"Bitfield corresponding to M fed to get_rf_sel_INR"
						severity Failure;
			when "111" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_INR"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_sel_DCR(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 3);
		
		case bitfield is
			when "000" => sel := RF_B;
			when "001" => sel := RF_C;
			when "010" => sel := RF_D;
			when "011" => sel := RF_E;
			when "100" => sel := RF_H;
			when "101" => sel := RF_L;
			when "110" =>
				assert false report
					"Bitfield corresponding to M fed to get_rf_sel_DCR"
						severity Failure;
			when "111" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_DCR"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_alu_op_ALU_IMMED(inst_byte: std_logic_vector(7 downto 0))
		return alu_operation
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: alu_operation := ALU_OP_NONE;
	begin
		bitfield := inst_byte(5 downto 3);
		
		case bitfield is
			when "000" => sel := ALU_OP_ADD;
			when "001" => sel := ALU_OP_ADC;
			when "010" => sel := ALU_OP_SUB;
			when "011" => sel := ALU_OP_SBB;
			when "100" => sel := ALU_OP_AND;
			when "101" => sel := ALU_OP_XOR;
			when "110" => sel := ALU_OP_OR;
			when "111" => sel := ALU_OP_CPI;
			when others =>
				assert false report "Invalid bitfield for get_alu_op_ALU_IMMED"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_sel_INX_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_C;
			when "01" => sel := RF_E;
			when "10" => sel := RF_L;
			when "11" => sel := RF_SP_L;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_INX_L"
					severity Failure;
		end case;
		
		return sel;
	end function;


	function get_rf_sel_INX_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_B;
			when "01" => sel := RF_D;
			when "10" => sel := RF_H;
			when "11" => sel := RF_SP_H;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_INX_H"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_sel_DCX_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_C;
			when "01" => sel := RF_E;
			when "10" => sel := RF_L;
			when "11" => sel := RF_SP_L;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_DCX_L"
					severity Failure;
		end case;
		
		return sel;
	end function;


	function get_rf_sel_DCX_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_B;
			when "01" => sel := RF_D;
			when "10" => sel := RF_H;
			when "11" => sel := RF_SP_H;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_DCX_H"
					severity Failure;
		end case;
		
		return sel;
	end function;


	function get_rf_sel_DAD_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_C;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_C;
			when "01" => sel := RF_E;
			when "10" => sel := RF_L;
			when "11" => sel := RF_SP_L;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_DAD_L"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
	function get_rf_sel_DAD_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_B;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_B;
			when "01" => sel := RF_D;
			when "10" => sel := RF_H;
			when "11" => sel := RF_SP_H;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_DAD_H"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_r_do_sel_PUSH_H(inst_byte: std_logic_vector(7 downto 0))
		return reg_do_load_type
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: reg_do_load_type := LOAD_RF;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := LOAD_RF;
			when "01" => sel := LOAD_RF;
			when "10" => sel := LOAD_RF;
			when "11" => sel := LOAD_FLAGS;
			when others =>
				assert false report "Invalid bitfield for get_r_do_sel_PUSH_H"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
	function get_r_do_sel_PUSH_L(inst_byte: std_logic_vector(7 downto 0))
		return reg_do_load_type
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: reg_do_load_type := LOAD_RF;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := LOAD_RF;
			when "01" => sel := LOAD_RF;
			when "10" => sel := LOAD_RF;
			when "11" => sel := LOAD_RF;
			when others =>
				assert false report "Invalid bitfield for get_r_do_sel_PUSH_L"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_sel_PUSH_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_B;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_B;
			when "01" => sel := RF_D;
			when "10" => sel := RF_H;
			when "11" => sel := RF_A; -- This choice is redundant and unused anyway
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_PUSH_H"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
	function get_rf_sel_PUSH_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_B;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_C;
			when "01" => sel := RF_E;
			when "10" => sel := RF_L;
			when "11" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_PUSH_L"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
	function get_rf_sel_POP_L(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_B;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_C;
			when "01" => sel := RF_E;
			when "10" => sel := RF_L;
			when "11" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_POP_L"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
	function get_rf_sel_POP_H(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
		variable sel: register_file_select := RF_B;
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "00" => sel := RF_B;
			when "01" => sel := RF_D;
			when "10" => sel := RF_H;
			when "11" => sel := RF_A; -- this result should NOT BE USED
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_POP_H"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_wren_POP_H(inst_byte: std_logic_vector(7 downto 0))
		return std_logic
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "11" => return '0'; -- Indicates that we're popping PSW
			when others => return '1';
		end case;
	end function;

	function get_alu_op_POP_H(inst_byte: std_logic_vector(7 downto 0))
		return alu_operation
	is
		variable bitfield: std_logic_vector(1 downto 0) := "00";
	begin
		bitfield := inst_byte(5 downto 4);
		
		case bitfield is
			when "11" => return ALU_OP_LOAD_FLAGS; -- Indicates that we're popping PSW
			when others => return ALU_OP_NONE;
		end case;
	end function;

	function get_rf_wren_CPI_IMMED(inst_byte: std_logic_vector(7 downto 0))
		return std_logic
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: std_logic := '0';
	begin
		bitfield := inst_byte(5 downto 3);
		
		case bitfield is
			when "000" => sel := '1'; -- ALU_OP_ADD;
			when "001" => sel := '1'; -- ALU_OP_ADC;
			when "010" => sel := '1'; -- ALU_OP_SUB;
			when "011" => sel := '1'; -- ALU_OP_SBB;
			when "100" => sel := '1'; -- ALU_OP_AND;
			when "101" => sel := '1'; -- ALU_OP_XOR;
			when "110" => sel := '1'; -- ALU_OP_OR;
			when "111" => sel := '0'; -- ALU_OP_CPI;
			when others =>
				assert false report "Invalid bitfield for get_rf_wren_CPI_IMMED"
					severity Failure;
		end case;
		
		return sel;
	end function;

	function get_rf_sel_ALU_R(inst_byte: std_logic_vector(7 downto 0))
		return register_file_select
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable sel: register_file_select := RF_A;
	begin
		bitfield := inst_byte(2 downto 0);
		
		case bitfield is
			when "000" => sel := RF_B;
			when "001" => sel := RF_C;
			when "010" => sel := RF_D;
			when "011" => sel := RF_E;
			when "100" => sel := RF_H;
			when "101" => sel := RF_L;
			when "110" =>
				assert false report
					"Bitfield corresponding to M fed to get_rf_sel_ALU_R"
						severity Failure;
			when "111" => sel := RF_A;
			when others =>
				assert false report "Invalid bitfield for get_rf_sel_ALU_R"
					severity Failure;
		end case;
		
		return sel;
	end function;
	
end package body;

