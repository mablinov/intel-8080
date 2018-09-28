
reg_template = \
"""	type reg_{}_load_type is (None, Databus);
	type reg_{}_control_signals is record
		load: reg_{}_load_type;
	end record;
	constant REG_{}_CONTROL_SIGNALS_DEFAULT: reg_{}_control_signals := (
		load => '0'
	);"""

print("\t-- Register types")
for i in ["a", "flags", "b", "c", "d", "e", "h", "l"]:
	print(reg_template.format(i, i, i, i.upper(), i))
	print("")

regs_template = \
"""	type register_control_signals is record
{}
	end record;
	constant REGISTER_CONTROL_SIGNALS_DEFAULT: register_control_signals := (
{}
	);"""

reg_decls = ""
reg_const_assmnts = ""
for i in ["a", "flags", "b", "c", "d", "e", "h", "l"]:
	reg_decls += "\t\t{}: reg_{}_control_signals;\n".format(i, i);

for i in ["a", "flags", "b", "c", "d", "e", "h", "l"]:
	reg_const_assmnts += "\t\t{} => REG_{}_CONTROL_SIGNALS_DEFAULT,\n".format(i, i.upper());

print(regs_template.format(reg_decls, reg_const_assmnts));

