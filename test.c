#include <stdio.h>
#include <assert.h>
#include <float.h>
#include <time.h>
#include <stdlib.h>


int x = 5;

int get(int a) {
	return a;
}

int main(int argc, char **args) {
	printf("abc %d", argc);
	{
		int x = 10;
		int a = x + 1;
		printf("a should be 11: %d", a);
	}
	int a = x + 1;
	printf(" a should be 6: %d", a);
	return 1 + get(a);
}