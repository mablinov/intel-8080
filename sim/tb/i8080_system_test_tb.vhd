library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;
use work.i8080_util.all;
use work.i8080_memory_sim_util.all;
use work.mm_device_util.all;

entity i8080_system_test_tb is
--	port (
--		clk: in std_logic;
--		
--		ps2_clk, ps2_data: in std_logic;
--		
--		dig_en: out std_logic_vector(7 downto 0);
--		seg_cs: out std_logic_vector(7 downto 0)
--	);
end;

architecture rtl of i8080_system_test_tb is
	function hex(arg: std_logic_vector(3 downto 0)) return std_logic_vector is
		variable seg_cs: std_logic_vector(7 downto 0) := X"00";
	begin
		case arg is
			when "0000" => seg_cs := "11111100";
			when "0001" => seg_cs := "01100000";
			when "0010" => seg_cs := "11011010";
			when "0011" => seg_cs := "11110010";
			when "0100" => seg_cs := "01100110";
			when "0101" => seg_cs := "10110110";
			when "0110" => seg_cs := "10111110";
			when "0111" => seg_cs := "11100000";
			when "1000" => seg_cs := "11111110";
			when "1001" => seg_cs := "11100110";
			when "1010" => seg_cs := "11101110";
			when "1011" => seg_cs := "00111110";
			when "1100" => seg_cs := "10011100";
			when "1101" => seg_cs := "01111010";
			when "1110" => seg_cs := "10011110";
			when "1111" => seg_cs := "10001110";
			when others => seg_cs := "00000010";
		end case;
		
		return seg_cs;
	end function;
	
	signal fout: i8080_core_out := I8080_CORE_OUT_DEFAULT;
	signal fin: i8080_core_in := I8080_CORE_IN_DEFAULT;

	signal sysmem_dev_iface_in: mm_iface_in := mm_iface_in_default;
	signal sysmem_dev_iface_out: mm_iface_out := mm_iface_out_default;
	signal vgamem_dev_iface_in: mm_iface_in := mm_iface_in_default;
	signal vgamem_dev_iface_out: mm_iface_out := mm_iface_out_default;
	signal kbd_dev_iface_in: mm_iface_in := mm_iface_in_default;
	signal kbd_dev_iface_out: mm_iface_out := mm_iface_out_default;
	signal ssd_dev_iface_in: mm_iface_in := mm_iface_in_default;
	signal ssd_dev_iface_out: mm_iface_out := mm_iface_out_default;
	signal null_dev_iface_in: mm_iface_in := mm_iface_in_default;
	signal null_dev_iface_out: mm_iface_out := mm_iface_out_default;

	signal cpu_iface_in: mm_iface_out := mm_iface_out_default;
	signal cpu_iface_out: mm_iface_in := mm_iface_in_default;

	signal b3, b2, b1, b0: std_logic_vector(7 downto 0) := X"00";
	signal d7, d6, d5, d4, d3, d2, d1, d0: std_logic_vector(7 downto 0) := X"00";
	
	-- PS2 Interface signals
	signal ps2_keycode: ps2_keycode_T := PS2_KEY_UNKNOWN;
	signal ps2_make, ps2_err: std_logic := '0';
	
	signal ps2_keycode_byte: std_logic_vector(7 downto 0) := X"00";

	constant mem_init: i8080_mem_blk(0 to 255) := (
		"00" & "111" & "110", X"BB", -- MVI A 0xBB
		"11010011", X"09", -- OUT 9h
		"00" & "111" & "110", X"00", -- MVI A 0x00
		"11011011", X"80", -- IN 80h
		
		others => X"00"
	);
	constant port_mem_init: i8080_port_blk(0 to 255) := (
		X"00", X"00", X"00", X"00",
		X"00", X"00", X"00", X"00",
		X"00", X"CC",
		
		others => X"00"
	);
	
	-- Testbench signals
	constant p: time := 10 ns;
	signal clk: std_logic := '1';
		
	signal ps2_clk: std_logic := '1';
	signal ps2_data: std_logic := '0';
		
	signal dig_en: std_logic_vector(7 downto 0) := X"00";
	signal seg_cs: std_logic_vector(7 downto 0) := X"00";

begin

	ps2_keycode <= PS2_KEY_9;
	ps2_make <= '1';
	ps2_err <= '1';
	-- Testbench driver signals
	clk <= not clk after p/2;
--	testbench: process
--	begin
--		wait;
--	end process;

	ps2_keycode_byte <= std_logic_vector(
		to_unsigned(ps2_keycode_T'pos(ps2_keycode), 8));

	kbd_mm_dev_inst: entity work.kbd_mm_device(rtl)
	port map (
		clk => clk,
		i => kbd_dev_iface_in,
		o => kbd_dev_iface_out,
		
		ps2_keycode => ps2_keycode,
		ps2_make => ps2_make,
		ps2_err => ps2_err
	);
	
	ps2_ctrl_inst: entity work.ps2_interface(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		
		keycode => open, --ps2_keycode,
		kc_strobe => open,
		make => open, --ps2_make,
		err => open --ps2_err
	);
	
	ssd_mm_dev_inst: entity work.ssd_mm_device(rtl)
	port map (
		clk => clk,
		i => ssd_dev_iface_in,
		o => ssd_dev_iface_out,
		
		b3 => b3, b2 => b2, b1 => b1, b0 => b0
	);
	
	d7 <= hex(b3(7 downto 4));
	d6 <= hex(b3(3 downto 0));
	d5 <= hex(b2(7 downto 4));
	d4 <= hex(b2(3 downto 0));
	d3 <= hex(b1(7 downto 4));
	d2 <= hex(b1(3 downto 0));
	d1 <= hex(ps2_keycode_byte(7 downto 4));
	d0 <= hex(ps2_keycode_byte(3 downto 0));
	
	ssd_ctrl_inst: entity work.ssd_ctrl(rtl)
	port map (
		clk => clk,
		d7 => d7,
		d6 => d6,
		d5 => d5,
		d4 => d4,
		d3 => d3,
		d2 => d2,
		d1 => d1,
		d0 => d0,
		dig_en => dig_en,
		seg_cs => seg_cs
	);

--	sysmem_dev_inst: entity work.sysmem_device(rtl)
--	port map (
--		clk => clk,
--		i => sysmem_dev_iface_in,
--		o => sysmem_dev_iface_out
--	);

	memory_sim_inst: entity work.i8080_memory_sim(rtl)
	generic map (
		mem_init => mem_init,
		port_init => port_mem_init
	)
	port map (
		clk => clk, reset => '0',
		
		addr => sysmem_dev_iface_in.addr,
		en => sysmem_dev_iface_in.en,
		we => sysmem_dev_iface_in.we,
		port_en => sysmem_dev_iface_in.port_en,
		di => sysmem_dev_iface_in.d,
		
		do => sysmem_dev_iface_out.d,
		ready => sysmem_dev_iface_out.ready
	);

	-- CPU signals fanout
	cpu_iface_out.addr <= fout.addr;
	cpu_iface_out.d <= fout.do;
	cpu_iface_out.en <= fout.en;
	cpu_iface_out.we <= fout.wren;
	cpu_iface_out.port_en <= fout.port_en;
	
	fin.di <= cpu_iface_in.d;
	fin.ready <= cpu_iface_in.ready;

	mm_dev_arb_inst: entity work.mm_device_arbiter(rtl)
	port map (
		sysmem_dev_iface_out => sysmem_dev_iface_out,
		vgamem_dev_iface_out => null_dev_iface_out,
		kbd_dev_iface_out => kbd_dev_iface_out,
		ssd_dev_iface_out => ssd_dev_iface_out,
		null_dev_iface_out => null_dev_iface_out,
		
		sysmem_dev_iface_in => sysmem_dev_iface_in,
		vgamem_dev_iface_in => open, --null_dev_iface_in,
		kbd_dev_iface_in => kbd_dev_iface_in, --null_dev_iface_in,
		ssd_dev_iface_in => ssd_dev_iface_in,
		null_dev_iface_in => open, --null_dev_iface_in,

		cpu_iface_out => cpu_iface_out,
		cpu_iface_in => cpu_iface_in
	);

	cpu0: entity work.i8080_core(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		fin => fin,
		fout => fout
	);
end architecture;

