#include <stdio.h>
#include <stdlib.h>

float sqr(float x) {
	return x * x;
}

int main(int argc, char **args) {

	int a = 5;
	float f = a + 1.0;
	float f2 = sqr(f);
	printf(" float test: %f", f2);
	return 0;
}