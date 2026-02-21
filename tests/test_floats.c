#include <stdio.h>
#include <assert.h>
#include <math.h>

#define EPSILON 0.0001
#define assert_eq(a, b) assert(fabs((a) - (b)) < EPSILON)

int main(int argc, char **args) {
	printf("=== test_floats ===\n");

	// Float literals
	{
		float a = 1.5f;
		double b = 1.5;
		assert_eq(a, 1.5);
		assert_eq(b, 1.5);
		printf("  float literals: PASS\n");
	}

	// Float to double promotion
	{
		float a = 2.5f;
		double b = a;
		assert_eq(b, 2.5);
		printf("  float to double: PASS\n");
	}

	// Double to float truncation
	{
		double a = 3.14159265358979;
		float b = (float)a;
		assert(fabs(b - 3.14159f) < 0.001f);
		printf("  double to float: PASS\n");
	}

	// Int to double conversion
	{
		int a = 42;
		double b = (double)a;
		assert_eq(b, 42.0);
		printf("  int to double: PASS\n");
	}

	// Double to int truncation
	{
		double a = 3.7;
		int b = (int)a;
		assert(b == 3);
		double c = -3.7;
		int d = (int)c;
		assert(d == -3);
		printf("  double to int: PASS\n");
	}

	// Math functions
	{
		assert_eq(sqrt(4.0), 2.0);
		assert_eq(sqrt(9.0), 3.0);
		assert_eq(fabs(-5.0), 5.0);
		assert_eq(fabs(5.0), 5.0);
		printf("  sqrt/fabs: PASS\n");
	}

	// Trig functions
	{
		double pi = 3.14159265358979;
		assert_eq(sin(0.0), 0.0);
		assert_eq(cos(0.0), 1.0);
		assert(fabs(sin(pi)) < 0.0001);
		assert(fabs(cos(pi) - (-1.0)) < 0.0001);
		printf("  sin/cos: PASS\n");
	}

	// pow function
	{
		assert_eq(pow(2.0, 10.0), 1024.0);
		assert_eq(pow(3.0, 2.0), 9.0);
		printf("  pow: PASS\n");
	}

	// Negative float operations
	{
		double a = -2.5;
		double b = -3.5;
		assert_eq(a + b, -6.0);
		assert_eq(a * b, 8.75);
		assert_eq(a - b, 1.0);
		printf("  negative float ops: PASS\n");
	}

	// 1/x where x is double (int-to-double division)
	{
		double x = 4.0;
		double r = 1 / x;
		assert_eq(r, 0.25);
		printf("  int/double division: PASS\n");
	}

	// Float comparison edge cases
	{
		double a = 0.0;
		double b = -0.0;
		assert(a == b);
		printf("  zero comparison: PASS\n");
	}

	printf("=== test_floats: ALL PASS ===\n");
	return 0;
}
