library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;
use work.i8080_memory_sim_util.all;

entity i8080_memory_sim_tb is
end;

architecture tb of i8080_memory_sim_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '1';

	type memory_in_T is record
		addr: std_logic_vector(15 downto 0);
		di: std_logic_vector(7 downto 0);
		en, we, port_en: std_logic;
	end record;

	procedure mwrite(signal mem: out memory_in_T;
		constant addr: in std_logic_vector(15 downto 0);
		constant di: in std_logic_vector(7 downto 0);
		constant port_en: in std_logic
	) is
	begin
		mem.addr <= addr;
		mem.di <= di;
		mem.en <= '1';
		mem.we <= '1';
		mem.port_en <= port_en;
	end;

	procedure mdefault(signal mem: out memory_in_T) is
	begin
		mem.addr <= X"0000";
		mem.di <= X"00";
		mem.en <= '0';
		mem.we <= '0';
		mem.port_en <= '0';
	end;

	procedure mread(signal mem: out memory_in_T;
		constant addr: in std_logic_vector(15 downto 0);
		constant port_en: in std_logic
	) is
	begin
		mem.addr <= addr;
		mem.di <= X"00";
		mem.en <= '1';
		mem.we <= '0';
		mem.port_en <= port_en;
	end;
	
	signal mem_in: memory_in_T := (X"0000", X"00", '0', '0', '0');
begin
	clk <= not clk after p/2;

	testbench: process is
	begin
		wait for p;
		
		mwrite(mem_in, X"0002", X"FF", '0');
		wait for p;

		mdefault(mem_in);
		wait for p;

		mread(mem_in, X"0002", '0');
		wait for p;
		
		mdefault(mem_in);
		wait for p;
				
		wait;
	end process;

	uut: entity work.i8080_memory_sim(rtl)
	port map (
		clk => clk, reset => '0',
		
		addr => mem_in.addr,
		en => mem_in.en,
		we => mem_in.we,
		port_en => mem_in.port_en,
		di => mem_in.di,
		do => open,
		ready => open
	);
end;

