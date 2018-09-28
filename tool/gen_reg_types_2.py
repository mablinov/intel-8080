regs = ["db", "pc", "ir", "a", "flags", "b", "c", "d", "e", "h", "l"]

reg_record_member_decl = "\n\t\t{}: reg_{}_load_type;"

decl = """	type register_control_signals is record{}
	end record;"""


reg_decl_member_block = ""

for i in regs:
	reg_decl_member_block += reg_record_member_decl.format(i, i)

print(decl.format(reg_decl_member_block))

const_stmt = \
"""	constant REGISTER_CONTROL_SIGNALS_DEFAULT: register_control_signals := ({}
	);"""

const_assmnts = ""
for i in regs:
	const_assmnts += "\n\t\t{} => None,".format(i)

print(const_stmt.format(const_assmnts))

