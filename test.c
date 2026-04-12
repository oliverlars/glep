#include <stdio.h>


int test(int a, int b) {
	return a + b;
}

int main() {
	float abc = 5.4f;
	printf("abc: %f, %f\n", abc, 1.2);

	if(abc > 0) {
		printf("abc > 0\n");
	} else {
		printf("abc <= 0\n");
	}

	printf("a + b: %d\n", test(6, 7));
}