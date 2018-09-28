library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.i8080_util.all;
use work.i8080_alu_util.all;

entity i8080_alu_tb is
end entity;

architecture behavioural of i8080_alu_tb is
	function str(slv: std_logic_vector) return string is
    	variable ret: string(1 to slv'length) := (others => ' ');
        variable j: positive := 1;
    begin
    	for i in slv'range loop
			case slv(i) is
            	when '0' => ret(j) := '0';
                when '1' => ret(j) := '1';
                when others => ret(j) := 'X';
            end case;
            
            j := j + 1;
        end loop;
        
        return ret;
    end;
    
	constant p: time := 10 ns;
	signal clk: std_logic := '1';
	
	signal cs: alu_control_signals := ALU_CONTROL_SIGNALS_DEFAULT;
	signal lhs, rhs: std_logic_vector(7 downto 0) := X"00";
	signal result: std_logic_vector(7 downto 0) := X"00";
	signal flags: i8080_flags := ('0', '1', '0', '1', '0');
	
	function slv(i: integer) return std_logic_vector is
		variable r: std_logic_vector(7 downto 0) := X"00";
	begin
		r := std_logic_vector(to_signed(i, r'length));
		return r;
	end function;

	procedure test_conversion_functions is
	begin
		-- Test the slv conversion function
		report "slv(32) = " & str(slv(32));
		report "slv(-32) = " & str(slv(-32));
	end procedure;
	
	procedure test_alu(
		signal lhs, rhs: out std_logic_vector(7 downto 0);
		signal cs: out alu_control_signals;
		constant l, r: in integer;
		constant op: in alu_operation;
		constant op2: in alu_operation
	) is
	begin
		lhs <= slv(l);
		rhs <= slv(r);
		cs.lhs_ce <= '1';
		cs.rhs_ce <= '1';
		wait for p;
		
		lhs <= X"00";
		rhs <= X"00";
		cs.lhs_ce <= '0';
		cs.rhs_ce <= '0';
		
		cs.op <= op;
		wait for p;
		
		cs.op <= ALU_OP_NONE;
		
		if op2 /= ALU_OP_NONE then
			wait for p;

			cs.op <= op2;
			wait for p;
		end if;
		
		cs.op <= ALU_OP_NONE;
		wait for p;
		
	end procedure;
	
	procedure test_alu(
		signal lhs, rhs: out std_logic_vector(7 downto 0);
		signal cs: out alu_control_signals;
		constant l, r: in std_logic_vector(7 downto 0);
		constant op: in alu_operation;
		constant op2: in alu_operation
	) is
		variable li, ri: integer;
	begin
		li := to_integer(unsigned(l));
		ri := to_integer(unsigned(r));
		test_alu(lhs, rhs, cs, li, ri, op, op2);
	end procedure;
	
	type test_vector is (TestADD, TestADC, TestSUB, TestSBB,
		TestCMA,
		TestSTC, TestCMC,
		TestRLC, TestRRC, TestRAL, TestRAR,
		
		TestDAA,
		
		TestINC,
		TestDEC,
		
		Finished
	);
	
	signal tv: test_vector := TestADD;
begin
	clk <= not clk after p/2;

	testbench: process
	begin
		wait for 2*p;
		
		tv <= testADD;
		test_alu(lhs, rhs, cs, 5, 6, ALU_OP_ADD, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, 30, -30, ALU_OP_ADD, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, 12, -65, ALU_OP_ADD, ALU_OP_SET_SZP_FLAGS);

		tv <= testADC;
		test_alu(lhs, rhs, cs, 176, 134, ALU_OP_ADD, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, 43, 19, ALU_OP_ADC, ALU_OP_SET_SZP_FLAGS);
		
		tv <= testSUB;
		test_alu(lhs, rhs, cs, 66, 34, ALU_OP_SUB, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, 66, 114, ALU_OP_SUB, ALU_OP_SET_SZP_FLAGS);
		
		tv <= testSBB;
		test_alu(lhs, rhs, cs, 67, 34, ALU_OP_SUB, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, 55, 100, ALU_OP_SBB, ALU_OP_SET_SZP_FLAGS);
		
		tv <= testCMA;
		test_alu(lhs, rhs, cs, "11110000", X"00", ALU_OP_CMA, ALU_OP_SET_SZP_FLAGS);
		
		tv <= testRLC;
		test_alu(lhs, rhs, cs, "00010000", X"00", ALU_OP_RLC, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, "10000000", X"00", ALU_OP_RLC, ALU_OP_SET_SZP_FLAGS);

		tv <= testRRC;
		test_alu(lhs, rhs, cs, "00000110", X"00", ALU_OP_RRC, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, "00100001", X"00", ALU_OP_RRC, ALU_OP_SET_SZP_FLAGS);

		tv <= testSTC;
		test_alu(lhs, rhs, cs, X"00", X"00", ALU_OP_STC, ALU_OP_NONE);
		
		tv <= testCMC;
		test_alu(lhs, rhs, cs, x"00", X"00", ALU_OP_CMC, ALU_OP_NONE);

		tv <= testRAL;
		test_alu(lhs, rhs, cs, "00000110", X"00", ALU_OP_RAL, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, "10100000", X"00", ALU_OP_RAL, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, "01000000", X"00", ALU_OP_RAL, ALU_OP_SET_SZP_FLAGS);
		
		tv <= testSTC;
		test_alu(lhs, rhs, cs, X"00", X"00", ALU_OP_STC, ALU_OP_NONE);
		
		tv <= testCMC;
		test_alu(lhs, rhs, cs, x"00", X"00", ALU_OP_CMC, ALU_OP_NONE);

		tv <= testRAR;
		test_alu(lhs, rhs, cs, "00000110", X"00", ALU_OP_RAR, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, "00000011", X"00", ALU_OP_RAR, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, "00000001", X"00", ALU_OP_RAR, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, "10000000", X"00", ALU_OP_RAR, ALU_OP_SET_SZP_FLAGS);
		
		tv <= TestDAA;
		test_alu(lhs, rhs, cs, X"28", X"63", ALU_OP_ADD, ALU_OP_SET_SZP_FLAGS);
		test_alu(lhs, rhs, cs, X"8b", X"00", ALU_OP_DAA, ALU_OP_SET_SZP_FLAGS);
		
		tv <= TestINC;
		test_alu(lhs, rhs, cs, X"00", X"00", ALU_OP_INC, ALU_OP_NONE);
		test_alu(lhs, rhs, cs, X"FF", X"00", ALU_OP_INC, ALU_OP_NONE);
		
		tv <= TestDEC;
		test_alu(lhs, rhs, cs, X"00", X"00", ALU_OP_DEC, ALU_OP_NONE);
		test_alu(lhs, rhs, cs, X"FF", X"00", ALU_OP_DEC, ALU_OP_NONE);
		
		
		
		tv <= Finished;
		wait;
	end process;

	uut: entity work.i8080_alu(behavioural)
	port map (
		clk => clk,
		cs => cs,
		
		lhs => lhs, rhs => rhs,
		result => result,
		flags => flags
	);

end architecture;

