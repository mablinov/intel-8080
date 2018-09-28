library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.txt_util.all;

package i8080_util is

	type i8080_flags is record
		sign: std_logic;
		zero: std_logic;
		aux_carry: std_logic;
		parity: std_logic; -- '1' if even number of bits present.
		carry: std_logic;
	end record;

	function get_flags_byte(flags: i8080_flags) return std_logic_vector;
	function get_flags_from_byte(flags_byte: std_logic_vector(7 downto 0))
		return i8080_flags;
	

	type i8080_cond_code is (C_CARRY, C_NCARRY, C_ZERO, C_NZERO, C_MINUS,
		C_PLUS, C_EPARITY, C_OPARITY);
	function get_cond_code(ib: std_logic_vector(7 downto 0))
		return i8080_cond_code;
	function eval_cond_code(cc: i8080_cond_code; flags: i8080_flags)
		return boolean;

	type microinstruction is
	(
		inst_LXI_0, inst_LXI_1, inst_LXI_2, inst_LXI_3, inst_LXI_4,
		inst_LXI_5, inst_LXI_6, inst_LXI_7, inst_LXI_8, inst_LXI_9,
		
		inst_MVI_R_0, inst_MVI_R_1, inst_MVI_R_2, inst_MVI_R_3,
		inst_MVI_R_4,
		
		inst_MVI_M_0, inst_MVI_M_1, inst_MVI_M_2, inst_MVI_M_3,
		inst_MVI_M_4, inst_MVI_M_5, inst_MVI_M_6, inst_MVI_M_7,
		inst_MVI_M_8, inst_MVI_M_9,
		
		inst_STA_0, inst_STA_1, inst_STA_2, inst_STA_3, inst_STA_4,
		inst_STA_5, inst_STA_6, inst_STA_7, inst_STA_8, inst_STA_9,
		inst_STA_10, inst_STA_11, inst_STA_12, inst_STA_13,

		inst_LDA_0, inst_LDA_1, inst_LDA_2, inst_LDA_3, inst_LDA_4,
		inst_LDA_5, inst_LDA_6, inst_LDA_7, inst_LDA_8, inst_LDA_9,
		inst_LDA_10, inst_LDA_11, inst_LDA_12, inst_LDA_13, inst_LDA_14,

		inst_SHLD_0, inst_SHLD_1, inst_SHLD_2, inst_SHLD_3, inst_SHLD_4,
		inst_SHLD_5, inst_SHLD_6, inst_SHLD_7, inst_SHLD_8, inst_SHLD_9,
		inst_SHLD_10, inst_SHLD_11, inst_SHLD_12, inst_SHLD_13, inst_SHLD_14,
		inst_SHLD_15, inst_SHLD_16, inst_SHLD_17,

		inst_LHLD_0, inst_LHLD_1, inst_LHLD_2, inst_LHLD_3, inst_LHLD_4,
		inst_LHLD_5, inst_LHLD_6, inst_LHLD_7, inst_LHLD_8, inst_LHLD_9,
		inst_LHLD_10, inst_LHLD_11, inst_LHLD_12, inst_LHLD_13, inst_LHLD_14,
		inst_LHLD_15, inst_LHLD_16, inst_LHLD_17, inst_LHLD_18, inst_LHLD_19,

		inst_MOV_RR_0, inst_MOV_RR_1,

		inst_MOV_RM_0, inst_MOV_RM_1, inst_MOV_RM_2, inst_MOV_RM_3,
		inst_MOV_RM_4, inst_MOV_RM_5, inst_MOV_RM_6,
		
		inst_MOV_MR_0, inst_MOV_MR_1, inst_MOV_MR_2, inst_MOV_MR_3,
		inst_MOV_MR_4, inst_MOV_MR_5, inst_MOV_MR_6, inst_MOV_MR_7,
		inst_MOV_MR_8, inst_MOV_MR_9, inst_MOV_MR_10, inst_MOV_MR_11,
		inst_MOV_MR_12, inst_MOV_MR_13, inst_MOV_MR_14,

		inst_STAX_0, inst_STAX_1, inst_STAX_2, inst_STAX_3,
		inst_STAX_4, inst_STAX_5, inst_STAX_6,
		
		inst_LDAX_0, inst_LDAX_1, inst_LDAX_2, inst_LDAX_3,
		inst_LDAX_4, inst_LDAX_5, inst_LDAX_6, inst_LDAX_7,

		inst_INR_R_0, inst_INR_R_1, inst_INR_R_2, inst_INR_R_3,
		inst_INR_R_4,

		inst_INR_M_0, inst_INR_M_1, inst_INR_M_2, inst_INR_M_3,
		inst_INR_M_4, inst_INR_M_5, inst_INR_M_6, inst_INR_M_7,
		inst_INR_M_8, inst_INR_M_9, inst_INR_M_10, inst_INR_M_11,

		inst_DCR_R_0, inst_DCR_R_1, inst_DCR_R_2, inst_DCR_R_3,
		inst_DCR_R_4,

		inst_DCR_M_0, inst_DCR_M_1, inst_DCR_M_2, inst_DCR_M_3,
		inst_DCR_M_4, inst_DCR_M_5, inst_DCR_M_6, inst_DCR_M_7,
		inst_DCR_M_8, inst_DCR_M_9, inst_DCR_M_10, inst_DCR_M_11,

		inst_CMA_0, inst_CMA_1, inst_CMA_2, inst_CMA_3,

		inst_DAA_0, inst_DAA_1, inst_DAA_2, inst_DAA_3,
		inst_DAA_4,

		inst_CMC_0,
		
		inst_STC_0,

		inst_ALU_IMMED_0, inst_ALU_IMMED_1, inst_ALU_IMMED_2, inst_ALU_IMMED_3,
		inst_ALU_IMMED_4, inst_ALU_IMMED_5, inst_ALU_IMMED_6, inst_ALU_IMMED_7,
		inst_ALU_IMMED_8, inst_ALU_IMMED_9,

		inst_XCHG_0, inst_XCHG_1, inst_XCHG_2, inst_XCHG_3, inst_XCHG_4,
		inst_XCHG_5, inst_XCHG_6, inst_XCHG_7, inst_XCHG_8, inst_XCHG_9,

		inst_XTHL_0, inst_XTHL_1, inst_XTHL_2, inst_XTHL_3, inst_XTHL_4,
		inst_XTHL_5, inst_XTHL_6, inst_XTHL_7, inst_XTHL_8, inst_XTHL_9,
		inst_XTHL_10, inst_XTHL_11, inst_XTHL_12, inst_XTHL_13, inst_XTHL_14,
		inst_XTHL_15, inst_XTHL_16, inst_XTHL_17, inst_XTHL_18,

		inst_INX_0, inst_INX_1, inst_INX_2, inst_INX_3, inst_INX_4,
		inst_INX_5, inst_INX_6,

		inst_DCX_0, inst_DCX_1, inst_DCX_2, inst_DCX_3, inst_DCX_4,
		inst_DCX_5, inst_DCX_6,
		
		inst_DAD_0, inst_DAD_1, inst_DAD_2, inst_DAD_3, inst_DAD_4,
		inst_DAD_5, inst_DAD_6, inst_DAD_7, inst_DAD_8, inst_DAD_9,
		inst_DAD_10, inst_DAD_11,
		
		inst_SPHL_0, inst_SPHL_1, inst_SPHL_2, inst_SPHL_3,
		
		inst_PUSH_0, inst_PUSH_1, inst_PUSH_2, inst_PUSH_3,
		inst_PUSH_4, inst_PUSH_5, inst_PUSH_6, inst_PUSH_7,
		inst_PUSH_8, inst_PUSH_9, inst_PUSH_10, inst_PUSH_11,
		inst_PUSH_12, inst_PUSH_13, inst_PUSH_14, inst_PUSH_15,
		
		inst_POP_0, inst_POP_1, inst_POP_2, inst_POP_3, inst_POP_4,
		inst_POP_5, inst_POP_6, inst_POP_7, inst_POP_8, inst_POP_9,
		inst_POP_10, inst_POP_11, inst_POP_12, inst_POP_13, inst_POP_14,
		inst_POP_15, inst_POP_16, inst_POP_17,

		inst_PCHL_0, inst_PCHL_1, inst_PCHL_2, inst_PCHL_3,
		
		inst_JMP_0, inst_JMP_1, inst_JMP_2, inst_JMP_3, inst_JMP_4,
		inst_JMP_5, inst_JMP_6, inst_JMP_7, inst_JMP_8, inst_JMP_9,

		inst_JMP_COND_0, inst_JMP_COND_1, inst_JMP_COND_2,
		inst_JMP_COND_3, inst_JMP_COND_4, inst_JMP_COND_5,
		inst_JMP_COND_6, inst_JMP_COND_7, inst_JMP_COND_8,
		inst_JMP_COND_9,

		inst_CALL_0, inst_CALL_1, inst_CALL_2, inst_CALL_3, inst_CALL_4,
		inst_CALL_5, inst_CALL_6, inst_CALL_7, inst_CALL_8, inst_CALL_9,
		inst_CALL_10, inst_CALL_11, inst_CALL_12, inst_CALL_13, inst_CALL_14,
		inst_CALL_15, inst_CALL_16, inst_CALL_17, inst_CALL_18, inst_CALL_19,
		inst_CALL_20, inst_CALL_21, inst_CALL_22, inst_CALL_23, inst_CALL_24,

		inst_CALL_COND_M1,
		inst_CALL_COND_0, inst_CALL_COND_1, inst_CALL_COND_2, inst_CALL_COND_3,
		inst_CALL_COND_4, inst_CALL_COND_5, inst_CALL_COND_6, inst_CALL_COND_7,
		inst_CALL_COND_8, inst_CALL_COND_9,	inst_CALL_COND_10, inst_CALL_COND_11,
		inst_CALL_COND_12, inst_CALL_COND_13, inst_CALL_COND_14, inst_CALL_COND_15,
		inst_CALL_COND_16, inst_CALL_COND_17, inst_CALL_COND_18, inst_CALL_COND_19,
		inst_CALL_COND_20, inst_CALL_COND_21, inst_CALL_COND_22, inst_CALL_COND_23,
		inst_CALL_COND_24,
		
		
		inst_RET_0, inst_RET_1, inst_RET_2, inst_RET_3, inst_RET_4,
		inst_RET_5, inst_RET_6, inst_RET_7, inst_RET_8, inst_RET_9,
		inst_RET_10, inst_RET_11, inst_RET_12, inst_RET_13, inst_RET_14,
		inst_RET_15, inst_RET_16, inst_RET_17,
		
		
		inst_RET_COND_M1,
		inst_RET_COND_0, inst_RET_COND_1, inst_RET_COND_2, inst_RET_COND_3,
		inst_RET_COND_4, inst_RET_COND_5, inst_RET_COND_6, inst_RET_COND_7,
		inst_RET_COND_8, inst_RET_COND_9, inst_RET_COND_10, inst_RET_COND_11,
		inst_RET_COND_12, inst_RET_COND_13, inst_RET_COND_14, inst_RET_COND_15,
		inst_RET_COND_16, inst_RET_COND_17,
		
		inst_ALU_R_0, inst_ALU_R_1, inst_ALU_R_2, inst_ALU_R_3,
		inst_ALU_R_4, inst_ALU_R_5, inst_ALU_R_6,

		inst_ALU_M_0, inst_ALU_M_1, inst_ALU_M_2, inst_ALU_M_3,
		inst_ALU_M_4, inst_ALU_M_5, inst_ALU_M_6, inst_ALU_M_7,
		inst_ALU_M_8, inst_ALU_M_9, inst_ALU_M_10, inst_ALU_M_11,
		inst_ALU_M_12,
		
		inst_EI_0,
		inst_DI_0,
		
		inst_IN_0, inst_IN_1, inst_IN_2, inst_IN_3, inst_IN_4, inst_IN_5,
		inst_IN_6, inst_IN_7, inst_IN_8,

		inst_OUT_0, inst_OUT_1, inst_OUT_2, inst_OUT_3, inst_OUT_4,
		inst_OUT_5, inst_OUT_6, inst_OUT_7,
		
		inst_RST_0, inst_RST_1, inst_RST_2, inst_RST_3, inst_RST_4,
		inst_RST_5, inst_RST_6, inst_RST_7, inst_RST_8, inst_RST_9,
		inst_RST_10, inst_RST_11, inst_RST_12, inst_RST_13, inst_RST_14,
		
		inst_HW_INT_0, inst_HW_INT_1, inst_HW_INT_2, inst_HW_INT_3, inst_HW_INT_4,
		inst_HW_INT_5, inst_HW_INT_6, inst_HW_INT_7, inst_HW_INT_8, inst_HW_INT_9,
		inst_HW_INT_10, inst_HW_INT_11, inst_HW_INT_12, inst_HW_INT_13, inst_HW_INT_14,
		inst_HW_INT_15, inst_HW_INT_16, inst_HW_INT_17, inst_HW_INT_18, inst_HW_INT_19,

		
		inst_HALT_0,

		fetch_inst_0, fetch_inst_1, fetch_inst_2, fetch_inst_3,
		fetch_inst_4, fetch_inst_5, fetch_inst_6, fetch_inst_7
	);

	type memory_operation is (Idle, Read, Write);
	
	type memory_control_signals is record
		op: memory_operation;
		port_en: std_logic;
	end record;
	constant MEMORY_CONTROL_SIGNALS_DEFAULT: memory_control_signals := (
		op => Idle,
		port_en => '0'
	);


	type address_load_mode is (
		NONE,
		LOAD_PC, LOAD_OFFSET,
		LOAD_RF_L, LOAD_RF_H,
		LOAD_DATA_IN,
		LOAD_DATA_IN_L, LOAD_DATA_IN_H,
		LOAD_BUFFER
	);

	subtype i8080_addr_offset_T is integer range -1 to 2;

	type address_control_signals is record
		load: address_load_mode;
		loadbuf: address_load_mode;
		offset: i8080_addr_offset_T;
	end record;
	constant ADDRESS_CONTROL_SIGNALS_DEFAULT: address_control_signals := (
		load => NONE,
		loadbuf => NONE,
		offset => 0
	);
	
	
	type alu_operation is (
		ALU_OP_SET_SZP_FLAGS,
		ALU_OP_ADD,
		ALU_OP_ADC,
		ALU_OP_SUB,
		ALU_OP_SBB,
		ALU_OP_ADD_NOFLAGS,
		ALU_OP_CMA,
		ALU_OP_STC,
		ALU_OP_CMC,
		
		ALU_OP_RLC,
		ALU_OP_RRC,
		ALU_OP_RAL,
		ALU_OP_RAR,
		
		ALU_OP_DAA,
		
		ALU_OP_INC,
		ALU_OP_DEC,
		
		ALU_OP_AND,
		ALU_OP_XOR,
		ALU_OP_OR,
		ALU_OP_CPI,
		
		ALU_DAD_LOW,
		ALU_DAD_HIGH,
		
		ALU_OP_LOAD_FLAGS,
		
		ALU_OP_NONE
	);
	
	type alu_lsel_class is (ALU_INPUT_RF_DO);
	type alu_rsel_class is (ALU_INPUT_RF_DO, ALU_INPUT_DATA_IN);
	
	type alu_control_signals is record
		op: alu_operation;
		lhs_ce, rhs_ce: std_logic;
		lsel: alu_lsel_class;
		rsel: alu_rsel_class;
	end record;
	constant ALU_CONTROL_SIGNALS_DEFAULT: alu_control_signals := (
		op => ALU_OP_NONE,
		lhs_ce => '0', rhs_ce => '0',
		lsel => ALU_INPUT_RF_DO,
		rsel => ALU_INPUT_RF_DO
	);
	
	-- Register types
	type register_file_select is (
		RF_A,
		RF_B, RF_C,
		RF_D, RF_E,
		RF_H, RF_L,
		RF_SP_H, RF_SP_L
	);
	
	type regfile_input_class is (
		RF_SEL_SELF, RF_SEL_DATA_IN, RF_SEL_ALU, RF_SEL_RPOP_HIGH,
		RF_SEL_RPOP_LOW
	);
	
	type register_file_control_signals is record
		sel_input_class: regfile_input_class;
		sel: register_file_select;
		en: std_logic;
		wren: std_logic;
	end record;
	constant REGISTER_FILE_CONTROL_SIGNALS_DEFAULT: register_file_control_signals := (
		sel_input_class => RF_SEL_SELF,
		sel => RF_A,
		en => '0',
		wren => '0'
	);


	-- NIA: "Next Instruction Address"
	type reg_pc_load_type is (NONE, PC_LOAD_NIA, PC_LOAD_RF_LOW,
		PC_LOAD_RF_HIGH, PC_LOAD_DATA_IN_LOW, PC_LOAD_DATA_IN_HIGH,
		PC_LOAD_DATA_IN_COND_LOW, PC_LOAD_DATA_IN_COND_HIGH, PC_LOAD_BUFFER,
		PC_LOAD_RESET_VECTOR
	);
	
	type reg_pc_buffer_load_type is (NONE, PC_BUFFER_LOAD_DATA_IN_LOW,
		PC_BUFFER_LOAD_DATA_IN_HIGH);
		
	type reg_do_load_type is (NONE, LOAD_DI, LOAD_RF, LOAD_ALU, LOAD_FLAGS,
		LOAD_PC_LOW, LOAD_PC_HIGH);
	type reg_pair_operation is (RP_OP_NONE, LOAD_RF_DO_HIGH, LOAD_RF_DO_LOW, RP_OP_INC,
		RP_OP_DEC);
	type reg_ie_operation is (NONE, ENABLE, DISABLE);

	type register_control_signals is record
		di_ce: std_logic;
		do: reg_do_load_type;
		ir_ce: std_logic;
		pc: reg_pc_load_type;
		pc_buffer: reg_pc_buffer_load_type;
		rf: register_file_control_signals;
		rp: reg_pair_operation;
		ie: reg_ie_operation;
	end record;
	constant REGISTER_CONTROL_SIGNALS_DEFAULT: register_control_signals := (
		do => NONE,
		ir_ce => '0',
		di_ce => '0',
		pc => None,
		pc_buffer => None,
		rf => REGISTER_FILE_CONTROL_SIGNALS_DEFAULT,
		rp => RP_OP_NONE,
		ie => NONE
	);
	
	type microcode_operation is (
		Jump_next_when_read_complete,
		Jump_next, -- Simply execute the next uinstruction after the current
		Jump_fetch_inst_0, -- Jump to uinstruction 'fetch_inst_0'
		Jump_fetch_inst_0_COND, -- conditional version of above
		-- Actually jump to the uinstruction that corresponds to the byte that
		-- is currently loaded into the instruction register
		Jump_inst_byte,
		Try_jump_to_int_handler
	);
	
	
	type microcode_control_signals is record
		op: microcode_operation;
		intack: std_logic;
	end record;
	constant MICROCODE_CONTROL_SIGNALS_DEFAULT: microcode_control_signals := (
		op => Jump_next,
		intack => '0'
	);
	
	type cpu_control_signals is record
		m: memory_control_signals;
		a: address_control_signals;
		uc: microcode_control_signals;
		r: register_control_signals;
		alu: alu_control_signals;
	end record;
	constant CPU_CONTROL_SIGNALS_DEFAULT: cpu_control_signals := (
		m => MEMORY_CONTROL_SIGNALS_DEFAULT,
		a => ADDRESS_CONTROL_SIGNALS_DEFAULT,
		uc => MICROCODE_CONTROL_SIGNALS_DEFAULT,
		r => REGISTER_CONTROL_SIGNALS_DEFAULT,
		alu => ALU_CONTROL_SIGNALS_DEFAULT
	);

	type i8080_core_in is record
		di: std_logic_vector(7 downto 0);
		ready: std_logic;
		int: std_logic;
	end record;
	constant I8080_CORE_IN_DEFAULT: i8080_core_in := (
		di => X"00",
		ready => '0',
		int => '0'
	);
	
	type i8080_core_out is record
		addr: std_logic_vector(15 downto 0);
		do: std_logic_vector(7 downto 0);
		en: std_logic;
		wren: std_logic;
		port_en: std_logic;
		intack: std_logic;
		ie: std_logic;
	end record;
	constant I8080_CORE_OUT_DEFAULT: i8080_core_out := (
		addr => X"0000",
		do => X"00",
		en => '0',
		wren => '0',
		port_en => '0',
		intack => '0',
		ie => '0'
	);

	type ucode_ctrl_cpuinfo is record
		read_done: std_logic;
		cond: boolean;
		int: std_logic;
		ie: std_logic;
	end record;

	type inst_type is (
		INST_CALL,
		INST_CALL_COND,
		INST_RET,
		INST_RET_COND,
		INST_RESET,
		INST_IN, INST_OUT,
		INST_LXI,
		INST_PUSH, INST_POP,
		INST_STA, INST_LDA,
		INST_XCHG, INST_XTHL,
		INST_SPHL, INST_PCHL,
		INST_DAD,
		INST_STAX, INST_LDAX,
		INST_INX,
		INST_MOV,
		INST_MVI,
		INST_INR,
		INST_DCR,
		INST_ALU_RM,
		INST_ALU_IMMED,
		INST_ROTATE,
		INST_JMP,
		INST_JMP_COND,
		INST_DCX,
		INST_CMA,
		INST_STC,
		INST_CMC,
		INST_DAA,
		INST_SHLD,
		INST_LHLD,
		INST_EI,
		INST_DI,
		INST_NOP
	);
	

	
	constant TOTAL_INST_COUNT: natural := inst_type'pos(inst_type'right) + 1;
	
	type inst_class is record
		op: std_logic_vector(7 downto 0);
		mask: std_logic_vector(7 downto 0);
		inst: inst_type;
		args: natural range 0 to 2; -- number of arguments in bytes
	end record;
	
	type inst_class_vector is array (natural range <>)
		of inst_class;
	
	constant inst_class_tab: inst_class_vector :=
	(
		-- Call
		("11001101", "11111111", INST_CALL, 2),
		-- Call conditional: CNZ, CZ/CALL, CNC, CC, CPO, CPE, CP, CM
		("11000100", "11000111", INST_CALL_COND, 2),
		-- Return
		("11001001", "11111111", INST_RET, 0),
		-- Return conditional: RNZ, RZ/RET, RNC, RC, RPO, RPE, RP, RM
		("11000000", "11000111", INST_RET_COND, 0),
	
		-- Bitfield encodes offset into memory
		("11000111", "11000111", INST_RESET, 0),
	
		-- outport/inport instructions
		("11011011", "11111111", INST_IN, 1),
		("11010011", "11111111", INST_OUT, 1),
	
		-- Load register pair immediate
		("00000001", "11001111", INST_LXI, 2),
		-- Push register pair BC, DE, HL, PSW
		("11000101", "11001111", INST_PUSH, 0),
		-- Pop into register pair BC, DE, HL, PSW
		("11000001", "11001111", INST_POP, 0),
	
		-- Store register A into given immediate memory location
		("00110010", "11111111", INST_STA, 2),
		-- Load register A from given immediate memory location
		("00111010", "11111111", INST_LDA, 2),
	
		-- Swap the contents of HL and DE registers
		("11101011", "11111111", INST_XCHG, 0),
		-- Swap the contents of HL and *SP registers
		("11100011", "11111111", INST_XTHL, 0),
	
		-- Load SP from HL
		("11111001", "11111111", INST_SPHL, 0),
		-- Load PC from HL (effective JMP)
		("11101001", "11111111", INST_PCHL, 0),
	
		-- Add given register pair to HL and store result in HL
		("00001001", "11001111", INST_DAD, 0),
	
		-- Store accumulator to memory location *BC or *DE, depending on bitfield
		("00000010", "11101111", INST_STAX, 0),
		-- Load accumulator from memory location *BC or *DE, depending on bitfield
		("00001010", "11101111", INST_LDAX, 0),
	
		-- Increment register pair BC, DE, HL, SP
		("00000011", "11001111", INST_INX, 0),
	
		-- Move register to register (but mask = "110110" is halt)
		("01000000", "11000000", INST_MOV, 0),
	
		-- if mask is = "110", then move immed8 to *HL. Otherwise, move immed8 to reg.
		("00000110", "11000111", INST_MVI, 1), -- FIXME should this be zero or 1??
	
		-- if mask is = "110", then increment *HL. Otherwise, increment reg.
		("00000100", "11000111", INST_INR, 0),
	
		-- if mask is = "110", then decrement *HL. Otherwise, decrement reg.
		("00000101", "11000111", INST_DCR, 0),
	
		-- if second mask is="110", then operate with *HL. normally operate with reg.
		-- (b c d e h l *HL a)
		-- first mask dictates operation: add adc sub sbb ana xra ora cmp 
		("10000000", "11000000", INST_ALU_RM, 0),
	
		-- Operate on the A register with an immediate byte operand
		("11000110", "11000111", INST_ALU_IMMED, 1),
		
		-- Bitfield: RLC RRC RAL RAR
		("00000111", "11100111", INST_ROTATE, 0),
	
		-- Unconditional jump
		("11000011", "11111111", INST_JMP, 2),

		-- Bitfield: JMP JZ JNC JC JPO JPE JP JM	
		("11000010", "11000111", INST_JMP_COND, 2),
	
		-- Decrement register pair: BC, DE, HL, SP
		("00001011", "11001111", INST_DCX, 0),
	
		-- Complement accumulator and store to accumulator
		("00101111", "11111111", INST_CMA, 0),
	
		-- Set carry flag
		("00110111", "11111111", INST_STC, 0),
		-- Complement carry flag
		("00111111", "11111111", INST_CMC, 0),
	
		-- Decimal adjust A register (convert to BCD)
		("00100111", "11111111", INST_DAA, 0),
	
		-- Store HL to given address
		("00100010", "11111111", INST_SHLD, 2),
		-- Load HL from given address
		("00101010", "11111111", INST_LHLD, 2),
	
		-- Enable interrupts
		("11111011", "11111111", INST_EI, 0),
		-- Disable interrupts
		("11110011", "11111111", INST_DI, 0),
	
		-- Try execute next byte
		("00000000", "11111111", INST_NOP, 0),
	
		-- Some more NOPS
		("00000000", "11001111", INST_NOP, 0), -- alternate nops (except X"00")
		("00001000", "11001111", INST_NOP, 0), -- alternate nops
		
		("11011001", "11111111", INST_NOP, 0), -- alternate RET
		("11001011", "11111111", INST_NOP, 0), -- alternate JMP
		
		("11011101", "11111111", INST_NOP, 0), -- alternate CALL
		("11101101", "11111111", INST_NOP, 0), -- alternate CALL
		("11111101", "11111111", INST_NOP, 0) -- alternate CALL
	);
	
	function get_inst(inst_byte: std_logic_vector(7 downto 0)) return inst_type;
	function get_inst_args(it: inst_type) return natural;
	
	function get_ucode_routine(ib: std_logic_vector(7 downto 0); it: inst_type) return microinstruction;
	
	function get_next_ui(ui: microinstruction) return microinstruction;

	function get_reset_vector_address(inst_byte: std_logic_vector(7 downto 0))
		return std_logic_vector;
end package;

package body i8080_util is
	function get_next_ui(ui: microinstruction) return microinstruction is
	begin
		if ui = microinstruction'right then
			return microinstruction'left;
			report "Caught microinstruction overflow (probably false alarm)"
				severity warning;
		else
			return microinstruction'succ(ui);
		end if;
	end function;

	function get_ucode_routine(ib: std_logic_vector(7 downto 0);
		it: inst_type) return microinstruction is
	begin
		-- For the most part, there is a one-to-one correspondence between
		-- the 'inst_type' and 'microinstruction'. However, instructions
		-- such as "MOV" have non-trivial configurations, in this case it is
		-- the MOV *HL -> *HL, which is actually a HALT instruction, and
		-- MVI, which moves an immed8 to a reg UNLESS the bitmask is "110",
		-- in which case we must do a complex memory operation with HL. For that
		-- we would prefer to have a seperate handler, so we fix-up the 
		-- microinstruction depending on the bitmasks, where neccesary.
		
		case it is
--		when INST_LXI => return inst_lxi_0;

--		when INST_NOP => return inst_nop_0;
		when INST_NOP => return fetch_inst_0;
		-- I dont know why i went for the first option. I cannot see how it
		-- isnt redundant, but i leave it here just in case there was a
		-- good reason that i've forgotten and cannot work out right now.		
		
		when INST_LXI => return inst_LXI_0;
		
		when INST_MVI =>
			if ib(5 downto 3) = "110" then
				return inst_MVI_M_0;
			else
				return inst_MVI_R_0;
			end if;
		
		when INST_STA => return inst_STA_0;
		when INST_LDA => return inst_LDA_0;
		when INST_SHLD => return inst_SHLD_0;
		when INST_LHLD => return inst_LHLD_0;
		
		when INST_MOV =>
			report "Got INST_MOV";
			if ib(5 downto 3) = "110" then
				if ib(2 downto 0) = "110" then
					return inst_HALT_0;
				else
					return inst_MOV_RM_0;
				end if;
			
			else
				if ib(2 downto 0) = "110" then
					return inst_MOV_MR_0;
				else
					return inst_MOV_RR_0;
				end if;
			end if;
		
		when INST_STAX => return inst_STAX_0;
		when INST_LDAX => return inst_LDAX_0;
		
		when INST_INR =>
			if ib(5 downto 3) = "110" then
				return inst_INR_M_0;
			else
				return inst_INR_R_0;
			end if;
		
		when INST_DCR =>
			if ib(5 downto 3) = "110" then
				return inst_DCR_M_0;
			else
				return inst_DCR_R_0;
			end if;

		when INST_CMA => return inst_CMA_0;
		when INST_DAA => return inst_DAA_0;
		
		when INST_CMC => return inst_CMC_0;
		when INST_STC => return inst_STC_0;
		
		when INST_ALU_IMMED => return inst_ALU_IMMED_0;
		
		when INST_XCHG => return inst_XCHG_0;
		when INST_XTHL => return inst_XTHL_0;
		
		when INST_INX => return inst_INX_0;
		when INST_DCX => return inst_DCX_0;
		
		when INST_DAD => return inst_DAD_0;
		
		when INST_SPHL => return inst_SPHL_0;
		
		when INST_PUSH => return inst_PUSH_0;
		
		when INST_POP => return inst_POP_0;
		
		when INST_PCHL =>  return inst_PCHL_0;
		
		when INST_JMP => return inst_JMP_0;
		when INST_JMP_COND => return inst_JMP_COND_0;
		
		when INST_CALL => return inst_CALL_0;
		when INST_RET => return inst_RET_0;
		
		when INST_CALL_COND => return inst_CALL_COND_M1;
		when INST_RET_COND => return inst_RET_COND_M1;
		
		when INST_ALU_RM =>
			if ib(2 downto 0) = "110" then
				return inst_ALU_M_0;
			else
				return inst_ALU_R_0;
			end if;
		
		when INST_EI => return inst_EI_0;
		when INST_DI => return inst_DI_0;
		
		when INST_IN => return inst_IN_0;
		when INST_OUT => return inst_OUT_0;
		
		when INST_RESET => return inst_RST_0;
		
		when others =>
			assert false report "UNHANDLED INSTRUCTION: "
				& natural'image(to_integer(unsigned(ib)))
				& ", type = " & inst_type'image(it) severity warning;
			return fetch_inst_0;
		end case;
	end function;

	function get_inst_args(it: inst_type) return natural is
		variable ret: natural := 0;
	begin
		for i in inst_class_tab'range loop
			if it = inst_class_tab(i).inst then
				ret := inst_class_tab(i).args;
			end if;
		end loop;
		
		return ret;
	end function;

	function get_inst(inst_byte: std_logic_vector(7 downto 0)) return inst_type is
		-- Implements AND over two 8 bit vectors
		function "and"(left, right: std_logic_vector(7 downto 0))
			return std_logic_vector
		is
			variable ret: std_logic_vector(7 downto 0) := (others => '0');
		begin
			for i in left'range loop
				ret(i) := left(i) and right(i);
			end loop;
			return ret;
		end function;
		
		-- Local variables
		variable inst_masked: std_logic_vector(7 downto 0) := (others => '0');
	begin
		for i in inst_class_tab'range loop
			inst_masked := inst_byte and inst_class_tab(i).mask;
			
			if inst_masked = inst_class_tab(i).op then
				return inst_class_tab(i).inst;
			end if;
		end loop;
		
		-- If we're still here, then we failed to find a corresponding instruction.
		assert false report "Failed to find instruction for instruction byte '"
			& str(inst_byte) & "', returning INST_NOP" severity Error;
		return INST_NOP;
	end function;

	function get_flags_byte(flags: i8080_flags) return std_logic_vector is
		constant FLAGIDX_SIGN: natural := 7;
		constant FLAGIDX_ZERO: natural := 6;
		-- Bit 5 always 0
		constant FLAGIDX_AUX_CARRY: natural := 4;
		-- Bit 3 always 0
		constant FLAGIDX_PARITY: natural := 2;
		-- Bit 1 always 0
		constant FLAGIDX_CARRY: natural := 0;

		variable flags_byte: std_logic_vector(7 downto 0) := X"00";
	begin
		flags_byte(FLAGIDX_SIGN) := flags.sign;
		flags_byte(FLAGIDX_ZERO) := flags.zero;
		flags_byte(5) := '0';
		flags_byte(FLAGIDX_AUX_CARRY) := flags.aux_carry;
		flags_byte(3) := '0';
		flags_byte(FLAGIDX_PARITY) := flags.parity;
		flags_byte(1) := '0';
		flags_byte(FLAGIDX_CARRY) := flags.carry;
		
		return flags_byte;
	end function;

	function get_flags_from_byte(flags_byte: std_logic_vector(7 downto 0))
		return i8080_flags
	is
		constant FLAGIDX_SIGN: natural := 7;
		constant FLAGIDX_ZERO: natural := 6;
		-- Bit 5 always 0
		constant FLAGIDX_AUX_CARRY: natural := 4;
		-- Bit 3 always 0
		constant FLAGIDX_PARITY: natural := 2;
		-- Bit 1 always 0
		constant FLAGIDX_CARRY: natural := 0;

		variable flags: i8080_flags;
	begin
		flags.sign := flags_byte(FLAGIDX_SIGN);
		flags.zero := flags_byte(FLAGIDX_ZERO);
		flags.aux_carry := flags_byte(FLAGIDX_AUX_CARRY);
		flags.parity := flags_byte(FLAGIDX_PARITY);
		flags.carry := flags_byte(FLAGIDX_CARRY);
	
		return flags;
	end function;

	function get_cond_code(ib: std_logic_vector(7 downto 0))
		return i8080_cond_code
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
	begin
		bitfield := ib(5 downto 3);
		case bitfield is
			when "000" => return C_NZERO;
			when "001" => return C_ZERO;
			when "010" => return C_NCARRY;
			when "011" => return C_CARRY;
			when "100" => return C_OPARITY;
			when "101" => return C_EPARITY;
			when "110" => return C_PLUS;
			when "111" => return C_MINUS;
			when others =>
				assert false report "Invalid bitfield supplied to "
					& "get_cond_code()" severity Failure;
				return C_NZERO;
		end case;
	end function;
	
	function eval_cond_code(cc: i8080_cond_code; flags: i8080_flags)
		return boolean
	is
	begin
		case cc is
			when C_NZERO =>
				return flags.zero = '0';
			when C_ZERO =>
				return flags.zero = '1';
			when C_NCARRY =>
				return flags.carry = '0';
			when C_CARRY =>
				return flags.carry = '1';
			when C_OPARITY =>
				return flags.parity = '0';
			when C_EPARITY =>
				return flags.parity = '1';
			when C_PLUS =>
				return flags.sign = '0';
			when C_MINUS =>
				return flags.sign = '1';
		end case;
	end function;

	function get_reset_vector_address(inst_byte: std_logic_vector(7 downto 0))
		return std_logic_vector
	is
		variable bitfield: std_logic_vector(2 downto 0) := "000";
		variable ret: std_logic_vector(15 downto 0) := X"0000";
	begin
		bitfield := inst_byte(5 downto 3);
		return "00000000" & "00" & bitfield & "000";
	end function;

end package body;

