#include <stdio.h>

/* print Celsius-Fahrenheit table; floating-point version */

main() {
	float fahr, celsius;
	int lower, upper, step;

	lower = 0;
	upper = 300;
	step = 20;

	/* lower will be converted to float before assigning it to celsius */

	celsius = lower;

	printf("Celsius Fahr\n");
	while (celsius <= upper) {
		/* if an arithmetic operator has a floating-point operand and
		an integer operand, the integer will be converted to float
		before the operation is done. But we explicitly put 32.0 below
		for readability. */

		fahr = (celsius * (9.0/5.0)) + 32.0;

		printf("%4.0f %6.0f\n", celsius, fahr);
		celsius = celsius + step;
	}
}
