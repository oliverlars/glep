#include <assert.h>
#include <stdio.h>
int main() {
	static_assert(1 < 2, "ooga booga");

	typedef enum abc {
		A = 1,
		B = A + 2,
		C = 3
	} abc;

	printf("A = %d | B = %d | C = %d\n", A, B, C);
	return 0;
}