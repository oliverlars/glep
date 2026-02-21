#include <stdio.h>
#include <assert.h>

int main(int argc, char **args) {
	printf("=== test_arithmetic ===\n");

	// Basic integer arithmetic
	{
		int a = 10;
		int b = 3;
		assert(a + b == 13);
		assert(a - b == 7);
		assert(a * b == 30);
		assert(a / b == 3);
		assert(a % b == 1);
		printf("  basic int ops: PASS\n");
	}

	// Negative numbers
	{
		int a = -5;
		int b = 3;
		assert(a + b == -2);
		assert(a * b == -15);
		assert(a - b == -8);
		printf("  negative int ops: PASS\n");
	}

	// Unsigned arithmetic
	{
		unsigned int a = 10;
		unsigned int b = 3;
		assert(a + b == 13);
		assert(a - b == 7);
		assert(a * b == 30);
		assert(a / b == 3);
		assert(a % b == 1);
		printf("  unsigned int ops: PASS\n");
	}

	// Double arithmetic
	{
		double a = 10.5;
		double b = 3.2;
		double sum = a + b;
		double diff = a - b;
		double prod = a * b;
		double quot = a / b;
		// Check within epsilon
		assert(sum > 13.69 && sum < 13.71);
		assert(diff > 7.29 && diff < 7.31);
		assert(prod > 33.59 && prod < 33.61);
		assert(quot > 3.28 && quot < 3.29);
		printf("  double ops: PASS\n");
	}

	// Float arithmetic
	{
		float a = 2.5f;
		float b = 1.5f;
		float sum = a + b;
		float prod = a * b;
		assert(sum > 3.99f && sum < 4.01f);
		assert(prod > 3.74f && prod < 3.76f);
		printf("  float ops: PASS\n");
	}

	// Mixed int/double (int promoted to double)
	{
		int a = 5;
		double b = 2.5;
		double result = a * b;
		assert(result > 12.49 && result < 12.51);
		printf("  mixed int/double: PASS\n");
	}

	// Integer division truncates toward zero
	{
		int a = 7;
		int b = 2;
		assert(a / b == 3);
		int c = -7;
		assert(c / b == -3);
		printf("  int division truncation: PASS\n");
	}

	// Shift operators
	{
		int a = 1;
		assert((a << 3) == 8);
		assert((8 >> 2) == 2);
		unsigned int b = 0x80000000;
		assert((b >> 1) == 0x40000000);
		printf("  shift ops: PASS\n");
	}

	// Bitwise AND
	{
		int a = 0xFF;
		int b = 0x0F;
		assert((a & b) == 0x0F);
		printf("  bitwise AND: PASS\n");
	}

	printf("=== test_arithmetic: ALL PASS ===\n");
	return 0;
}
