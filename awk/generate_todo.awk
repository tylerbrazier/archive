# Use this to generate a to-do list outline for the month in a format like:
#   December 2023
#   01 Fr
#   02 Sa
#   ...
#   25 Mo Jesus's birthday
#   26 Tu Toupin's birthday
#   ...
# Birthday info is read from a vcf file (export of phone contacts).
# My current phone exports contacts in vcard version 2.1; this script
# may need to be updated if that changes.
#
# This script needs to be used like:
#   cal -v [month [year]] | awk -f script.awk FS=" " - FS=":" .../Contacts.vcf
# (FS can't be set in this script since it needs to already be set when awk
# starts processing the file.)
# Since that command line is fairly complicated, and the output is intended
# to be appended to my notes file also, it should be run from a separate shell
# script that includes that line and resolved paths to files.

BEGIN {
	### Variables:
	cal_month_name   # name of the month according to cal
	cal_month_num    # number of the month according to cal
	cal_year         # year according to cal
	last_day         # the last day of the month (e.g. 31)
	days_in_month[0] # e.g. [1:"Fr", 2:"Sa", 3:"Su", ...]
	birthdays[0,0]   # 2-dimensional e.g. [12,25:"Jesus", ...]
	errors[0]        # array of error messages
	### Temp variables used when going thru a vcard:
	fn       # name of the contact
	err      # 1 if there was a problem parsing, 0 otherwise
	bd_month # month number of a contact's birthday
	bd_day   # day number of a contact's birthday
	### Counter variables
	i # used in for loops
	e # error counter
	### Map of month name to number:
	months["January"] = 1
	months["February"] = 2
	months["March"] = 3
	months["April"] = 4
	months["May"] = 5
	months["June"] = 6
	months["July"] = 7
	months["August"] = 8
	months["September"] = 9
	months["October"] = 10
	months["November"] = 11
	months["December"] = 12
}

# \r at the end of each line in vcf causes problems with printf
{ sub(/\r$/, "") }

# the first line of the cal command is like 'January 2023'
FILENAME == "-" && FNR == 1 {
	cal_month_name = $1
	cal_month_num = months[$1]
	cal_year = $2
}

# for every other line from cal
FILENAME == "-" && FNR > 1 {
	for (i=2; i<=NF; i++) {
		days_in_month[$i] = $1
		if ($i > last_day) last_day = $i
	}
}

# reset temp variables at the beginning of each contact
/^BEGIN:VCARD/ { fn = ""; err = 0; bd_month = 0; bd_day = 0 }
# set the contact's name
/^FN:/ { fn = $2 }
# when the contact has a birthday (e.g. 1989-12-25 or --12-25)
/^BDAY:/ {
	match($2, /[0-9]{2}-[0-9]{2}$/)
	# RSTART will be 0 if no match was found
	if (RSTART == 0) { err = 1; next }
	bd_month = int(substr($2, RSTART, 2))
	bd_day = int(substr($2, RSTART+3, 2))
	if (bd_month > 12 || bd_day > 31) err = 1
}
# if there was an error parsing birthday
/^END:VCARD/ && err {
	errors[e++] = sprintf("Bad BDAY value for %s.", fn)
}
# when we get to the end of a contact with a birthday
/^END:VCARD/ && bd_month && bd_day {
	birthdays[bd_month, bd_day] = sprintf("%s %s's birthday;", \
		 birthdays[bd_month, bd_day], fn)
}

# finally generate the output
END {
	printf "%s %d\n", cal_month_name, cal_year
	for (i=1; i<=last_day; i++) {
		printf "%02d %s", i, days_in_month[i]
		if (birthdays[cal_month_num, i])
			printf "%s", birthdays[cal_month_num, i]
		printf "\n"
	}

	if (e > 0) for (i=0; i<e; i++) print errors[i]
}
