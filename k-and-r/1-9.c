#include <stdio.h>

/* replace two or more spaces with a single space */

main() {
	int c, ns;

	while ((c = getchar()) != EOF) {
		if (c == ' ')
			++ns;
		if (c != ' ')
			ns = 0;
		if (ns <= 1)
			putchar(c);

	}
}
