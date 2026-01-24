#include <stdio.h>
#include <stdlib.h>

float sqr(float x) {
	return x * x;
}

int main(int argc, char **args) {

	int a = 5;
	float f = (float)argc + 1.0f;
	float f2 = sqr(f);
	double f2d = f;
	double abc = 5;
	double def = f;
	double x = f;
	double y = f;
	double z = f;
	printf(" float test: %f", f2);
	return 0;
}