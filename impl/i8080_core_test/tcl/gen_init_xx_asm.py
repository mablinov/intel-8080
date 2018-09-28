cmdstr = (
"set_property INIT_{} {} [get_cells ramb_inst/ramb64x1_inst_{}/"
"RAMB36E1_lower]"
)

hexsrc = (
":100000000125001126003E00C601D303DA1200C309\n"
":1000100008000AC60102DA1C00C306001AC6011253\n"
":07002000D302C3060000003B\n"
":00000001FF"
)
":100000000125001126003E00C601D303DA1200C309\n"
":1000100008000AC60102DA1C00C306001AC6011253\n"
":07002000D302C3060000003B\n"
":00000001FF"

entries = hexsrc.split();

hexvec = []

for i in entries:
	count = int(i[1:3], 16)
#	print(count)
	for j in range(count):
		hexvec.append(int(i[9+(2*j):11+(2*j)], 16))

print([hex(i) for i in hexvec])



for i in hexvec:
	print("\tX\"{}\",".format(hex(i)))

binvec = []

for i in hexvec:
	binvec.append("{:08b}".format(i));

# Generate individual vectors
v0 = []
v1 = []
v2 = []
v3 = []
v4 = []
v5 = []
v6 = []
v7 = []

for i in reversed(binvec):
	v7.append(i[0])
	v6.append(i[1])
	v5.append(i[2])
	v4.append(i[3])
	v3.append(i[4])
	v2.append(i[5])
	v1.append(i[6])
	v0.append(i[7])


print(v0)
print(v1)
print(v2)
print(v3)
print(v4)
print(v5)
print(v6)
print(v7)

ramb0 = hex(int("".join(v0), 2))
ramb1 = hex(int("".join(v1), 2))
ramb2 = hex(int("".join(v2), 2))
ramb3 = hex(int("".join(v3), 2))
ramb4 = hex(int("".join(v4), 2))
ramb5 = hex(int("".join(v5), 2))
ramb6 = hex(int("".join(v6), 2))
ramb7 = hex(int("".join(v7), 2))

print("ramb1 = " + ramb1)

cmdfile = ""
j = 0
for i in [ramb0, ramb1, ramb2, ramb3, ramb4, ramb5, ramb6, ramb7]:
	cmdfile += cmdstr.format("00", i, j) + "\n"
	j += 1

print(cmdfile)

