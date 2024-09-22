#!/bin/sh

# Wrapper for the awk script to make it easier to run

cd "$(dirname "$0")"
awk -f newsletter_email_addresses.awk \
	../docs/Contacts.vcf
