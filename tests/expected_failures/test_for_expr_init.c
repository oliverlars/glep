#include <stdio.h>
#include <assert.h>

// Tests for-loop with expression init (not declaration)
// The parser always calls parse_decl() for the init, so "for (i = 0; ...)"
// where i is already declared would fail

int main(int argc, char **args) {
	printf("=== test_for_expr_init ===\n");

	// for loop with pre-declared variable
	{
		int i;
		int sum = 0;
		for (i = 0; i < 5; ++i) {
			sum = sum + i;
		}
		assert(sum == 10);
		assert(i == 5);
		printf("  for with expr init: PASS\n");
	}

	printf("=== test_for_expr_init: ALL PASS ===\n");
	return 0;
}
