BEGIN { FS="\t" }

$1 ~ "^"scope {
	# scope is yyyy-mm so this is a ledger record
	#
	# To calculate multiple categories per entry you can do something like:
        # split($3, entry_categories, /,/)
        # for (c in entry_categories)
	# 	ledger_categories[entry_categories[c]] += $1
	ledger_categories[$3] += $2
	ledger_total += $2
}

$1 ~ /^[+-]?[0-9]+(\.[0-9]+)?$/ {
	# budget record
	budget_categories[$2] += $1
	budget_total += $1
}

END {
	header_format = "%-8s %-8s %-8s %s\n"
	data_format = "%-8s %-8+.2f %-8+.2f %-8+.2f\n"
	printf header_format, \
	       "Category", \
	       "Budgeted", \
	       "Actual", \
	       "Difference"
	for (c in budget_categories) {
		budgeted = budget_categories[c]
		actual = ledger_categories[c]
		diff = actual - budgeted
		printf data_format, \
		       c, \
		       budgeted, \
		       actual, \
		       diff
	}

	# also check for categories in ledger that aren't in budget
	for (c in ledger_categories)
		if (!budget_categories[c])
			unbudgeted[c] += ledger_categories[c]
	for (c in unbudgeted)
		printf data_format, \
			c, \
			0, \
			unbudgeted[c], \
			unbudgeted[c]

	printf data_format, \
	       "Total:", \
	       budget_total, \
	       ledger_total, \
	       ledger_total-budget_total
}
