#include <stdio.h>
#include <stdlib.h>

float sqr(float s) {
	return s * s;
}

int main(int argc, char **args) {

	int a = 5;
	float f = (float)argc + 1.0f;
	int i = f;
	printf(" float test: %f", sqr(f));
	return 0;
}