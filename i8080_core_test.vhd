library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;

entity i8080_core_test is
	port (
		clk: in std_logic;
		
		dig_en: out std_logic_vector(7 downto 0);
		seg_cs: out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of i8080_core_test is
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

	signal regce: std_logic := '0';
	signal en: std_logic := '0';

	signal d7, d6, d5, d4, d3, d2, d1, d0: std_logic_vector(7 downto 0) := X"00";
begin


	en <= fout.en and (not fout.port_en);

	ramb_read_ctrl: block
		signal rdy: std_logic_vector(0 to 1) := "00";
	begin
		ramb_ctrl_proc: process (clk, fout.en, fout.wren, rdy)
		begin
			if rising_edge(clk) then
				rdy(0) <= fout.en and (not fout.wren);
				rdy(1) <= rdy(0);
			end if;
		end process;
		
		regce <= rdy(0);
		fin.ready <= rdy(1);
	end block;

	ramb_inst: entity work.ramb64x8(structural)
	port map (
		clka => clk,
		addra => fout.addr,
		dia => fout.do,
		doa => fin.di,
		
		ena => en,
		regcea => regce,
		rstrama => '0',
		rstrega => '0',
		wea => fout.wren,
		
		clkb => clk,
		addrb => X"0000",
		dib => X"00",
		dob => open,
		
		enb => '0',
		regceb => '0',
		rstramb => '0',
		rstregb => '0',
		web => '0'
	);

	cpu0: entity work.i8080_core(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		fin => fin,
		fout => fout
	);

	d3 <= hex(fout.addr(15 downto 12));
	d2 <= hex(fout.addr(11 downto 8));
	d1 <= hex(fout.addr(7 downto 4));
	d0 <= hex(fout.addr(3 downto 0));

	ssd_ctrl_proc: process (clk, fout.en, fout.wren, fout.port_en,
		fout.do, fout.addr)
	is
--		variable idx: natural range 0 to 3 := 0;
		variable low_addr: std_logic_vector(1 downto 0) := "00";
	begin
--		idx := to_integer(unsigned(fout.addr(1 downto 0)));
		low_addr := fout.addr(1 downto 0);
		
		if rising_edge(clk) then
			if (fout.en and fout.wren and fout.port_en) = '1' then
				case low_addr is
				when "11" =>
					d7 <= hex(fout.do(7 downto 4));
					d6 <= hex(fout.do(3 downto 0));
				when "10" =>
					d5 <= hex(fout.do(7 downto 4));
					d4 <= hex(fout.do(3 downto 0));
				when others =>
					null;
				end case;
			end if;
		end if;
	end process;

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
end;

