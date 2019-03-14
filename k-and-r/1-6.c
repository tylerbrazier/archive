#include <stdio.h>

/* Verifies the expression `getchar() != EOF` is always 0 or 1 */

main() {
	printf("type anything or ctrl-d to send EOF\n");
	printf("getchar() != EOF: %d\n", (getchar() != EOF));
}
