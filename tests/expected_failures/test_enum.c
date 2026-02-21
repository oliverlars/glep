#include <stdio.h>
#include <assert.h>

// Tests enum values and usage
// Enums are parsed but eval_constant_expr asserts false on Node_Identifier,
// so enum constants can't be used as array sizes or in constant expressions

enum Color {
	RED,
	GREEN,
	BLUE,
	NUM_COLORS
};

enum Explicit {
	A = 10,
	B = 20,
	C = 30
};

int main(int argc, char **args) {
	printf("=== test_enum ===\n");

	// Basic enum values
	{
		enum Color c = RED;
		assert(c == 0);
		c = GREEN;
		assert(c == 1);
		c = BLUE;
		assert(c == 2);
		printf("  basic enum values: PASS\n");
	}

	// Enum count pattern
	{
		assert(NUM_COLORS == 3);
		printf("  enum count: PASS\n");
	}

	// Explicit enum values
	{
		assert(A == 10);
		assert(B == 20);
		assert(C == 30);
		printf("  explicit enum values: PASS\n");
	}

	// Enum as array size
	{
		int counts[NUM_COLORS];
		counts[RED] = 1;
		counts[GREEN] = 2;
		counts[BLUE] = 3;
		assert(counts[0] == 1);
		assert(counts[1] == 2);
		assert(counts[2] == 3);
		printf("  enum array size: PASS\n");
	}

	printf("=== test_enum: ALL PASS ===\n");
	return 0;
}
