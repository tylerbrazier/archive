#include <stdio.h>

/* replace tabs, backspaces, and backslashes with \t, \b, and \\ */

main() {
	int c;

	while ((c = getchar()) != EOF) {
		if (c == '\t') {
			putchar('\\');
			c = 't';
		}
		if (c == '\b') {
			putchar('\\');
			c = 'b';
		}
		if (c == '\\') {
			putchar('\\');
			c = '\\';
		}
		putchar(c);

	}
}
