#include <stdio.h>
#include <assert.h>

int main(int argc, char **args) {
	printf("=== test_ternary ===\n");

	// Basic ternary
	{
		int a = 5;
		int b = (a > 3) ? 10 : 20;
		assert(b == 10);
		int c = (a > 10) ? 10 : 20;
		assert(c == 20);
		printf("  basic ternary: PASS\n");
	}

	// Ternary with doubles
	{
		double x = 1.5;
		double y = (x > 1.0) ? 2.0 : 0.0;
		assert(y > 1.9 && y < 2.1);
		printf("  double ternary: PASS\n");
	}

	// Nested ternary
	{
		int a = 5;
		int r = (a < 3) ? 1 : (a < 7) ? 2 : 3;
		assert(r == 2);
		printf("  nested ternary: PASS\n");
	}

	// Ternary as function arg
	{
		int a = 10;
		printf("  value: %d\n", (a > 5) ? 1 : 0);
		printf("  ternary as arg: PASS\n");
	}

	printf("=== test_ternary: ALL PASS ===\n");
	return 0;
}
