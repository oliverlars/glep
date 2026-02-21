#include <stdio.h>
#include <assert.h>

int g_int = 42;
double g_double = 3.14;
int g_arr[3] = {10, 20, 30};
int g_zero = 0;

void modify_global(int val) {
	g_int = val;
}

int read_global() {
	return g_int;
}

int main(int argc, char **args) {
	printf("=== test_globals ===\n");

	// Read global int
	{
		assert(g_int == 42);
		printf("  global int read: PASS\n");
	}

	// Read global double
	{
		assert(g_double > 3.13 && g_double < 3.15);
		printf("  global double read: PASS\n");
	}

	// Read global array
	{
		assert(g_arr[0] == 10);
		assert(g_arr[1] == 20);
		assert(g_arr[2] == 30);
		printf("  global array read: PASS\n");
	}

	// Modify global through function
	{
		modify_global(99);
		assert(g_int == 99);
		assert(read_global() == 99);
		printf("  global modify via function: PASS\n");
	}

	// Zero-initialized global
	{
		assert(g_zero == 0);
		printf("  zero-init global: PASS\n");
	}

	printf("=== test_globals: ALL PASS ===\n");
	return 0;
}
