#include <stdio.h>
#include <assert.h>

int main(int argc, char **args) {
	printf("=== test_preincrement ===\n");

	// Basic pre-increment
	{
		int a = 5;
		int b = ++a;
		assert(a == 6);
		assert(b == 6);
		printf("  basic pre-increment: PASS\n");
	}

	// Pre-increment in condition
	{
		int depth = 4;
		if (++depth > 5) {
			assert(0);
		}
		assert(depth == 5);
		if (++depth > 5) {
			assert(depth == 6);
		} else {
			assert(0);
		}
		printf("  pre-increment in condition: PASS\n");
	}

	// Pre-increment in for loop
	{
		int sum = 0;
		for (int i = 0; i < 5; ++i) {
			sum = sum + i;
		}
		assert(sum == 10);
		printf("  pre-increment in for: PASS\n");
	}

	// Pre-increment on pointer targets
	{
		int x = 10;
		int *p = &x;
		++(*p);
		assert(x == 11);
		printf("  pre-increment via pointer: PASS\n");
	}

	// Multiple pre-increments
	{
		int a = 0;
		++a;
		++a;
		++a;
		assert(a == 3);
		printf("  multiple pre-increments: PASS\n");
	}

	printf("=== test_preincrement: ALL PASS ===\n");
	return 0;
}
