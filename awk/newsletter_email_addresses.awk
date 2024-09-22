# Prints the email address of each contact in Contacts.vcf that includes
# 'Newsletter' in the NOTE property.
{
	# \n\r at the end of each line causes many problems
	sub(/\r/, "")
}
BEGIN { FS = ":"; email_len = 0; no_email_len = 0; }
/^BEGIN:VCARD/ { send = 0; name = ""; email = ""; }
/^NOTE:.*Newsletter/ { send = 1 }
/^FN:/ { name = $2 }
/^EMAIL/ {
	if (email) email = email "\n" $2
	else email = $2
}
/^END:VCARD/ && send && !email { no_email[no_email_len++] = name }
/^END:VCARD/ && send && email { print email; email_len++ }
END {
	if (no_email_len) {
		print "\nNo email addresses for:"
		for (i in no_email) print no_email[i]
	}
	printf "\n%d total people ", (email_len+no_email_len)
	printf "(%d with email, %d without)\n", email_len, no_email_len
}
