library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;
use work.i8080_memory_sim_util.all;

entity i8080_memory_sim is
	generic (
		mem_init: i8080_mem_blk := i8080_mem_blk_default;
		port_init: i8080_port_blk := i8080_port_blk_default
	);
	port (
		clk, reset: in std_logic;
		
		addr: in std_logic_vector(15 downto 0);
		en, we, port_en: in std_logic;
		di: in std_logic_vector(7 downto 0);
		do: out std_logic_vector(7 downto 0) := X"00";
		ready: out std_logic := '0'
	);
end;

architecture rtl of i8080_memory_sim is
	function to_int(arg: std_logic_vector) return integer is
	begin
		return to_integer(unsigned(arg));
	end function;

	type memory_interface is record
		addr: std_logic_vector(15 downto 0);
		en: std_logic;
		wren: std_logic;
		port_en: std_logic;
		di: std_logic_vector(7 downto 0);
	end record;
	constant MEMORY_INTERFACE_DEFAULT: memory_interface := (
		addr => X"0000",
		en => '0',
		wren => '0',
		port_en => '0',
		di => X"00"
	);

	type mem_op_rq_T is (none, read_rq, write_rq);
	signal mem_op_rq: mem_op_rq_t := none;

	signal mem_intf: memory_interface := MEMORY_INTERFACE_DEFAULT;
	
	signal memory: i8080_mem_blk(mem_init'range) := mem_init;
	signal port_memory: i8080_port_blk(port_init'range) := port_init;
	
	signal do_reg: std_logic_vector(7 downto 0) := X"00";
begin
	do <= do_reg;

	ready_signal_ctrl: process (clk, reset, mem_op_rq) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				ready <= '0';
			
			else

				if mem_op_rq = read_rq then
					ready <= '1';
				else
					ready <= '0';
				end if;
			
			end if;
		end if;
	end process;
	
	mem_op_rq_eval: process (mem_intf) is
	begin
		if mem_intf.en = '1' then
			if mem_intf.wren = '1' then
				mem_op_rq <= write_rq;
			elsif mem_intf.wren = '0' then
				mem_op_rq <= read_rq;
			else
				assert false report "Invalid state of mem_intf.wren"
					severity Error;
				mem_op_rq <= none;
			end if;
		else
			mem_op_rq <= none;
		end if;
	end process;
	
	mem_intf_register: process (clk, reset, addr, en, we, port_en, di) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				mem_intf <= MEMORY_INTERFACE_DEFAULT;
		
			else
				mem_intf.addr <= addr;
				mem_intf.en <= en;
				mem_intf.wren <= we;
				mem_intf.port_en <= port_en;
				mem_intf.di <= di;

			end if;
		end if;
	end process;
	
	write_ctrl: process (clk, reset, mem_op_rq, mem_intf)
	begin
		if rising_edge(clk) then
		
			if reset = '1' then
				memory <= mem_init;
			
			else
				if mem_op_rq = write_rq then
					if mem_intf.port_en = '0' then
						memory(to_int(mem_intf.addr)) <= mem_intf.di;
					elsif mem_intf.port_en = '1' then
						port_memory(to_int(mem_intf.addr(7 downto 0))) <= mem_intf.di;
					else
						assert false report "mem_intf.port_en is not a well-"
							& "defined value." severity Error;
					end if;
				end if;
			end if;
		
		end if;
	end process;
	
	read_ctrl: process (clk, reset, mem_op_rq, mem_intf, memory, port_memory)
	begin
		if rising_edge(clk) then
		
			if reset = '1' then
				do_reg <= X"00";
			
			else
				if mem_op_rq = read_rq then
					if mem_intf.port_en = '0' then
						do_reg <= memory(to_int(mem_intf.addr));
					elsif mem_intf.port_en = '1' then
						do_reg <= port_memory(to_int(mem_intf.addr(7 downto 0)));
					else
						assert false report "mem_intf.port_en is not a well-"
							& "defined value." severity Error;
					end if;
				end if;
			end if;
		
		end if;
	end process;
		
end architecture;

