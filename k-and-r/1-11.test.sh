#!/bin/bash

# input/output tests for 1-11.c

cc 1-11.c

input='one two\n'
echo "input: $input"
printf 'expect 1 2 8\n'
printf 'actual '
printf "$input" | ./a.out

echo

input=''
echo "input: (empty string)"
printf 'expect 0 0 0\n'
printf 'actual '
printf "$input" | ./a.out

echo

input='\n\n'
echo "input: $input"
printf 'expect 2 0 2\n'
printf 'actual '
printf "$input" | ./a.out

echo

echo '(characters outside of the ascii range inflate the character count)'
input='† word'
echo "input: $input"
printf 'expect 0 2 6\n'
printf 'actual '
printf "$input" | ./a.out
