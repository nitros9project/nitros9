import sys
import os
import re

def sanitize(name):
	newname = name.lstrip(' ').rstrip('\n')
	return newname + ".hp"

def extractdocs(file):
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


def obtainfiles(sourcefolder):
	results = []

	for folder in sourcefolder:
		for f in os.listdir(folder):
			if re.search('.asm', f):
				results += [f]
	return results	


files = obtainfiles(["../level1/cmds"])
for f in files:
	f2 = "../level1/cmds/" + f
	extractdocs(f2)
