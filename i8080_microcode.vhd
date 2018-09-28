library ieee;
use ieee.std_logic_1164.all;

use work.i8080_util.all;
use work.i8080_microcode_util.all;

entity i8080_microcode is
	port (
		current_ui: in microinstruction;
		inst_byte: in std_logic_vector(7 downto 0);
		cs: out cpu_control_signals := CPU_CONTROL_SIGNALS_DEFAULT
	);
end entity;

architecture rtl of i8080_microcode is
begin
	microcode_proc: process (current_ui) is
		variable csi: cpu_control_signals := CPU_CONTROL_SIGNALS_DEFAULT;
	begin
		csi := CPU_CONTROL_SIGNALS_DEFAULT;
		
		case current_ui is
		when fetch_inst_0 =>
			-- If there is an interrupt and ie = '1', handle it.
			csi.uc.op := Try_jump_to_int_handler;
		
		when fetch_inst_1 =>
			-- Register PC to output address register
			csi.a.load := LOAD_PC;

		when fetch_inst_2 =>
			-- Fetch the instruction at PC
			csi.m.op := Read;

		when fetch_inst_3 =>
--			csi.uc.op := Jump_next_when_read_complete;

		when fetch_inst_4 =>
			-- Enable the data input register
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when fetch_inst_5 =>
			-- Enable the instruction register
			csi.r.ir_ce := '1';

		when fetch_inst_6 =>
			-- Update PC to point to next instruction
			csi.r.pc := PC_LOAD_NIA;

		when fetch_inst_7 =>
			-- Jump to corresponding microroutine
			csi.uc.op := Jump_inst_byte;
		
		
		
		when inst_LXI_0 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_LXI_1 =>
			-- Fetch low byte
			csi.m.op := Read;
		
		when inst_LXI_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LXI_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_LXI_4 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := get_rf_sel_LXI_low(inst_byte);

			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_LXI_5 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_LXI_6 =>
			-- Fetch high byte
			csi.m.op := Read;
		
		when inst_LXI_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LXI_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_LXI_9 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := get_rf_sel_LXI_high(inst_byte);
			
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		when inst_MVI_R_0 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_MVI_R_1 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_MVI_R_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_MVI_R_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_MVI_R_4 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := get_rf_sel_MVI_R(inst_byte);
			
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		when inst_MVI_M_0 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_MVI_M_1 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_MVI_M_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_MVI_M_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		-- Now we need to address *HL. Load HL into address regster.
		when inst_MVI_M_4 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';

		when inst_MVI_M_5 =>
			csi.a.load := LOAD_RF_H;
		
		when inst_MVI_M_6 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';

		when inst_MVI_M_7 =>
			csi.a.load := LOAD_RF_L;

		-- Now load the data output register
		when inst_MVI_M_8 =>
			csi.r.do := LOAD_DI;

		-- Now write the data in register to *HL that is loaded into addr reg.
		when inst_MVI_M_9 =>
			csi.m.op := Write;
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		-- First we load the low byte address buffer register
		when inst_STA_0 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_STA_1 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_STA_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_STA_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_STA_4 =>
			csi.a.loadbuf := LOAD_DATA_IN_L;
		
		-- Now load the high byte address buffer register
		when inst_STA_5 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_STA_6 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_STA_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_STA_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_STA_9 =>
			csi.a.loadbuf := LOAD_DATA_IN_H;

		-- The address buffer register is ready, but before we commit it to
		-- the address register, lets get the accumulator out on the output
		-- data register.
		when inst_STA_10 =>
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
		
		when inst_STA_11 =>
			csi.r.do := LOAD_RF;

		-- Now load the address register proper
		when inst_STA_12 =>
			csi.a.load := LOAD_BUFFER;
		
		-- Now issue the write command and leave
		when inst_STA_13 =>
			csi.m.op := Write;
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		
		-- First we load the low byte address buffer register
		when inst_LDA_0 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_LDA_1 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_LDA_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LDA_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_LDA_4 =>
			csi.a.loadbuf := LOAD_DATA_IN_L;
		
		-- Now load the high byte address buffer register
		when inst_LDA_5 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_LDA_6 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_LDA_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LDA_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_LDA_9 =>
			csi.a.loadbuf := LOAD_DATA_IN_H;
		
		-- Now load the address register proper
		when inst_LDA_10 =>
			csi.a.load := LOAD_BUFFER;
		
		-- Read byte
		when inst_LDA_11 =>
			csi.m.op := Read;
		
		when inst_LDA_12 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LDA_13 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		-- Write byte to accumulator
		when inst_LDA_14 =>
			csi.r.rf.sel := RF_A;
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		-- First we load the low byte address buffer register
		when inst_SHLD_0 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_SHLD_1 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_SHLD_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_SHLD_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_SHLD_4 =>
			csi.a.loadbuf := LOAD_DATA_IN_L;
		
		-- Now load the high byte address buffer register
		when inst_SHLD_5 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_SHLD_6 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_SHLD_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_SHLD_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_SHLD_9 =>
			csi.a.loadbuf := LOAD_DATA_IN_H;
		
		-- Load address register with [HI] [LO]
		when inst_SHLD_10 =>
			csi.a.load := LOAD_BUFFER;
		
		-- Now load register L
		when inst_SHLD_11 =>
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		-- Load register L to data output
		when inst_SHLD_12 =>
			csi.r.do := LOAD_RF;
		
		-- Write L to *([high][low])
		when inst_SHLD_13 =>
			csi.m.op := Write;
		
		-- Increment address
		when inst_SHLD_14 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		-- Now load register H
		when inst_SHLD_15 =>
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		-- Load register H to data output
		when inst_SHLD_16 =>
			csi.r.do := LOAD_RF;
		
		-- Write H to *([high][low]) and LEAVE
		when inst_SHLD_17 =>
			csi.m.op := Write;
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		-- First we load the low byte argument
		when inst_LHLD_0 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_LHLD_1 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_LHLD_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LHLD_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		-- Now load the low byte into the address buffer
		when inst_LHLD_4 =>
			csi.a.loadbuf := LOAD_DATA_IN_L;
		
		-- Now load the high byte argument
		when inst_LHLD_5 =>
			-- Increment addr by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;

		when inst_LHLD_6 =>
			-- Fetch byte
			csi.m.op := Read;
		
		when inst_LHLD_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LHLD_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		-- Now load high low byte into the address buffer
		when inst_LHLD_9 =>
			csi.a.loadbuf := LOAD_DATA_IN_H;
		
		-- Load address register with [HI] [LO]
		when inst_LHLD_10 =>
			csi.a.load := LOAD_BUFFER;
		
		-- Fetch low byte
		when inst_LHLD_11 =>
			csi.m.op := Read;
		
		when inst_LHLD_12 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LHLD_13 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		-- Load data into register L
		when inst_LHLD_14 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		-- Increment address
		when inst_LHLD_15 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
			
		when inst_LHLD_16 =>
			csi.m.op := Read;
		
		when inst_LHLD_17 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LHLD_18 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		-- Load data into register H
		when inst_LHLD_19 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;
		
		
		-- Move register src to register dest
		when inst_MOV_RR_0 =>
			csi.r.rf.sel := get_rf_sel_MOV_RR_src(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_MOV_RR_1 =>
			csi.r.rf.sel_input_class := RF_SEL_SELF;
			csi.r.rf.sel := get_rf_sel_MOV_RR_dest(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		-- Move register src to *(HL)
		-- First, load address register with HL. We can bypass address buffer
		-- because all data is already available.
		when inst_MOV_RM_0 =>
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_MOV_RM_1 =>
			csi.a.load := LOAD_RF_L;
		
		when inst_MOV_RM_2 =>
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_MOV_RM_3 =>
			csi.a.load := LOAD_RF_H;
		
		-- Now load the register in the src to data output register
		when inst_MOV_RM_4 =>
			csi.r.rf.sel := get_rf_sel_MOV_RM_src(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_MOV_RM_5 =>
			csi.r.do := LOAD_RF;
		
		when inst_MOV_RM_6 =>
			csi.m.op := Write;
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		-- Move value pointed by immed16 to register in dst bitmask.
		-- First, load immed16 into addr buffer (wee need to icnrement addr for 2nd immed8)
		when inst_MOV_MR_0 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_MOV_MR_1 =>
			csi.m.op := Read;
		
		when inst_MOV_MR_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_MOV_MR_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_MOV_MR_4 =>
			csi.a.loadbuf := LOAD_DATA_IN_L;
		

		when inst_MOV_MR_5 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_MOV_MR_6 =>
			csi.m.op := Read;
		
		when inst_MOV_MR_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_MOV_MR_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_MOV_MR_9 =>
			csi.a.loadbuf := LOAD_DATA_IN_H;


		-- Read request for the specified byte
		when inst_MOV_MR_10 =>
			csi.a.load := LOAD_BUFFER;
		
		when inst_MOV_MR_11 =>
			csi.m.op := Read;
		
		when inst_MOV_MR_12 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_MOV_MR_13 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		-- Load specified byte into corresponding dest register
		when inst_MOV_MR_14 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := get_rf_sel_MOV_MR_dest(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		-- Store accumulator into register pair *BC or *DE depending on bit 4.

		-- Get the low register into the output address register (dont need buffer)
		when inst_STAX_0 =>
			csi.r.rf.sel := get_rf_sel_STAX_L(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_STAX_1 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_L;

		-- Get the high register into the output address register (dont need buffer)		
		when inst_STAX_2 =>		
			csi.r.rf.sel := get_rf_sel_STAX_H(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_STAX_3 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_H;
		
		-- Register accumulator into output data register
		when inst_STAX_4 =>
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
		
		when inst_STAX_5 =>
			csi.r.do := LOAD_RF;
		
		when inst_STAX_6 =>
			csi.m.op := Write;
			
			csi.uc.op := Jump_fetch_inst_0;
		


		-- Load accumulator from register pair *BC or *DE depending on bit 4.
		-- Get the low register into the output address register (dont need buffer)
		when inst_LDAX_0 =>
			csi.r.rf.sel := get_rf_sel_LDAX_L(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_LDAX_1 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_L;

		-- Get the high register into the output address register (dont need buffer)		
		when inst_LDAX_2 =>		
			csi.r.rf.sel := get_rf_sel_LDAX_H(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_LDAX_3 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_H;
		
		-- Read byte
		when inst_LDAX_4 =>
			csi.m.op := Read;
		
		when inst_LDAX_5 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_LDAX_6 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		-- Write byte and exit
		when inst_LDAX_7 =>
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		when inst_INR_R_0 =>
			-- Load given register
			csi.r.rf.sel := get_rf_sel_INR(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_INR_R_1 =>
			-- Load selected register into RHS of ALU
			csi.alu.rsel := ALU_INPUT_RF_DO;
			csi.alu.rhs_ce := '1';
		
		when inst_INR_R_2 =>
			-- Issue increment operation to ALU
			csi.alu.op := ALU_OP_INC;
		
		when inst_INR_R_3 =>
			-- Issue update SZP flags operation to ALU
			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_INR_R_4 =>
			-- Writeback register to register file
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := get_rf_sel_INR(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			-- Fetch next instruction
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		
		-- Get the HL registers into the output address register (dont need buffer)
		when inst_INR_M_0 =>
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_INR_M_1 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_L;

		-- Get the high register into the output address register (dont need buffer)		
		when inst_INR_M_2 =>		
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_INR_M_3 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_H;
		
		-- Read byte
		when inst_INR_M_4 =>
			csi.m.op := Read;
		
		when inst_INR_M_5 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_INR_M_6 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_INR_M_7 =>
			-- Load data input into ALU rhs register
			csi.alu.rsel := ALU_INPUT_DATA_IN;
			csi.alu.rhs_ce := '1';
			
		when inst_INR_M_8 =>
			-- Issue increment operation
			csi.alu.op := ALU_OP_INC;
		
		when inst_INR_M_9 =>
			-- Issue update SZP flags operation to ALU
			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_INR_M_10 =>
			-- Load data output register with ALU result
			csi.r.do := LOAD_ALU;
		
		when inst_INR_M_11 =>
			-- Recall that the address hasn't changed; We're still pointing
			-- to *(HL). All we have to do is issue the write.
			csi.m.op := Write;
			
			csi.uc.op := Jump_fetch_inst_0;
		




		-- Get the HL registers into the output address register (dont need buffer)
		when inst_DCR_M_0 =>
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_DCR_M_1 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_L;

		-- Get the high register into the output address register (dont need buffer)		
		when inst_DCR_M_2 =>		
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_DCR_M_3 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_H;
		
		-- Read byte
		when inst_DCR_M_4 =>
			csi.m.op := Read;
		
		when inst_DCR_M_5 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_DCR_M_6 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_DCR_M_7 =>
			-- Load data input into ALU rhs register
			csi.alu.rsel := ALU_INPUT_DATA_IN;
			csi.alu.rhs_ce := '1';
			
		when inst_DCR_M_8 =>
			-- Issue decrement operation
			csi.alu.op := ALU_OP_DEC;
		
		when inst_DCR_M_9 =>
			-- Issue update SZP flags operation to ALU
			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_DCR_M_10 =>
			-- Load data output register with ALU result
			csi.r.do := LOAD_ALU;
		
		when inst_DCR_M_11 =>
			-- Recall that the address hasn't changed; We're still pointing
			-- to *(HL). All we have to do is issue the write.
			csi.m.op := Write;
			
			csi.uc.op := Jump_fetch_inst_0;
		


		when inst_DCR_R_0 =>
			-- Load given register
			csi.r.rf.sel := get_rf_sel_DCR(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_DCR_R_1 =>
			-- Load selected register into RHS of ALU
			csi.alu.rsel := ALU_INPUT_RF_DO;
			csi.alu.rhs_ce := '1';
		
		when inst_DCR_R_2 =>
			-- Issue decrement operation to ALU
			csi.alu.op := ALU_OP_DEC;
		
		when inst_DCR_R_3 =>
			-- Issue update SZP flags operation to ALU
			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_DCR_R_4 =>
			-- Writeback register to register file
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := get_rf_sel_DCR(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			-- Fetch next instruction
			csi.uc.op := Jump_fetch_inst_0;




		when inst_CMA_0 =>
			-- Load accumulator from register file
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
		
		when inst_CMA_1 =>
			-- Load ALU lhs from rf_do
			csi.alu.lsel := ALU_INPUT_RF_DO;
			csi.alu.lhs_ce := '1';
		
		when inst_CMA_2 =>
			-- Issue CMA instruction to ALU
			csi.alu.op := ALU_OP_CMA;

		-- CMA instruction does not affect any flags		
--		when inst_CMA_3 =>
--			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_CMA_3 =>
			-- Writeback register
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		when inst_DAA_0 =>
			-- Load accumulator from register file
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
		
		when inst_DAA_1 =>
			-- Load ALU lhs from rf_do
			csi.alu.lsel := ALU_INPUT_RF_DO;
			csi.alu.lhs_ce := '1';
		
		when inst_DAA_2 =>
			-- Issue DAA instruction to ALU
			csi.alu.op := ALU_OP_DAA;

		when inst_DAA_3 =>
			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_DAA_4 =>
			-- Writeback register
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			csi.uc.op := Jump_fetch_inst_0;
			
		
		
		when inst_CMC_0 =>
			csi.alu.op := ALU_OP_CMC;
			csi.uc.op := Jump_fetch_inst_0;
		
		
		when inst_STC_0 =>
			csi.alu.op := ALU_OP_STC;
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		
		when inst_ALU_IMMED_0 =>
			-- First load the immediate byte into the data input register
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_ALU_IMMED_1 =>
			csi.m.op := Read;
		
		when inst_ALU_IMMED_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_ALU_IMMED_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_ALU_IMMED_4 =>
			-- Load immediate byte into ALU rhs register
			csi.alu.rsel := ALU_INPUT_DATA_IN;
			csi.alu.rhs_ce := '1';
		
		when inst_ALU_IMMED_5 =>
			-- Now load the accumulator register
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
		
		when inst_ALU_IMMED_6 =>
			-- Load A register into ALU lhs register
			csi.alu.lsel := ALU_INPUT_RF_DO;
			csi.alu.lhs_ce := '1';
		
		when inst_ALU_IMMED_7 =>
			-- Issue ALU instruction that corresponds to bitfield (5 downto 3)
			csi.alu.op := get_alu_op_ALU_IMMED(inst_byte);
			-- FIXME: we writeback the register on CPI instructions, which
			-- is just a waste of cycles. Differentiate the two somehow.
		
		when inst_ALU_IMMED_8 =>
			-- Issue update SZP flags operation to ALU
			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_ALU_IMMED_9 =>
			-- Writeback result to register file MAYBE (not if CPI)
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := get_rf_wren_CPI_IMMED(inst_byte);
			csi.r.rf.wren := get_rf_wren_CPI_IMMED(inst_byte);
		
			csi.uc.op := Jump_fetch_inst_0;
			
			
		
		when inst_XCHG_0 =>
			-- Load HL into temporary register
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_XCHG_1 =>
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_XCHG_2 =>
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_XCHG_3 =>
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_XCHG_4 =>
			-- Overwrite HL with DE, lowest byte first
			csi.r.rf.sel := RF_E;
			csi.r.rf.en := '1';
		
		when inst_XCHG_5 =>
			csi.r.rf.sel_input_class := RF_SEL_SELF;
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_XCHG_6 =>
			-- Do the same as 4 and 5, but for D and H
			csi.r.rf.sel := RF_D;
			csi.r.rf.en := '1';
		
		when inst_XCHG_7 =>
			csi.r.rf.sel_input_class := RF_SEL_SELF;
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_XCHG_8 =>
			-- Now write rp_tmp to DE, low byte
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_E;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_XCHG_9 =>
			-- Now write rp_tmp to DE, high byte
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_D;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		
		when inst_XTHL_0 =>
			-- Load address output register with SP
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
		
		when inst_XTHL_1 =>
			csi.a.load := LOAD_RF_L;
		
		when inst_XTHL_2 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
		
		when inst_XTHL_3 =>
			csi.a.load := LOAD_RF_H;

		when inst_XTHL_4 =>
			csi.m.op := Read;
		
		when inst_XTHL_5 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_XTHL_6 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_XTHL_7 =>
			-- Now get L register onto data out register
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_XTHL_8 =>
			csi.r.do := LOAD_RF;
		
		when inst_XTHL_9 =>
			-- Write L to *SP
			csi.m.op := Write;
		
		when inst_XTHL_10 =>
			-- Load L with data in register
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
		-- Now do the same but for the H register
		when inst_XTHL_11 =>
			-- Increment address buffer by 1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_XTHL_12 =>
			csi.m.op := Read;
		
		when inst_XTHL_13 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_XTHL_14 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_XTHL_15 =>
			-- Now get H register onto data out register
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_XTHL_16 =>
			csi.r.do := LOAD_RF;
		
		when inst_XTHL_17 =>
			-- Write L to *(SP+1)
			csi.m.op := Write;
		
		when inst_XTHL_18 =>
			-- Load H with data in register
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		-- Load given pair (BC, DE, HL, SP) into rp_tmp		
		when inst_INX_0 =>
			csi.r.rf.sel := get_rf_sel_INX_L(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_INX_1 =>
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_INX_2 =>
			csi.r.rf.sel := get_rf_sel_INX_H(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_INX_3 =>
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_INX_4 =>
			csi.r.rp := RP_OP_INC;
		
		when inst_INX_5 =>
			-- write back result to register file
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := get_rf_sel_INX_L(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_INX_6 =>
			-- write back result to register file
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := get_rf_sel_INX_H(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';

			csi.uc.op := Jump_fetch_inst_0;
		
		


		-- Load given pair (BC, DE, HL, SP) into rp_tmp		
		when inst_DCX_0 =>
			csi.r.rf.sel := get_rf_sel_DCX_L(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_DCX_1 =>
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_DCX_2 =>
			csi.r.rf.sel := get_rf_sel_DCX_H(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_DCX_3 =>
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_DCX_4 =>
			csi.r.rp := RP_OP_DEC;
		
		when inst_DCX_5 =>
			-- write back result to register file
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := get_rf_sel_DCX_L(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_DCX_6 =>
			-- write back result to register file
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := get_rf_sel_DCX_H(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';

			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		-- hl + {bc de hl sp}
		when inst_DAD_0 =>
			-- Load L to lhs
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_DAD_1 =>
			-- Load rf_do to alu lhs
			csi.alu.lsel := ALU_INPUT_RF_DO;
			csi.alu.lhs_ce := '1';
		
		when inst_DAD_2 =>
			-- Load the low argument register into rhs alu register
			csi.r.rf.sel := get_rf_sel_DAD_L(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_DAD_3 =>
			-- Load rf_do to alu rhs
			csi.alu.rsel := ALU_INPUT_RF_DO;
			csi.alu.rhs_ce := '1';
		
		when inst_DAD_4 =>
			-- Issue DAD ADD instruction to ALU
			csi.alu.op := ALU_DAD_LOW;
		
		when inst_DAD_5 =>
			-- Save ALU result to L register
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_DAD_6 =>
			-- Load H register to lhs
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_DAD_7 =>
			-- load rf_do to alu lhs
			csi.alu.lsel := ALU_INPUT_RF_DO;
			csi.alu.lhs_ce := '1';
		
		when inst_DAD_8 =>
			-- Load the high argument register into rhs alu register
			csi.r.rf.sel := get_rf_sel_DAD_H(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_DAD_9 =>
			-- Load rf_do to alu rhs
			csi.alu.rsel := ALU_INPUT_RF_DO;
			csi.alu.rhs_ce := '1';
		
		when inst_DAD_10 =>
			-- Issue DAD ADD instruction to ALU
			csi.alu.op := ALU_DAD_HIGH;
		
		when inst_DAD_11 =>
			-- Save ALU result to H register
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;

		
		
		
		when inst_SPHL_0 =>
			-- Load L
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_SPHL_1 =>
			-- Load SP_L
			csi.r.rf.sel_input_class := RF_SEL_SELF;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_SPHL_2 =>
			-- Load H
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_SPHL_3 =>
			-- Load SP_H
			csi.r.rf.sel_input_class := RF_SEL_SELF;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		
		when inst_PUSH_0 =>
			-- First we get the high register, dependant on the
			-- instruction of the bitfield.
			csi.r.rf.sel := get_rf_sel_PUSH_H(inst_byte);
			csi.r.rf.en := '1';
			
		when inst_PUSH_1 =>
			-- Load the high data byte into the output register
			-- NOTE: it may be the flags register.
			csi.r.do := get_r_do_sel_PUSH_H(inst_byte);
		
		when inst_PUSH_2 =>
			-- Load the stack pointer into the address register
			-- AND into the rp_tmp register
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			
		when inst_PUSH_3 =>
			csi.a.load := LOAD_RF_L;

			csi.r.rp := LOAD_RF_DO_LOW;
					
		when inst_PUSH_4 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			
		when inst_PUSH_5 =>
			csi.a.load := LOAD_RF_H;

			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_PUSH_6 =>
			-- Now decrement the address register by one
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_PUSH_7 =>
			-- Now save whatever is on the output data register
			csi.m.op := Write;
		
		when inst_PUSH_8 =>
			-- Now get the low data byte. This one is *definitely* a register.
			csi.r.rf.sel := get_rf_sel_PUSH_L(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_PUSH_9 =>
			csi.r.do := LOAD_RF;
		
		when inst_PUSH_10 =>
			-- Decrement the address output register
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
			
		when inst_PUSH_11 =>
			-- Write the output register
			csi.m.op := Write;
		
		when inst_PUSH_12 =>
			-- Decrement the temp register twice (it has SP loaded from earlier)
			csi.r.rp := RP_OP_DEC;
		
		when inst_PUSH_13 =>
			csi.r.rp := RP_OP_DEC;
		
		when inst_PUSH_14 =>
			-- Writeback the SP-2 to SP
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_PUSH_15 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		
		when inst_POP_0 =>
			-- Load stack pointer into address register AND rp_tmp
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
		
		when inst_POP_1 =>
			csi.a.load := LOAD_RF_L;
			
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_POP_2 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			
		when inst_POP_3 =>
			csi.a.load := LOAD_RF_H;

			csi.r.rp := LOAD_RF_DO_HIGH;
					
		when inst_POP_4 =>
			-- Request read
			csi.m.op := Read;
		
		when inst_POP_5 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_POP_6 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
				
		when inst_POP_7 =>
			-- We're DEFINITELY writing to a register file now.
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := get_rf_sel_POP_L(inst_byte);
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_POP_8 =>
			-- Increment address register to be equal to SP+1
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_POP_9 =>
			csi.m.op := Read;
		
		when inst_POP_10 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_POP_11 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_POP_12 =>
			-- Now we have the high byte, load into either the corresponding
			-- register OR into the ALU flags register.
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := get_rf_sel_POP_H(inst_byte);
			csi.r.rf.en := get_rf_wren_POP_H(inst_byte);
			csi.r.rf.wren := get_rf_wren_POP_H(inst_byte);
			
			-- Load into ALU rhs incase we're loading flags
			csi.alu.rsel := ALU_INPUT_DATA_IN;
			csi.alu.rhs_ce := '1';
		
		when inst_POP_13 =>
			-- Try loading flags if thats the case
			csi.alu.op := get_alu_op_POP_H(inst_byte);
		
		when inst_POP_14 =>
			-- Ok, we've loaded the value, now increment SP by 2
			csi.r.rp := RP_OP_INC;
		
		when inst_POP_15 =>
			csi.r.rp := RP_OP_INC;
		
		when inst_POP_16 =>
			-- Writeback the stack pointer
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_POP_17 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';

			csi.uc.op := Jump_fetch_inst_0;
			
		
		
		
		when inst_PCHL_0 =>
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_PCHL_1 =>
			csi.r.pc := PC_LOAD_RF_LOW;
		
		when inst_PCHL_2 =>
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_PCHL_3 =>
			csi.r.pc := PC_LOAD_RF_HIGH;
		
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		when inst_JMP_0 =>
			-- Load the immediate jump location into PC
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
			
		when inst_JMP_1 =>
			csi.m.op := Read;
		
		when inst_JMP_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_JMP_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_JMP_4 =>
			csi.r.pc := PC_LOAD_DATA_IN_LOW;
		
		when inst_JMP_5 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
			
		when inst_JMP_6 =>
			csi.m.op := Read;
		
		when inst_JMP_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_JMP_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_JMP_9 =>
			csi.r.pc := PC_LOAD_DATA_IN_HIGH;
		
			csi.uc.op := Jump_fetch_inst_0;



		when inst_JMP_COND_0 =>
			-- Load jump location
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_JMP_COND_1 =>
			csi.m.op := Read;
		
		when inst_JMP_COND_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_JMP_COND_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_JMP_COND_4 =>
			csi.r.pc := PC_LOAD_DATA_IN_COND_LOW;
		
		when inst_JMP_COND_5 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
			
		when inst_JMP_COND_6 =>
			csi.m.op := Read;
		
		when inst_JMP_COND_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_JMP_COND_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_JMP_COND_9 =>
			csi.r.pc := PC_LOAD_DATA_IN_COND_HIGH;
		
			csi.uc.op := Jump_fetch_inst_0;




		when inst_CALL_0 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_CALL_1 =>
			csi.m.op := Read;
		
		when inst_CALL_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_CALL_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_CALL_4 =>
			-- Load into low pc buffer
			csi.r.pc_buffer := PC_BUFFER_LOAD_DATA_IN_LOW;
		
		when inst_CALL_5 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_CALL_6 =>
			csi.m.op := Read;
		
		when inst_CALL_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_CALL_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_CALL_9 =>
			-- Load into high pc buffer
			csi.r.pc_buffer := PC_BUFFER_LOAD_DATA_IN_HIGH;

		when inst_CALL_10 =>
			-- push PC to stack
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
		
		when inst_CALL_11 =>
			csi.a.load := LOAD_RF_L;
			
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_CALL_12 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
		
		when inst_CALL_13 =>
			csi.a.load := LOAD_RF_H;
			
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_CALL_14 =>
			-- subtract addr by one to save high return address byte
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_CALL_15 =>
			csi.r.do := LOAD_PC_HIGH;
		
		when inst_CALL_16 =>
			csi.m.op := Write;
		
		when inst_CALL_17 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_CALL_18 =>
			csi.r.do := LOAD_PC_LOW;
		
		when inst_CALL_19 =>
			csi.m.op := Write;
		
		when inst_CALL_20 =>
			-- Decrement SP twice and writeback to register file
			csi.r.rp := RP_OP_DEC;
		
		when inst_CALL_21 =>
			csi.r.rp := RP_OP_DEC;
		
		when inst_CALL_22 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_CALL_23 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_CALL_24 =>
			csi.r.pc := PC_LOAD_BUFFER;
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		
		
		when inst_RET_0 =>
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
		
		when inst_RET_1 =>
			csi.a.load := LOAD_RF_L;
			
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_RET_2 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
		
		when inst_RET_3 =>
			csi.a.load := LOAD_RF_H;
			
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_RET_4 =>
			-- Get the LOW return address byte
			csi.m.op := Read;
		
		when inst_RET_5 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_RET_6 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_RET_7 =>
			csi.r.pc_buffer := PC_BUFFER_LOAD_DATA_IN_LOW;
		
		when inst_RET_8 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_RET_9 =>
			csi.m.op := Read;
		
		when inst_RET_10 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_RET_11 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_RET_12 =>
			csi.r.pc_buffer := PC_BUFFER_LOAD_DATA_IN_HIGH;
		
		when inst_RET_13 =>
			csi.r.pc := PC_LOAD_BUFFER;
		
		when inst_RET_14 =>
			-- Ok, the PC has the return address ready, now just increment
			-- SP and writeback.
			csi.r.rp := RP_OP_INC;
		
		when inst_RET_15 =>
			csi.r.rp := RP_OP_INC;
		
		when inst_RET_16 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_RET_17 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;





		when inst_CALL_COND_M1 =>
			-- try to exit if cond bit fails
			csi.uc.op := Jump_fetch_inst_0_COND;

		when inst_CALL_COND_0 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_CALL_COND_1 =>
			csi.m.op := Read;
		
		when inst_CALL_COND_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_CALL_COND_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_CALL_COND_4 =>
			-- Load into low pc buffer
			csi.r.pc_buffer := PC_BUFFER_LOAD_DATA_IN_LOW;
		
		when inst_CALL_COND_5 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_CALL_COND_6 =>
			csi.m.op := Read;
		
		when inst_CALL_COND_7 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_CALL_COND_8 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';

		when inst_CALL_COND_9 =>
			-- Load into high pc buffer
			csi.r.pc_buffer := PC_BUFFER_LOAD_DATA_IN_HIGH;

		when inst_CALL_COND_10 =>
			-- push PC to stack
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
		
		when inst_CALL_COND_11 =>
			csi.a.load := LOAD_RF_L;
			
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_CALL_COND_12 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
		
		when inst_CALL_COND_13 =>
			csi.a.load := LOAD_RF_H;
			
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_CALL_COND_14 =>
			-- subtract addr by one to save high return address byte
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_CALL_COND_15 =>
			csi.r.do := LOAD_PC_HIGH;
		
		when inst_CALL_COND_16 =>
			csi.m.op := Write;
		
		when inst_CALL_COND_17 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_CALL_COND_18 =>
			csi.r.do := LOAD_PC_LOW;
		
		when inst_CALL_COND_19 =>
			csi.m.op := Write;
		
		when inst_CALL_COND_20 =>
			-- Decrement SP twice and writeback to register file
			csi.r.rp := RP_OP_DEC;
		
		when inst_CALL_COND_21 =>
			csi.r.rp := RP_OP_DEC;
		
		when inst_CALL_COND_22 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_CALL_COND_23 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_CALL_COND_24 =>
			csi.r.pc := PC_LOAD_BUFFER;
			
			csi.uc.op := Jump_fetch_inst_0;
		



		when inst_RET_COND_M1 =>
			-- try to exit if cond bit fails
			csi.uc.op := Jump_fetch_inst_0_COND;
		
		when inst_RET_COND_0 =>
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
		
		when inst_RET_COND_1 =>
			csi.a.load := LOAD_RF_L;
			
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_RET_COND_2 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
		
		when inst_RET_COND_3 =>
			csi.a.load := LOAD_RF_H;
			
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_RET_COND_4 =>
			-- Get the LOW return address byte
			csi.m.op := Read;
		
		when inst_RET_COND_5 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_RET_COND_6 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_RET_COND_7 =>
			csi.r.pc_buffer := PC_BUFFER_LOAD_DATA_IN_LOW;
		
		when inst_RET_COND_8 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_RET_COND_9 =>
			csi.m.op := Read;
		
		when inst_RET_COND_10 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_RET_COND_11 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_RET_COND_12 =>
			csi.r.pc_buffer := PC_BUFFER_LOAD_DATA_IN_HIGH;
		
		when inst_RET_COND_13 =>
			csi.r.pc := PC_LOAD_BUFFER;
		
		when inst_RET_COND_14 =>
			-- Ok, the PC has the return address ready, now just increment
			-- SP and writeback.
			csi.r.rp := RP_OP_INC;
		
		when inst_RET_COND_15 =>
			csi.r.rp := RP_OP_INC;
		
		when inst_RET_COND_16 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_RET_COND_17 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;




		when inst_ALU_R_0 =>
			-- First load the given register into ALU rhs
			csi.r.rf.sel := get_rf_sel_ALU_R(inst_byte);
			csi.r.rf.en := '1';
		
		when inst_ALU_R_1 =>
			-- Load register byte into ALU rhs register
			csi.alu.rsel := ALU_INPUT_RF_DO;
			csi.alu.rhs_ce := '1';
		
		when inst_ALU_R_2 =>
			-- Now load the accumulator register
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
		
		when inst_ALU_R_3 =>
			-- Load A register into ALU lhs register
			csi.alu.lsel := ALU_INPUT_RF_DO;
			csi.alu.lhs_ce := '1';
		
		when inst_ALU_R_4 =>
			-- Issue ALU instruction that corresponds to bitfield (5 downto 3)
			csi.alu.op := get_alu_op_ALU_IMMED(inst_byte);
			-- FIXME: we "writeback" the register on CPI instructions, which
			-- is just a waste of cycles. Differentiate the two somehow.
		
		when inst_ALU_R_5 =>
			-- Issue update SZP flags operation to ALU
			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_ALU_R_6 =>
			-- "Writeback" result to register file MAYBE (not if CPI)
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := get_rf_wren_CPI_IMMED(inst_byte);
			csi.r.rf.wren := get_rf_wren_CPI_IMMED(inst_byte);
		
			csi.uc.op := Jump_fetch_inst_0;
				



		-- Get the HL registers into the output address register
		-- (dont need buffer)
		when inst_ALU_M_0 =>
			csi.r.rf.sel := RF_L;
			csi.r.rf.en := '1';
		
		when inst_ALU_M_1 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_L;

		-- Get the high register into the output address register
		-- (dont need buffer)		
		when inst_ALU_M_2 =>		
			csi.r.rf.sel := RF_H;
			csi.r.rf.en := '1';
		
		when inst_ALU_M_3 =>
			-- Register the low output address register
			csi.a.load := LOAD_RF_H;
		
		-- Read byte
		when inst_ALU_M_4 =>
			csi.m.op := Read;
		
		when inst_ALU_M_5 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_ALU_M_6 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_ALU_M_7 =>
			-- Load data input into ALU rhs register
			csi.alu.rsel := ALU_INPUT_DATA_IN;
			csi.alu.rhs_ce := '1';
		
		when inst_ALU_M_8 =>
			-- Now load the accumulator register
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
		
		when inst_ALU_M_9 =>
			-- Load A register into ALU lhs register
			csi.alu.lsel := ALU_INPUT_RF_DO;
			csi.alu.lhs_ce := '1';
		
		when inst_ALU_M_10 =>
			-- Issue ALU instruction that corresponds to bitfield (5 downto 3)
			csi.alu.op := get_alu_op_ALU_IMMED(inst_byte);
			-- FIXME: we "writeback" the register on CPI instructions, which
			-- is just a waste of cycles. Differentiate the two somehow.
		
		when inst_ALU_M_11 =>
			-- Issue update SZP flags operation to ALU
			csi.alu.op := ALU_OP_SET_SZP_FLAGS;
		
		when inst_ALU_M_12 =>
			-- "Writeback" result to register file MAYBE (not if CPI)
			csi.r.rf.sel_input_class := RF_SEL_ALU;
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := get_rf_wren_CPI_IMMED(inst_byte);
			csi.r.rf.wren := get_rf_wren_CPI_IMMED(inst_byte);
		
			csi.uc.op := Jump_fetch_inst_0;
			



		when inst_EI_0 =>
			csi.r.ie := ENABLE;
			
			csi.uc.op := Jump_fetch_inst_0;
		
		
		
		when inst_DI_0 =>
			csi.r.ie := DISABLE;
			
			csi.uc.op := Jump_fetch_inst_0;
		




		when inst_IN_0 =>
			-- Load argument for port address
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_IN_1 =>
			csi.m.op := Read;
		
		when inst_IN_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_IN_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_IN_4 =>
			-- Load reg_di to low address
			csi.a.load := LOAD_DATA_IN_L;
		
		when inst_IN_5 =>
			-- Request read from port space
			csi.m.op := Read;
			csi.m.port_en := '1';
		
		when inst_IN_6 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_IN_7 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_IN_8 =>
			-- Load port data byte into register A and exit
			csi.r.rf.sel_input_class := RF_SEL_DATA_IN;
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
			csi.uc.op := Jump_fetch_inst_0;
			
		



		when inst_OUT_0 =>
			-- Load argument into low address register
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := 1;
		
		when inst_OUT_1 =>
			csi.m.op := Read;
		
		when inst_OUT_2 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_OUT_3 =>
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_OUT_4 =>
			csi.a.load := LOAD_DATA_IN_L;
		
		when inst_OUT_5 =>
			-- Load register A to output
			csi.r.rf.sel := RF_A;
			csi.r.rf.en := '1';
		
		when inst_OUT_6 =>
			csi.r.do := LOAD_RF;
		
		when inst_OUT_7 =>
			-- Write register A to port space and leave
			csi.m.op := Write;
			csi.m.port_en := '1';
		
			csi.uc.op := Jump_fetch_inst_0;




		when inst_HW_INT_0 =>
			-- Raise interrupt acknowledge signal
--			csi.uc.intack := '1';
			
			-- Also disable interrupt enable
			csi.r.ie := DISABLE;
		
		when inst_HW_INT_1 =>
--			csi.uc.op := Jump_next_when_read_complete;
		
		when inst_HW_INT_2 =>
			-- Raise interrupt acknowledge signal
			csi.uc.intack := '1';

			-- FIXME: I really need to standardise the timings on
			-- memory access operations...
			csi.uc.op := Jump_next_when_read_complete;
			csi.r.di_ce := '1';
		
		when inst_HW_INT_3 =>
			csi.r.ir_ce := '1';
		
		when inst_HW_INT_4 =>
			-- Now just execute the reset instruction as usual.
			
		when inst_HW_INT_5 =>
			-- push PC to stack
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
		
		when inst_HW_INT_6 =>
			csi.a.load := LOAD_RF_L;
			
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_HW_INT_7 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
		
		when inst_HW_INT_8 =>
			csi.a.load := LOAD_RF_H;
			
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_HW_INT_9 =>
			-- subtract addr by one to save high return address byte
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_HW_INT_10 =>
			csi.r.do := LOAD_PC_HIGH;
		
		when inst_HW_INT_11 =>
			csi.m.op := Write;
		
		when inst_HW_INT_12 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_HW_INT_13 =>
			csi.r.do := LOAD_PC_LOW;
		
		when inst_HW_INT_14 =>
			csi.m.op := Write;
		
		when inst_HW_INT_15 =>
			-- Decrement SP twice and writeback to register file
			csi.r.rp := RP_OP_DEC;
		
		when inst_HW_INT_16 =>
			csi.r.rp := RP_OP_DEC;
		
		when inst_HW_INT_17 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_HW_INT_18 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_HW_INT_19 =>
			csi.r.pc := PC_LOAD_RESET_VECTOR;
			
			csi.uc.op := Jump_fetch_inst_0;









		-- This instruction is identical to CALL, but without having to
		-- load the immed16 call destination address.
		when inst_RST_0 =>
			-- push PC to stack
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
		
		when inst_RST_1 =>
			csi.a.load := LOAD_RF_L;
			
			csi.r.rp := LOAD_RF_DO_LOW;
		
		when inst_RST_2 =>
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
		
		when inst_RST_3 =>
			csi.a.load := LOAD_RF_H;
			
			csi.r.rp := LOAD_RF_DO_HIGH;
		
		when inst_RST_4 =>
			-- subtract addr by one to save high return address byte
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_RST_5 =>
			csi.r.do := LOAD_PC_HIGH;
		
		when inst_RST_6 =>
			csi.m.op := Write;
		
		when inst_RST_7 =>
			csi.a.load := LOAD_OFFSET;
			csi.a.offset := -1;
		
		when inst_RST_8 =>
			csi.r.do := LOAD_PC_LOW;
		
		when inst_RST_9 =>
			csi.m.op := Write;
		
		when inst_RST_10 =>
			-- Decrement SP twice and writeback to register file
			csi.r.rp := RP_OP_DEC;
		
		when inst_RST_11 =>
			csi.r.rp := RP_OP_DEC;
		
		when inst_RST_12 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_LOW;
			csi.r.rf.sel := RF_SP_L;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_RST_13 =>
			csi.r.rf.sel_input_class := RF_SEL_RPOP_HIGH;
			csi.r.rf.sel := RF_SP_H;
			csi.r.rf.en := '1';
			csi.r.rf.wren := '1';
		
		when inst_RST_14 =>
			csi.r.pc := PC_LOAD_RESET_VECTOR;
			
			csi.uc.op := Jump_fetch_inst_0;




		when others =>
			null;
		
		end case;
		
		cs <= csi;
	end process;
	
end architecture;

