#include <stdio.h>
#include <assert.h>

// Tests -- operator (pre-decrement and post-decrement)
// Only PlusPlus is handled in unary compile case, MinusMinus is missing

int main(int argc, char **args) {
	printf("=== test_decrement ===\n");

	// Pre-decrement
	{
		int a = 5;
		int b = --a;
		assert(a == 4);
		assert(b == 4);
		printf("  pre-decrement: PASS\n");
	}

	// Pre-decrement in loop
	{
		int i = 10;
		int count = 0;
		while (i > 0) {
			--i;
			count = count + 1;
		}
		assert(count == 10);
		assert(i == 0);
		printf("  pre-decrement loop: PASS\n");
	}

	// Post-decrement
	{
		int a = 5;
		int b = a--;
		assert(b == 5);
		assert(a == 4);
		printf("  post-decrement: PASS\n");
	}

	printf("=== test_decrement: ALL PASS ===\n");
	return 0;
}
