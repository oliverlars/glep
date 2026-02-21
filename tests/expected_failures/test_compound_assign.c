#include <stdio.h>
#include <assert.h>

// Tests compound assignment operators (+=, -=, *=, /=, %=, &=, |=, ^=, <<=, >>=)
// These are parsed but not codegen'd in compile.jai (Node_Assign only handles .Equals)

int main(int argc, char **args) {
	printf("=== test_compound_assign ===\n");

	// +=
	{
		int a = 10;
		a += 5;
		assert(a == 15);
		printf("  += : PASS\n");
	}

	// -=
	{
		int a = 10;
		a -= 3;
		assert(a == 7);
		printf("  -= : PASS\n");
	}

	// *=
	{
		int a = 5;
		a *= 4;
		assert(a == 20);
		printf("  *= : PASS\n");
	}

	// /=
	{
		int a = 20;
		a /= 4;
		assert(a == 5);
		printf("  /= : PASS\n");
	}

	// %=
	{
		int a = 17;
		a %= 5;
		assert(a == 2);
		printf("  %%= : PASS\n");
	}

	// &=
	{
		int a = 0xFF;
		a &= 0x0F;
		assert(a == 0x0F);
		printf("  &= : PASS\n");
	}

	// |=
	{
		int a = 0x0F;
		a |= 0xF0;
		assert(a == 0xFF);
		printf("  |= : PASS\n");
	}

	// ^=
	{
		int a = 0xFF;
		a ^= 0x0F;
		assert(a == 0xF0);
		printf("  ^= : PASS\n");
	}

	// <<=
	{
		int a = 1;
		a <<= 4;
		assert(a == 16);
		printf("  <<= : PASS\n");
	}

	// >>=
	{
		int a = 16;
		a >>= 2;
		assert(a == 4);
		printf("  >>= : PASS\n");
	}

	// += on double
	{
		double d = 1.5;
		d += 2.5;
		assert(d > 3.99 && d < 4.01);
		printf("  += double: PASS\n");
	}

	printf("=== test_compound_assign: ALL PASS ===\n");
	return 0;
}
