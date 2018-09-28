library ieee;
use ieee.std_logic_1164.all;

package mm_device_util is
	type mm_iface_in is record
		addr: std_logic_vector(15 downto 0);
		d: std_logic_vector(7 downto 0);
		en, we, port_en: std_logic;
	end record;
	constant mm_iface_in_default: mm_iface_in := (
		addr => X"0000",
		d => X"00",
		en => '0', we => '0', port_en => '0'
	);
	
	type mm_iface_out is record
		d: std_logic_vector(7 downto 0);
		ready: std_logic;
	end record;
	constant mm_iface_out_default: mm_iface_out := (
		d => X"00",
		ready => '0'
	);

	type mm_iface is record
		i: mm_iface_in;
		o: mm_iface_out;
	end record;
end package;

