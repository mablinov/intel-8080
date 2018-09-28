library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;
use work.i8080_memory_sim_util.all;

entity i8080_core_inst_LXI_tb is
end;

architecture tb of i8080_core_inst_LXI_tb is
	constant mem_init_LXI: i8080_mem_blk(0 to 255) := (
		"00000000",
		"00000001", X"AD", X"DE", -- bc
		"00010001", X"EF", X"BE", -- de
		"00100001", X"34", X"12", -- hl
		"00110001", X"78", X"56", -- sp
		"00000001", X"CD", X"AB",
		"00010001", X"BA", X"AB",
		
		others => X"00"
	);
	
	constant mem_init_MVI_R: i8080_mem_blk(0 to 255) := (
		"00" & "000" & "110", X"FF",
		"00" & "001" & "110", X"FF",
		"00" & "010" & "110", X"FF",
		"00" & "011" & "110", X"FF",
		"00" & "100" & "110", X"FF",
		"00" & "101" & "110", X"FF",
--		"00" & "110" & "110", X"FF",
		"00" & "111" & "110", X"FF",

		"00" & "111" & "110", X"00",
--		"00" & "110" & "110", X"00",
		"00" & "101" & "110", X"00",
		"00" & "100" & "110", X"00",
		"00" & "011" & "110", X"00",
		"00" & "010" & "110", X"00",
		"00" & "001" & "110", X"00",
		"00" & "000" & "110", X"00",
		
		others => X"00"
	);

	constant mem_init_MVI_M: i8080_mem_blk(0 to 255) := (
--		"00100001", X"10", X"00", -- LXI HL 0x10
--		"00" & "110" & "110", X"FF", -- MVI M 0xFF

		"00100001", X"20", X"00", -- LXI HL 0x10
		"00" & "110" & "110", X"DE", -- MVI M 0xFF

		"00100001", X"21", X"00", -- LXI HL 0x10
		"00" & "110" & "110", X"AD", -- MVI M 0xFF

		"00100001", X"22", X"00", -- LXI HL 0x10
		"00" & "110" & "110", X"BE", -- MVI M 0xFF

		"00100001", X"23", X"00", -- LXI HL 0x10
		"00" & "110" & "110", X"EF", -- MVI M 0xFF
		
		others => X"00"
	);

	constant mem_init_STA: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"FF", -- MVI A 0xFF
		"001" & "10" & "010", X"20", X"00", -- STA 0x0020
		"001" & "10" & "010", X"21", X"00", -- STA 0x0021
		"001" & "10" & "010", X"25", X"00", -- STA 0x0025
		
		others => X"00"
	);

	constant mem_init_LDA: i8080_mem_blk(0 to 255) := (
		"001" & "11" & "010", X"03", X"00",
		X"AA",
		
		others => X"00"
	);

	constant mem_init_SHLD: i8080_mem_blk(0 to 255) := (
		"001" & "00" & "001", X"CD", X"AB", -- LXI HL 0xFF
		"001" & "00" & "010", X"10", X"00", -- SHLD 0x10
		
		others => X"00"
	);

	constant mem_init_LHLD: i8080_mem_blk(0 to 255) := (
		"001" & "01" & "010", X"04", X"00", -- LHLD 0x0004
		X"00", X"34", X"12",
		
		others => X"00"
	);

	constant mem_init_MVI_RR: i8080_mem_blk(0 to 255) := (
		-- First load the A register with 0xff
		"00" & "111" & "110", X"FF",
		-- Now move a to each register
		"01" & "000" & "111",
		"01" & "001" & "111",
		"01" & "010" & "111",
		"01" & "011" & "111",
		"01" & "100" & "111",
		"01" & "101" & "111",
--		"01" & "110" & "111",
		"01" & "111" & "111",
		
		"00" & "111" & "110", X"AA",
		-- Now move a to each register
		"01" & "000" & "111",
		"01" & "001" & "111",
		"01" & "010" & "111",
		"01" & "011" & "111",
		"01" & "100" & "111",
		"01" & "101" & "111",
--		"01" & "110" & "111",
		"01" & "111" & "111",
		
		others => X"00"
	);
	
	constant mem_init_MVI_RM: i8080_mem_blk(0 to 255) := (
		"001" & "01" & "010", X"06", X"00", -- LHLD 0x0006
		"00" & "111" & "110", X"FF", -- MVI A 0xFF
		"01" & "110" & "111", -- MOV [HL] A
		X"20", X"00",
		
		others => X"00"
	);

	constant mem_init_MVI_MR: i8080_mem_blk(0 to 255) := (
		"01" & "111" & "110", X"03", X"00",
		X"FF",
		
		others => X"00"
	);

	constant mem_init_STAX: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"FF", -- MVI A 0xFF
		"00" & "000" & "110", X"00", -- MVI B 0xFF
		"00" & "001" & "110", X"20", -- MVI C 0xFF
		"00" & "010" & "110", X"00", -- MVI D 0xFF
		"00" & "011" & "110", X"21", -- MVI E 0xFF
		
		"000" & "0" & "0010", -- STAX BC
		"000" & "1" & "0010", -- STAX DE
		
		others => X"00"
	);

	constant mem_init_LDAX: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"FF", -- MVI A 0xFF
		"00" & "000" & "110", X"00", -- MVI B 0xFF
		"00" & "001" & "110", X"0c", -- MVI C 0xFF
		"00" & "010" & "110", X"00", -- MVI D 0xFF
		"00" & "011" & "110", X"0d", -- MVI E 0xFF

		"000" & "0" & "1010", -- LDAX BC
		"000" & "1" & "1010", -- LDAX DE
		
		X"DE",
		X"AD",
		
		others => X"00"
	);

	constant mem_init_INR: i8080_mem_blk(0 to 255) := (
		-- MVI random data into all registers
		"00" & "000" & "110", X"FF",
		"00" & "001" & "110", X"A4",
		"00" & "010" & "110", X"BB",
		"00" & "011" & "110", X"FF",
		"00" & "100" & "110", X"00",
		"00" & "101" & "110", X"F3",
--		"00" & "110" & "110", X"FF",
		"00" & "111" & "110", X"01",
		
		-- INR all registers
		"00" & "000" & "100", -- INR B
		"00" & "001" & "100", -- INR C
		"00" & "010" & "100", -- INR D
		"00" & "011" & "100", -- INR E
		"00" & "100" & "100", -- INR H
		"00" & "101" & "100", -- INR L
--		"00" & "110" & "100", -- INR *(HL)
		"00" & "111" & "100", -- INR A

		others => X"00"
	);
	
	constant mem_init_INR_M: i8080_mem_blk(0 to 255) := (
		"00" & "10" & "0001", X"04", X"00", -- LXI HL 0006h
		"00" & "110" & "100", -- increment (*HL)
		X"FF",
		
		others => X"00"
	);
	
	constant mem_init_DCR_M: i8080_mem_blk(0 to 255) := (
		"00" & "10" & "0001", X"04", X"00", -- LXI HL 0006h
		"00" & "110" & "101", -- increment (*HL)
		X"FF",
		
		others => X"00"
	);

	constant mem_init_CMA: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"0F", -- MVI A 0Fh
		"00101111", -- CMA
		
		others => X"00"
	);

	constant mem_init_DAA: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"70", -- MVI A 70h
		"00100111", -- DAA
		
		others => X"00"
	);

	constant mem_init_STC: i8080_mem_blk(0 to 255) := (
		"00110111", -- set carry
		
		others => X"00"
	);

	constant mem_init_CMC: i8080_mem_blk(0 to 255) := (
		"00110111", -- set carry
		"00111111", -- complement carry

		
		others => X"00"
	);

	constant mem_init_ADI: i8080_mem_blk(0 to 255) := (
		"00111110", X"01", -- MVI A 1h
		"11" & "000" & "110", X"80", -- ADI 80h
		
		others => X"00"
	);
	
	constant mem_init_XCHG: i8080_mem_blk(0 to 255) := (
		"00010001", X"EF", X"BE", -- LXI DE BEEFh
		"00100001", X"34", X"12", -- LXI HL 1234h
		"11101011", -- XCHG
		
		others => X"00"
	);
	
	constant mem_init_XTHL: i8080_mem_blk(0 to 255) := (
		"00110001", X"07", X"00", -- LXI SP BEEFh
		"00100001", X"34", X"12", -- LXI HL 1234h
		"11100011", -- XTHL
		
		X"EF", X"BE",
		
		others => X"00"
	);
	
	constant mem_init_INX: i8080_mem_blk(0 to 255) := (
		"00000001", X"AD", X"DE", -- bc
		"00010001", X"EF", X"BE", -- de
		"00100001", X"34", X"12", -- hl
		"00110001", X"78", X"56", -- sp
		
		"00" & "00" & "0011", -- INX BC
		"00" & "01" & "0011", -- INX DE
		"00" & "10" & "0011", -- INX HL
		"00" & "11" & "0011", -- INX SP

		"00000001", X"FF", X"FF", -- bc
		"00010001", X"00", X"00", -- de
		"00100001", X"FF", X"FE", -- hl
		"00110001", X"FE", X"FF", -- sp

		"00" & "00" & "0011", -- INX BC
		"00" & "01" & "0011", -- INX DE
		"00" & "10" & "0011", -- INX HL
		"00" & "11" & "0011", -- INX SP
		
		others => X"00"
	);	

	constant mem_init_DCX: i8080_mem_blk(0 to 255) := (
		"00000001", X"AD", X"DE", -- bc
		"00010001", X"EF", X"BE", -- de
		"00100001", X"34", X"12", -- hl
		"00110001", X"78", X"56", -- sp
		
		"00" & "00" & "1011", -- INX BC
		"00" & "01" & "1011", -- INX DE
		"00" & "10" & "1011", -- INX HL
		"00" & "11" & "1011", -- INX SP

		"00000001", X"FF", X"FF", -- bc
		"00010001", X"00", X"00", -- de
		"00100001", X"FF", X"FE", -- hl
		"00110001", X"FE", X"FF", -- sp

		"00" & "00" & "1011", -- INX BC
		"00" & "01" & "1011", -- INX DE
		"00" & "10" & "1011", -- INX HL
		"00" & "11" & "1011", -- INX SP
		
		others => X"00"
	);	

	
	constant mem_init_DAD: i8080_mem_blk(0 to 255) := (
		"00000001", X"AD", X"DE", -- bc
		"00010001", X"EF", X"BE", -- de
		"00100001", X"01", X"00", -- hl
		"00110001", X"78", X"56", -- sp
		
		"00" & "00" & "1001", -- DAD BC
		"00100001", X"01", X"00", -- hl
		
		"00" & "01" & "1001", -- DAD DE
		"00100001", X"01", X"00", -- hl
		
		"00" & "10" & "1001", -- DAD HL
		"00100001", X"01", X"00", -- hl
		
		"00" & "11" & "1001", -- DAD SP
		"00100001", X"01", X"00", -- hl
	
		others => X"00"
	);

	constant mem_init_SPHL: i8080_mem_blk(0 to 255) := (
		"00100001", X"01", X"00", -- hl
		"00110001", X"78", X"56", -- sp

		"11111001", -- SPHL
		
		others => X"00"
	);
	
	constant mem_init_PUSH: i8080_mem_blk(0 to 255) := (
		"00111110", X"01", -- MVI A 1h

		"00000001", X"AD", X"DE", -- bc
		"00010001", X"EF", X"BE", -- de
		"00100001", X"01", X"00", -- hl

		"00110001", X"30", X"00", -- sp

		"11" & "00" & "0101", -- push BC
		"11" & "01" & "0101", -- push DE
		"11" & "10" & "0101", -- push HL
		"11" & "11" & "0101", -- push A & PSW

		others => X"00"
	);

	constant mem_init_POP: i8080_mem_blk(0 to 255) := (
		"00111110", X"01", -- MVI A 1h

		"00000001", X"AD", X"DE", -- bc
		"00010001", X"EF", X"BE", -- de
		"00100001", X"01", X"00", -- hl

		"00110001", X"30", X"00", -- sp

		"11" & "00" & "0101", -- push BC
		"11" & "01" & "0101", -- push DE
		"11" & "10" & "0101", -- push HL
		"11" & "11" & "0101", -- push A & PSW
		
		-- Overwrite the registers so that we can tell when theyve been
		-- re-initalized
		"00111110", X"00", -- MVI A 1h

		"00000001", X"00", X"00", -- bc
		"00010001", X"00", X"00", -- de
		"00100001", X"00", X"00", -- hl

		"11" & "11" & "0001", -- pop A & PSW
		"11" & "10" & "0001", -- pop HL
		"11" & "01" & "0001", -- pop DE
		"11" & "00" & "0001", -- pop BC
		others => X"00"
	);

	constant mem_init_PCHL: i8080_mem_blk(0 to 255) := (
		"00100001", X"0C", X"00", -- hl
		"111" & "01" & "001", -- PCHL 0009h
		X"00", X"00",
		X"00", X"00", X"00", X"00", X"00",
		X"00",
		
		"00111110", X"AA", -- MVI A AAh
		
		others => X"00"
	);
	
	constant mem_init_JMP: i8080_mem_blk(0 to 255) := (
		"11000011", X"0A", X"00", -- JMP Ah
		X"00", X"00", X"00", X"00", X"00", X"00", X"00",
		"00111110", X"11",
		
		others => X"00"
	);
	
	constant mem_init_JMP_COND: i8080_mem_blk(0 to 255) := (
		"00111110", X"00", -- MVI A 0
		"11" & "011" & "010", X"0a", X"00", -- JC Ah
		"11" & "000" & "110", X"01", -- ADI 1
		"11000011", X"02", X"00", -- JMP 2h
		
		"00000001", X"AD", X"DE", -- bc
		"00010001", X"EF", X"BE", -- de

		others => X"00"
	);
	
	constant mem_init_CALL: i8080_mem_blk(0 to 255) := (
		"00110001", X"30", X"00", -- LXI SP
		"11" & "001" & "101", X"0a", X"00", -- CALL ah
		"00111110", X"F0", -- MVI A F0h
		X"00", X"00",
		"00111110", X"0F", -- MVI A 0Fh
	
		others => X"00"
	);
	
	constant mem_init_RET: i8080_mem_blk(0 to 255) := (
		"00110001", X"30", X"00", -- LXI SP
		"11" & "001" & "101", X"0a", X"00", -- CALL ah
		"00111110", X"AA", -- MVI A AAh
		X"00", X"00",
		"00111110", X"0F", -- MVI A 0Fh
		"11001001", -- RET
	
		others => X"00"
	);

	constant mem_init_CALL_COND: i8080_mem_blk(0 to 255) := (
		"00110001", X"30", X"00", -- LXI SP
		"11000011", X"09", X"00", -- JMP 9h (JUMP OVER PROC)
		"00111110", X"AA", -- MVI A AAh (PROC)
		"11001001", -- RET (ENDPROC)
		
		"11" & "000" & "110", X"01", -- ADI 1 (ADD1)
		"11" & "010" & "010", X"09", X"00", -- JNC (ADD1)
		"11" & "011" & "100", X"06", X"00", -- CALL IF C 6h (PROC)

		"00111110", X"0F", -- MVI A 0Fh
	
		others => X"00"
	);

	constant mem_init_RET_COND: i8080_mem_blk(0 to 255) := (
		"00110001", X"30", X"00", -- LXI SP
		"11000011", X"0e", X"00", -- JMP eh (JUMP OVER PROC)

		"11" & "000" & "110", X"01", -- ADI 1 (ADD 1)
		"11111110", X"45", -- CPI 45h
		"11001000", -- RET Z (ENDPROC)
		"11000011", X"06", X"00", -- JMP 6h (JUMP ADD 1)
		
		"00111110", X"20", -- MVI A 20h (PROC)
		"11001101", X"06", X"00", -- CALL 6h (PROC)		
		
		"00111110", X"0F", -- MVI A 0Fh
	
		others => X"00"
	);

	constant mem_init_ALU_R: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"00", -- MVI A 0xFF
		"00" & "000" & "110", X"07", -- MVI B 0xFF
		"00" & "001" & "110", X"0c", -- MVI C 0xFF
		"00" & "010" & "110", X"01", -- MVI D 0xFF
		"00" & "011" & "110", X"12", -- MVI E 0xFF
		
		"10" & "000" & "000", -- ADD B
		"10" & "000" & "001", -- ADD C
		"10" & "010" & "010", -- SUB D
		"10" & "111" & "011", -- CMP E
		
		others => X"00"
	);
	
	constant mem_init_ALU_M: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"00", -- MVI A 0x00

		"00100001", X"12", X"00", -- hl		
		"10" & "000" & "110", -- ADD hl
		"00100001", X"13", X"00", -- hl
		"10" & "000" & "110", -- ADD hl
		"00100001", X"14", X"00", -- hl
		"10" & "010" & "110", -- SUB hl
		"00100001", X"15", X"00", -- hl
		"10" & "111" & "110", -- CMP hl

		X"07",
		X"0c",
		X"01",
		X"12",
		
		
		others => X"00"
	);
	
	constant mem_init_EIDI: i8080_mem_blk(0 to 255) := (
		"11111011", -- enable
		"11110011", -- disable
		"11111011", -- enable
		"11110011", -- disable
		
		others => X"00"
	);
	
	constant mem_init_IN: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"BB", -- MVI A 0xBB
		"11011011", X"09", -- IN 9h
		
		others => X"00"
	);
	constant port_mem_init_IN: i8080_port_blk(0 to 255) := (
		X"00", X"00", X"00", X"00",
		X"00", X"00", X"00", X"00",
		X"00", X"CC",
		
		others => X"00"
	);

	constant mem_init_OUT: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"BB", -- MVI A 0xBB
		"11010011", X"09", -- OUT 9h
		
		others => X"00"
	);
	constant port_mem_init_OUT: i8080_port_blk(0 to 255) := (
		X"00", X"00", X"00", X"00",
		X"00", X"00", X"00", X"00",
		X"00", X"CC",
		
		others => X"00"
	);

	constant mem_init_RST: i8080_mem_blk(0 to 255) := (
		"00110001", X"30", X"00", -- LXI SP
		"11" & "111" & "111",
		
		X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", -- 11
		X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", -- 19
		X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", -- 27
		X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", -- 35
		X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", -- 43
		X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", -- 51
		X"00", X"00", X"00", X"00", -- 55
		
		"00" & "111" & "110", X"BB", -- MVI A 0xBB
		"11" & "000" & "110", X"80", -- ADI 80h
		
		others => X"00"
	);

	constant mem_init_HW_INT: i8080_mem_blk(0 to 255) := (
		X"FB", -- ei
		X"31", X"00", X"01", -- LXI sp, $100
		X"3E", X"20", -- MVI a, $20
		X"C3", X"06", X"00", -- LOOP: JMP LOOP
		
		others => X"00"
	);

	constant mem_init_MVI_BUG_0: i8080_mem_blk(0 to 255) := (
		X"01", X"80", X"00", -- LXI b, 0x80 (should be 0x8000)
		X"3E", X"20", -- MVI a, 20; (init_screen)
		X"02", -- stax b
		X"03", -- inx b
		X"79", -- mov a, c
		X"C3", X"03", X"00", -- jmp init_screen
		
		others => X"00"
	);

	constant p: time := 10 ns;
	signal clk: std_logic := '1';

	type memory_in_T is record
		addr: std_logic_vector(15 downto 0);
		di: std_logic_vector(7 downto 0);
		en, we, port_en: std_logic;
	end record;
	type memory_out_T is record
		do: std_logic_vector(7 downto 0);
		ready: std_logic;
	end record;

	signal mem_in: memory_in_T := (X"0000", X"00", '0', '0', '0');
	signal mem_out: memory_out_T := (X"00", '0');
	signal int_out: memory_out_T := (X"00", '0');
	
	signal fin: i8080_core_in := I8080_CORE_IN_DEFAULT;
	signal fout: i8080_core_out := I8080_CORE_OUT_DEFAULT;
	
	signal hw_int_issued: boolean := false;
begin
	clk <= not clk after p/2;

	mux_cpu_input: process (mem_out, int_out, hw_int_issued)
	begin
		if not hw_int_issued then
			fin.di <= mem_out.do;
			fin.ready <= mem_out.ready;
		else
			fin.di <= int_out.do;
			fin.ready <= int_out.ready;
		end if;
	end process;
		
	mem_in.addr <= fout.addr;
	mem_in.di <= fout.do;
	mem_in.en <= fout.en;
	mem_in.we <= fout.wren;
	mem_in.port_en <= fout.port_en;
	
--	generate_hw_int: process
--	begin
--		wait for 1.5 us;
--		
--		hw_int_issued <= true;
--		fin.int <= '1';
--		wait for 5*p;
--		
--		int_out.do <= "11" & "111" & "111";
--		int_out.ready <= '1';
--		wait for p;
--
--		int_out.do <= X"00";
--		int_out.ready <= '0';
--		wait for p;
--
--		wait;
--	end process;
	
	cpu: entity work.i8080_core(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		fin => fin,
		fout => fout
	);
	
	mem: entity work.i8080_memory_sim(rtl)
	generic map (
		mem_init => mem_init_MVI_BUG_0,
		port_init => i8080_port_blk_default
	)
	port map (
		clk => clk, reset => '0',
		
		addr => mem_in.addr,
		en => mem_in.en,
		we => mem_in.we,
		port_en => mem_in.port_en,
		di => mem_in.di,
		
		do => mem_out.do,
		ready => mem_out.ready
	);
end;

