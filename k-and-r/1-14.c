#include <stdio.h>

#define RANGE  '~' - ' '  /* range of visible chars */
#define OFFSET '!'        /* 0th index in array is the ! character */

/* prints histogram of frequencies of characters in input */

main() {
	int c, i, j;
	int lengths[RANGE];

	for (i = 0; i < RANGE; ++i)
		lengths[i] = 0;

	while ((c = getchar()) != EOF) {
		if (c >= '!' && c <= '~')
			++lengths[c - OFFSET];
	}

	for (i = 0; i < RANGE; ++i) {
		printf("%c | ", OFFSET + i);
		for (j = 0; j < lengths[i]; ++j)
			printf("-");
		printf("\n");
	}
}
