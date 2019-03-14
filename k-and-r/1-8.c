#include <stdio.h>

/* count characters in input */

main() {
	int c, newlines, tabs, blanks;

	newlines = 0;
	tabs = 0;
	blanks = 0;

	while ((c = getchar()) != EOF) {
		if (c == '\n')
			++newlines;
		if (c == '\t')
			++tabs;
		if (c == ' ')
			++blanks;
	}
	printf("%d newlines\n%d tabs\n%d spaces\n",newlines, tabs, blanks);
}
