#include <stdio.h>

int Data[8] = {
	1, 2, 3, 4, 5, 6, 7, 8
};

int *AlsoSomeData = Data;

#define VERTEX_ATTRIBUTE_FIELDS                       \
	X(int, X) \
	X(int, Y) \
	X(int, Z) \

#define X(T, NAME) T NAME;
typedef struct test { VERTEX_ATTRIBUTE_FIELDS } test;
#undef X

#define X(T, NAME) NAME,
typedef enum test2 { VERTEX_ATTRIBUTE_FIELDS } test2;
#undef X

void another_function() {
	printf("this function is called: %s\n", __func__);
}

int main() {
	int a = sizeof(a);
	test t = { .X = 1, .Y = 2, .Z = 3 };
	another_function();
	printf("Function name: %s\n", __func__);
	printf("AlsoSomeData[0] = %d\n", AlsoSomeData[1]);
	int x = 8;
	printf("CTZ: %d", __builtin_ctz(x));
	return 0;
}