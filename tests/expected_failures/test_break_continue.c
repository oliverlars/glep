#include <stdio.h>
#include <assert.h>

// Tests break and continue statements
// Parsed but no codegen (compile_statement has no case for Node_Break or Node_Continue)

int main(int argc, char **args) {
	printf("=== test_break_continue ===\n");

	// break in while
	{
		int i = 0;
		while (i < 100) {
			if (i == 5) break;
			i = i + 1;
		}
		assert(i == 5);
		printf("  break in while: PASS\n");
	}

	// break in for
	{
		int last = -1;
		for (int i = 0; i < 100; ++i) {
			if (i == 7) break;
			last = i;
		}
		assert(last == 6);
		printf("  break in for: PASS\n");
	}

	// continue in for
	{
		int sum = 0;
		for (int i = 0; i < 10; ++i) {
			if (i % 2 == 0) continue;
			sum = sum + i;
		}
		assert(sum == 25);
		printf("  continue in for: PASS\n");
	}

	// continue in while
	{
		int sum = 0;
		int i = 0;
		while (i < 10) {
			i = i + 1;
			if (i % 2 == 0) continue;
			sum = sum + i;
		}
		assert(sum == 25);
		printf("  continue in while: PASS\n");
	}

	printf("=== test_break_continue: ALL PASS ===\n");
	return 0;
}
