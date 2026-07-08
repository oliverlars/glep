#include <stdio.h>

struct {
	int a;
	struct {
		int b;
	};
} test;

int main() {
	test.a = 123;
	test.b = 456;
	printf("I still got it: %d %d\n", test.a, test.b);
}