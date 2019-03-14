#include <stdio.h>

/* prints histogram of words in input, horizontally and vertically */

main() {
	int c, ccount, i, j, greatest;
	int lengths[10];  /* 0th index is for words with 10+ characters */

	ccount = 0;
	for (i = 0; i < 10; ++i)
		lengths[i] = 0;

	while ((c = getchar()) != EOF) {
		if (c == ' ' || c == '\n' || c == '\t') {
			if (ccount >= 10)
				++lengths[0];
			else if (ccount > 0)
				++lengths[ccount];
			ccount = 0;
		} else {
			++ccount;
		}
	}

	/* print horizontally */

	/* first for 1 - 9 */
	for (i = 1; i < 10; ++i) {
		printf("%d   | ", i);
		for (j = 0; j < lengths[i]; ++j)
			printf("-");
		printf("\n");
	}

	/* for 10+ */
	printf("10+ | ");
	for (j = 0; j < lengths[0]; ++j)
		printf("-");


	printf("\n\n------------------------------------------------------------\n\n");


	/* print vertically */

	/* determine the height of the graph by finding the greatest count */
	greatest = 0;
	for (i = 0; i < 10; ++i)
		if (lengths[i] > greatest)
			greatest = lengths[i];

	for (i = greatest; i > 0; --i) {    /* for each row, starting at the top */
		for (j = 1; j < 10; ++j) {  /* for each column besides 10+ */
			if (lengths[j] >= i)
				printf("| ");
			else
				printf("  ");
		}

		if (lengths[0] >= i)
			printf(" | ");
		else
			printf("   ");

		printf("\n");
	}

	/* print the bottom of the graph */
	printf("---------------------\n");
	for (i = 1; i < 10; ++i)
		printf("%d ", i);
	printf("10+\n");
}
