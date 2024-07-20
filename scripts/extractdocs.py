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


def extractDocsFromFolder(folder):
	files = obtainfiles([folder])
	for file in files:
		f2 = folder + "/" + file
		print("Extracting documentation from " + f2)
		extractdocs(f2)

def main():
	extractDocsFromFolder(sys.argv[1])

if __name__ == "__main__":
	main()
