#include <stdio.h>
#include <assert.h>
#include <float.h>
#include <time.h>
#include <stdlib.h>

int main(int argc, char **args) {
	int *a = malloc(4);
	*a = 10;
	printf("a is: %d", *a);
	return 0;
}