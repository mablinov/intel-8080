library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;
use work.i8080_util.all;
use work.i8080_memory_sim_util.all;

entity i8080_core_hw_int_tb is
end;

architecture tb of i8080_core_hw_int_tb is
	constant port_mem_init_OUT: i8080_port_blk(0 to 255) := (
		X"00", X"00", X"00", X"00",
		X"00", X"00", X"00", X"00",
		X"00", X"CC",
		
		others => X"00"
	);

	constant mem_init_RST: i8080_mem_blk(0 to 255) := (
		"00110001", X"f0", X"00", -- LXI SP
		"11" & "111" & "011", -- EI
		
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

	constant p: time := 10 ns;
	signal clk: std_logic := '1';

	-- PS2 Keyboard interface signals
	signal ps2_clk: std_logic := '1';
	signal ps2_data, kc_strobe: std_logic := '0';
	signal keycode: ps2_keycode_T := PS2_KEY_UNKNOWN;
	signal keycode_slv: std_logic_vector(7 downto 0) := X"00";
	
	-- Memory interface signals
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
	
	mux_cpu_input: process (fout, mem_out, int_out, hw_int_issued)
		type access_mm_device_T is (MAIN_SYSTEM_MEMORY, KBD_SCANCODE_PORT,
			VGA_ADDR_HI, VGA_ADDR_LO, VGA_BYTE);
		variable ammd: access_mm_device_T := MAIN_SYSTEM_MEMORY;
	begin
		-- Attach keyboard scancode to port 0x80
		if fout.addr(7 downto 0) = X"80"
			and fout.en = '1' and fout.wren = '0' and fout.port_en = '1'
		then
			
	
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
	
	generate_hw_int: process
	begin
		wait for 1.5 us;
		
		fin.int <= '1';
		wait for 5*p;
		
		int_out.do <= X"FF";
		int_out.ready <= '1';
		wait for p;

		int_out.do <= X"00";
		int_out.ready <= '0';
		wait for p;

		wait;
	end process;

	cpu: entity work.i8080_core(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		fin => fin,
		fout => fout
	);
	
	mem: entity work.i8080_memory_sim(rtl)
	generic map (
		mem_init => mem_init_RST,
		port_init => port_mem_init_OUT
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
	

	int_out.do <= keycode_slv;
	
	ps2_int_ctrl: process (clk, kc_strobe, fout.intack)
	begin
		if rising_edge(clk) then
			if kc_strobe = '1' then
				hw_int_issued <= true;
				keycode_slv <= std_logic_vector(to_unsigned(
					ps2_keycode_T'pos(keycode), 8));
			elsif fout.intack = '1' then
				hw_int_issued <= false;
				keycode_slv <= X"00";
			end if;
		end if;

		if fout.intack = '1' then
			int_out.ready <= '1';
			int_out.do <= X"FF";
		else
			int_out.ready <= '0';
			int_out.do <= X"00";
		end if;
	end process;
	
	ps2_iface: entity work.ps2_interface
	port map (
		clk => clk, en => '1', reset => '0',
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		
		keycode => keycode,
		kc_strobe => kc_strobe,
		make => open,
		err => open
	);

end;

