#!/bin/sh

# Wrapper for generate_todo.awk since the command is fairly complicated.
# The comment at the top of awk script explains what it does.

if [ $# -eq 0 ]; then
	echo 'You probably want to give an argument to cal.' >&2
	exit 1
fi

cd "$(dirname "$0")"
cal -v "$@" | awk -f generate_todo.awk \
	FS=":" ../docs/Contacts.vcf \
	FS=" " - \
	| tee -a ../docs/notes
