# This sums and prints the categories from backup/docs/budget
BEGIN { FS="\t" }
$1 ~ /^[+-]?[0-9]+(\.[0-9]+)?$/ {
	# To calculate multiple categories per entry you can do something like:
	# split($2, entry_categories, /,/)
	# for (c in entry_categories) categories[entry_categories[c]] += $1
	categories[$2] += $1
	total += $1
}
END {
	header_format = "%-12s %-8s  %-8s\n"
	category_format = "%-12s %-8+.2f  %-8+.2f\n"
	printf header_format, "Category", "Monthly", "Annually"
	for (c in categories)
		printf category_format, c, categories[c], categories[c]*12
	printf category_format, "Total:", total, total*12
}
