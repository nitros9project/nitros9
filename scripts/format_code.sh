#!/bin/zsh
# This is a shell script that formats all assembly files in the project for
# consistent indentation.
listit() {
	while [ "$1" ]; do
		if [ -d "$1" ]; then
			listit "$1"/*
		elif [ "$1:t:e" = "asm" ]; then
			printf '%s\n' "$1"
		elif [ "$1:t:e" = "as" ]; then
			printf '%s\n' "$1"
		elif [ "$1:t:e" = "d" ]; then
			printf '%s\n' "$1"
		fi
		shift
	done
}

echo "#!/bin/sh -x"
listit $1 | awk {'print("python3 asmprettyprint.py " $0 " > /tmp/format.out; mv /tmp/format.out " $0)'}