#include <stdio.h>
#include <assert.h>
#include <float.h>
#include <time.h>
#include <stdlib.h>


int get(int a) {
	return a;
}

int main(int argc, char **args) {
	printf("abc %d", argc);
	int a = 5;
	return 1 + get(a);
}