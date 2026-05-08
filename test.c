#include <assert.h>
#include <stdio.h>
#include <stdatomic.h>
int main() {
	static_assert(1 < 2, "ooga booga");

	typedef enum abc {
		A = 1,
		B = A + 2,
		C = 3
	} abc;

	printf("A = %d | B = %d | C = %d\n", A, B, C);

	atomic_ullong test;
	atomic_store(&test, 10);
	printf("Atomic test: %llu", test);
	return 0;
}