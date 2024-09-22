#!/bin/bash
# Compares a month's spending with budget.
# TODO:
# - color output?
# - allow calculating for the whole year

if [[ ! $1 =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
	echo "Usage: $0 yyyy-mm" >&2
	exit 1
fi

cd "$(dirname "$0")" || exit
awk -v scope="$1" \
	-f calculate_spending.awk \
	../docs/budget \
	../docs/ledger
