#include <stdio.h>
#include <assert.h>

int main(int argc, char **args) {
	printf("=== test_comparison ===\n");

	// Integer comparisons
	{
		int a = 5;
		int b = 10;
		assert(a < b);
		assert(b > a);
		assert(a <= b);
		assert(b >= a);
		assert(a != b);
		assert(a == 5);
		assert(a <= 5);
		assert(a >= 5);
		printf("  int comparisons: PASS\n");
	}

	// Negative integer comparisons
	{
		int a = -5;
		int b = 5;
		assert(a < b);
		assert(b > a);
		assert(a < 0);
		assert(b > 0);
		printf("  negative int comparisons: PASS\n");
	}

	// Unsigned comparisons
	{
		unsigned int a = 5;
		unsigned int b = 10;
		assert(a < b);
		assert(b > a);
		printf("  unsigned comparisons: PASS\n");
	}

	// Double comparisons
	{
		double a = 1.5;
		double b = 2.5;
		assert(a < b);
		assert(b > a);
		assert(a <= b);
		assert(b >= a);
		assert(a != b);
		assert(a == 1.5);
		printf("  double comparisons: PASS\n");
	}

	// Float comparisons
	{
		float a = 1.5f;
		float b = 2.5f;
		assert(a < b);
		assert(b > a);
		assert(a != b);
		printf("  float comparisons: PASS\n");
	}

	// Logical AND (short-circuit)
	{
		int a = 1;
		int b = 0;
		assert(a && !b);
		assert(!(a && b));
		assert(!(b && a));
		printf("  logical AND: PASS\n");
	}

	// NOT operator
	{
		int a = 0;
		int b = 5;
		assert(!a);
		assert(!(!b));
		printf("  logical NOT: PASS\n");
	}

	printf("=== test_comparison: ALL PASS ===\n");
	return 0;
}
