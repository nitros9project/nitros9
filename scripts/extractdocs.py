import sys

def sanitize(name):
	newname = name.lstrip(' ').rstrip('\n')
	return newname + ".hp"

file = sys.argv[1]
with open(file) as fp:
	for line in fp:
		if line[0:3] == ";;;":
			fname = sanitize(line[4:])
			f2 = open(fname, 'w')
			while line[0:3] == ";;;":
				newline = line[4:]
				if newline == "":
					newline = "\n"
				f2.write(newline)
				line = fp.readline()
			f2.close()


