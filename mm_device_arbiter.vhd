library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mm_device_util.all;

entity mm_device_arbiter is
	port (
		sysmem_dev_iface_out: in mm_iface_out;
		vgamem_dev_iface_out: in mm_iface_out;
		kbd_dev_iface_out: in mm_iface_out;
		ssd_dev_iface_out: in mm_iface_out;
		null_dev_iface_out: in mm_iface_out;

		sysmem_dev_iface_in: out mm_iface_in := mm_iface_in_default;
		vgamem_dev_iface_in: out mm_iface_in := mm_iface_in_default;
		kbd_dev_iface_in: out mm_iface_in := mm_iface_in_default;
		ssd_dev_iface_in: out mm_iface_in := mm_iface_in_default;
		null_dev_iface_in: out mm_iface_in := mm_iface_in_default;
		
		cpu_iface_out: in mm_iface_in;
		cpu_iface_in: out mm_iface_out := mm_iface_out_default
	);
end entity;

architecture rtl of mm_device_arbiter is
	type access_mode_T is (
		SYSTEM_MEMORY,
		VGA_MEMORY,
		KBD_SCANCODE,
		SSD_DISPLAY,
		NULL_DEVICE,
		
		NONE
	);
	
	signal am: access_mode_T;
begin
	
	mux_device_inputs_for_write: process (am, cpu_iface_out) is
	begin
		-- Set all interface defaults
		sysmem_dev_iface_in <= mm_iface_in_default;
		vgamem_dev_iface_in <= mm_iface_in_default;
		kbd_dev_iface_in <= mm_iface_in_default;
		ssd_dev_iface_in <= mm_iface_in_default;
		null_dev_iface_in <= mm_iface_in_default;
	
		case am is
		when SYSTEM_MEMORY =>
			sysmem_dev_iface_in <= cpu_iface_out;

		when VGA_MEMORY =>
			vgamem_dev_iface_in <= cpu_iface_out;

		when KBD_SCANCODE =>
			kbd_dev_iface_in <= cpu_iface_out;
			
		when SSD_DISPLAY =>
			ssd_dev_iface_in <= cpu_iface_out;
			
		when NULL_DEVICE =>
			null_dev_iface_in <= cpu_iface_out;
		
		when NONE =>
			null;
			
		end case;
	end process;
	
	mux_device_outputs_for_read: process (
		sysmem_dev_iface_out,
		vgamem_dev_iface_out,
		kbd_dev_iface_out,
		ssd_dev_iface_out,
		null_dev_iface_out ) is
	begin
		-- Whoever asserts ready signal gets to talk to the cpu.
		-- Collisions are priority-encoder-resolved by the following if-elif ladder.
		if sysmem_dev_iface_out.ready = '1' then
			cpu_iface_in.d <= sysmem_dev_iface_out.d;
			cpu_iface_in.ready <= sysmem_dev_iface_out.ready;
			
		elsif vgamem_dev_iface_out.ready = '1' then
			cpu_iface_in.d <= vgamem_dev_iface_out.d;
			cpu_iface_in.ready <= vgamem_dev_iface_out.ready;
			
		elsif kbd_dev_iface_out.ready = '1' then
			cpu_iface_in.d <= kbd_dev_iface_out.d;
			cpu_iface_in.ready <= kbd_dev_iface_out.ready;

		elsif ssd_dev_iface_out.ready = '1' then
			cpu_iface_in.d <= ssd_dev_iface_out.d;
			cpu_iface_in.ready <= ssd_dev_iface_out.ready;
			
		elsif null_dev_iface_out.ready = '1' then
			cpu_iface_in.d <= null_dev_iface_out.d;
			cpu_iface_in.ready <= null_dev_iface_out.ready;

		else
			cpu_iface_in.d <= X"00";
			cpu_iface_in.ready <= '0';
		
		end if;
	end process;
	
	-- Combinatorially set the access mode signal.
	do_memory_mapping: process (cpu_iface_out) is
		variable port_addr: std_logic_vector(7 downto 0) := X"00";
	begin
		port_addr := cpu_iface_out.addr(7 downto 0);
	
		-- Assert that a memory request is present
		if cpu_iface_out.en = '1' then
			
			-- Handle port conditions
			if cpu_iface_out.port_en = '1' then
				
				-- Keyboard scancode location
				if port_addr = X"80" or port_addr = X"81"
					or port_addr = X"82" or port_addr = X"83"
				  then
					am <= KBD_SCANCODE;
				elsif port_addr >= X"00" and port_addr <= X"03" then
					am <= SSD_DISPLAY;
				else
					am <= NULL_DEVICE;
				end if;
				
			-- Handle pure address condition
			else
				-- Handle RAM access
				if cpu_iface_out.addr >= X"8000"
					and cpu_iface_out.addr <= X"a000"
				then
					am <= VGA_MEMORY;
				else
					am <= SYSTEM_MEMORY;
				end if;
				
				-- In the future, we can memory map anything we
				-- want here, e.g. video buffers, character glyph sheets, etc.
				-- NOTE: Too many entries will increase multiplexer
				-- complexity and thus may require pipelining to meet timing.
				
			end if;
			
		else
			-- No memory request
			am <= NONE;
			
		end if;
		
	end process;
end architecture;

