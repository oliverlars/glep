#include <stdio.h>
#include <assert.h>

// Tests bitwise OR (|), XOR (^), logical OR (||), and bitwise NOT (~)
// The binary compile case has no codegen for Pipe, Caret, PipePipe, or Tilde

int main(int argc, char **args) {
	printf("=== test_bitwise_or_xor ===\n");

	// Bitwise OR
	{
		int a = 0x0F;
		int b = 0xF0;
		int c = a | b;
		assert(c == 0xFF);
		printf("  bitwise OR: PASS\n");
	}

	// Bitwise XOR
	{
		int a = 0xFF;
		int b = 0x0F;
		int c = a ^ b;
		assert(c == 0xF0);
		printf("  bitwise XOR: PASS\n");
	}

	// Logical OR (short-circuit)
	{
		int a = 0;
		int b = 1;
		assert(a || b);
		assert(b || a);
		assert(!(a || 0));
		printf("  logical OR: PASS\n");
	}

	// Bitwise NOT
	{
		unsigned int a = 0;
		unsigned int b = ~a;
		assert(b == 0xFFFFFFFF);
		printf("  bitwise NOT: PASS\n");
	}

	printf("=== test_bitwise_or_xor: ALL PASS ===\n");
	return 0;
}
