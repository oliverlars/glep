#include <stdio.h>
#include <assert.h>
#include <math.h>

#define EPSILON 0.001
#define assert_eq(a, b) assert(fabs((a) - (b)) < EPSILON)

int main(int argc, char **args) {
	printf("=== test_casts ===\n");

	// Int to double cast
	{
		int a = 42;
		double b = (double)a;
		assert_eq(b, 42.0);
		printf("  int to double: PASS\n");
	}

	// Double to int cast (truncation)
	{
		double a = 3.99;
		int b = (int)a;
		assert(b == 3);
		printf("  double to int: PASS\n");
	}

	// Float to int
	{
		float a = 7.9f;
		int b = (int)a;
		assert(b == 7);
		printf("  float to int: PASS\n");
	}

	// Int to float
	{
		int a = 100;
		float b = (float)a;
		assert(b > 99.9f && b < 100.1f);
		printf("  int to float: PASS\n");
	}

	// Unsigned to signed
	{
		unsigned int a = 42;
		int b = (int)a;
		assert(b == 42);
		printf("  unsigned to signed: PASS\n");
	}

	// Signed to unsigned
	{
		int a = 42;
		unsigned int b = (unsigned int)a;
		assert(b == 42);
		printf("  signed to unsigned: PASS\n");
	}

	// Char to int
	{
		char c = 'A';
		int i = (int)c;
		assert(i == 65);
		printf("  char to int: PASS\n");
	}

	// Int to char
	{
		int i = 66;
		char c = (char)i;
		assert(c == 'B');
		printf("  int to char: PASS\n");
	}

	// Implicit int-to-double in expression
	{
		int a = 5;
		double b = 2.0;
		double c = a / b;
		assert_eq(c, 2.5);
		printf("  implicit promotion: PASS\n");
	}

	// Cast in complex expression
	{
		int a = 7;
		int b = 2;
		double c = (double)a / (double)b;
		assert_eq(c, 3.5);
		printf("  cast in expression: PASS\n");
	}

	printf("=== test_casts: ALL PASS ===\n");
	return 0;
}
