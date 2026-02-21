#include <stdio.h>
#include <assert.h>

int main(int argc, char **args) {
	printf("=== test_pointers ===\n");

	// Basic pointer dereference
	{
		int x = 42;
		int *p = &x;
		assert(*p == 42);
		printf("  basic deref: PASS\n");
	}

	// Write through pointer
	{
		int x = 10;
		int *p = &x;
		*p = 20;
		assert(x == 20);
		printf("  write through pointer: PASS\n");
	}

	// Pointer to pointer
	{
		int x = 99;
		int *p = &x;
		int **pp = &p;
		assert(**pp == 99);
		printf("  pointer to pointer: PASS\n");
	}

	// Pointer arithmetic with arrays
	{
		int arr[5] = {10, 20, 30, 40, 50};
		int *p = &arr[0];
		assert(*p == 10);
		assert(*(p + 1) == 20);
		assert(*(p + 4) == 50);
		printf("  pointer arithmetic: PASS\n");
	}

	// Passing pointer to function (via helper)
	{
		int a = 5;
		int b = 10;
		int *pa = &a;
		int *pb = &b;
		// Swap via pointers
		int tmp = *pa;
		*pa = *pb;
		*pb = tmp;
		assert(a == 10);
		assert(b == 5);
		printf("  swap via pointers: PASS\n");
	}

	// Null pointer check
	{
		int *p = 0;
		assert(p == 0);
		assert(!p);
		int x = 5;
		p = &x;
		assert(p != 0);
		printf("  null pointer check: PASS\n");
	}

	printf("=== test_pointers: ALL PASS ===\n");
	return 0;
}
