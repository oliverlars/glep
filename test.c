#include <stdio.h>
#include <assert.h>
#include <float.h>
#include <time.h>
#include <stdlib.h>

int *wrapped_malloc(int size) {
	return malloc(size);
}

int sqr(int num) {
	return num * num;
}

int main(int argc, char **args) {
	int *a = wrapped_malloc(4);
	*a = sqr(10);
	printf("a is: %d", *a);
	return 0;
}