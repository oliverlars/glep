#include <stdio.h>
#include <assert.h>

// Tests unions
// Unions are parsed with is_union flag but layout calculation treats them as structs
// (members offset sequentially instead of all at offset 0)

union IntOrFloat {
	int i;
	float f;
};

union Packed {
	int i;
	char bytes[4];
};

int main(int argc, char **args) {
	printf("=== test_union ===\n");

	// Union size should be max of members
	{
		assert(sizeof(union IntOrFloat) == 4);
		printf("  union sizeof: PASS\n");
	}

	// Union members share memory
	{
		union IntOrFloat u;
		u.i = 42;
		assert(u.i == 42);
		u.f = 3.14f;
		// i is now garbage (overwritten by float)
		assert(u.f > 3.13f && u.f < 3.15f);
		printf("  union shared memory: PASS\n");
	}

	// Union byte access
	{
		union Packed p;
		p.i = 0x01020304;
		// On little-endian ARM:
		assert(p.bytes[0] == 0x04);
		assert(p.bytes[3] == 0x01);
		printf("  union byte access: PASS\n");
	}

	printf("=== test_union: ALL PASS ===\n");
	return 0;
}
