#include <stdio.h>
#include <assert.h>

// Tests void functions with bare return statements
// compile_statement for Node_Return does assert(t != null) on the return expr type,
// which will crash when a void function does "return;"

int g_value = 0;

void set_value(int x) {
	g_value = x;
	return;
}

void conditional_set(int x) {
	if (x < 0) {
		return;
	}
	g_value = x;
}

int main(int argc, char **args) {
	printf("=== test_void_return ===\n");

	set_value(42);
	assert(g_value == 42);
	printf("  void return: PASS\n");

	conditional_set(-1);
	assert(g_value == 42);
	printf("  early void return: PASS\n");

	conditional_set(99);
	assert(g_value == 99);
	printf("  conditional void return: PASS\n");

	printf("=== test_void_return: ALL PASS ===\n");
	return 0;
}
