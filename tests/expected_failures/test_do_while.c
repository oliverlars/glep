#include <stdio.h>
#include <assert.h>

// Tests do...while loops
// Parsed but not codegen'd (compile_statement has no case for Node_Do)

int main(int argc, char **args) {
	printf("=== test_do_while ===\n");

	// Basic do-while
	{
		int i = 0;
		int sum = 0;
		do {
			sum = sum + i;
			i = i + 1;
		} while (i < 5);
		assert(sum == 10);
		assert(i == 5);
		printf("  basic do-while: PASS\n");
	}

	// do-while runs at least once
	{
		int ran = 0;
		do {
			ran = 1;
		} while (0);
		assert(ran == 1);
		printf("  do-while runs once: PASS\n");
	}

	printf("=== test_do_while: ALL PASS ===\n");
	return 0;
}
