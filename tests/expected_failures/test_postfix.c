#include <stdio.h>
#include <assert.h>

// Tests postfix increment and decrement (i++, i--)
// The parser may handle these but codegen may not distinguish post from pre

int main(int argc, char **args) {
	printf("=== test_postfix ===\n");

	// Postfix increment: returns old value
	{
		int a = 5;
		int b = a++;
		assert(b == 5);
		assert(a == 6);
		printf("  postfix increment: PASS\n");
	}

	// Postfix in array index
	{
		int arr[5] = {10, 20, 30, 40, 50};
		int i = 0;
		int v0 = arr[i++];
		int v1 = arr[i++];
		assert(v0 == 10);
		assert(v1 == 20);
		assert(i == 2);
		printf("  postfix in array index: PASS\n");
	}

	// Postfix decrement
	{
		int a = 5;
		int b = a--;
		assert(b == 5);
		assert(a == 4);
		printf("  postfix decrement: PASS\n");
	}

	printf("=== test_postfix: ALL PASS ===\n");
	return 0;
}
