#include <stdio.h>
#include <assert.h>
#include <float.h>
#include <time.h>
#include <stdlib.h>

int main(int argc, char **args) {
	int a = 5;
	int *b = &a;
	printf("%p %p", b, &a);
	return 0;
}