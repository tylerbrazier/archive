#include <stdio.h>

/* print Fahrenheit-Celsius table; floating-point version */

main() {
	float fahr, celsius;
	int lower, upper, step;

	lower = 0;
	upper = 300;
	step = 20;

	/* lower will be converted to float before assigning it to fahr */

	fahr = lower;

	printf("Fahr Celsius\n");
	while (fahr <= upper) {
		/* if an arithmetic operator has a floating-point operand and
		an integer operand, the integer will be converted to float
		before the operation is done. But we explicitly put fahr-32.0
		below for readability. */

		celsius = (5.0/9.0) * (fahr-32.0);

		/* print fahr at least 3 characters wide and no characters
		after the decimal point. Print celsius at least 6 wide with
		two characters after the decimal point. */

		printf("%3.0f %6.1f\n", fahr, celsius);
		fahr = fahr + step;
	}
}
