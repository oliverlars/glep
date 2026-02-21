#include <stdio.h>
#include <assert.h>

int main(int argc, char **args) {
	printf("=== test_control_flow ===\n");

	// Basic if/else
	{
		int x = 10;
		int result = 0;
		if (x > 5) {
			result = 1;
		} else {
			result = 2;
		}
		assert(result == 1);

		x = 3;
		if (x > 5) {
			result = 1;
		} else {
			result = 2;
		}
		assert(result == 2);
		printf("  if/else: PASS\n");
	}

	// else-if chain
	{
		int x = 15;
		int result = 0;
		if (x < 10) {
			result = 1;
		} else if (x < 20) {
			result = 2;
		} else {
			result = 3;
		}
		assert(result == 2);
		printf("  else-if chain: PASS\n");
	}

	// while loop
	{
		int sum = 0;
		int i = 0;
		while (i < 10) {
			sum = sum + i;
			i = i + 1;
		}
		assert(sum == 45);
		assert(i == 10);
		printf("  while loop: PASS\n");
	}

	// for loop
	{
		int sum = 0;
		for (int i = 0; i < 10; ++i) {
			sum = sum + i;
		}
		assert(sum == 45);
		printf("  for loop: PASS\n");
	}

	// Nested loops
	{
		int count = 0;
		for (int i = 0; i < 5; ++i) {
			for (int j = 0; j < 3; ++j) {
				count = count + 1;
			}
		}
		assert(count == 15);
		printf("  nested loops: PASS\n");
	}

	// Nested if inside loop
	{
		int even_count = 0;
		int odd_count = 0;
		for (int i = 0; i < 10; ++i) {
			if (i % 2 == 0) {
				even_count = even_count + 1;
			} else {
				odd_count = odd_count + 1;
			}
		}
		assert(even_count == 5);
		assert(odd_count == 5);
		printf("  if inside loop: PASS\n");
	}

	// Loop with early return pattern (via flag)
	{
		int found = 0;
		int target = 7;
		int i = 0;
		while (i < 20 && !found) {
			if (i == target) {
				found = 1;
			}
			i = i + 1;
		}
		assert(found);
		assert(i == 8);
		printf("  loop with condition flag: PASS\n");
	}

	printf("=== test_control_flow: ALL PASS ===\n");
	return 0;
}
