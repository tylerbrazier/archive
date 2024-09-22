# This sums and prints the categories from backup/docs/ledger
BEGIN { FS="\t"; scope="2023-06"}
$1 ~ "^"scope {
	# To calculate multiple categories per entry you can do something like:
        # split($3, entry_categories, /,/)
        # for (c in entry_categories) categories[entry_categories[c]] += $1
	categories[$3] += $2
	total += $2
}
END {
	format = "%-8s %+.2f\n"
	printf "Results for %s:\n", scope
	for (c in categories)
		printf format, c, categories[c]
	printf format, "Total:", total
}
