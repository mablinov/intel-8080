cmdstr = (
"set_property INIT_{} {} [get_cells */ramb64x8_inst/ramb64x1_inst_{}/"
"RAMB36E1_lower]"
)

hexsrc = (
":1000000031FFFFCD4300011800110080CD300011F9\n"
":100010005080CD3000C31500546869732069732087\n"
":10002000612074657374206D6573736167652E005C\n"
":10003000F5C5D50AFE00CA3F00120313C33300D131\n"
":10004000C1F1C9F5C50100803E20020379FEC0C29E\n"
":0B005000480078FE92C24800C1F1C9D0\n"
":00000001FF"
)

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

