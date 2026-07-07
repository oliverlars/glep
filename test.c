#include <stdio.h>

#include <stdint.h>
#include <stdlib.h>
#include <assert.h>

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

#define per_thread_local __thread

struct foo {
} foo;

per_thread_local struct foo a;

typedef struct m44f { float E[4][4]; } m44f;

#define ArenaPushArrayZero(Arena, Type, Count) (Type*)ArenaPushAlignZero(Arena, sizeof(Type)*Count, _Alignof(Type))


int GlobalInt = 123;
int *PointerToGlobalInt = &GlobalInt;

typedef struct {
	int a;
	union {
		int b1;
		int b2;
	};
	struct { union { struct { int c; }; }; };
	struct {
		int d;
	};
} s;

int main() {

	s v;

	printf("sizeof struct { union { struct { int c; }; }; }; = %lu\n", sizeof(struct { union { struct { int c; }; };}));
	v.a = 1;
	v.b1 = 2;
	v.c = 3;
	v.d = 4;

	printf("v.a = %d\n", v.a);
	printf("v.c = %d\n", v.c);

	if (v.a != 1)
		return 1;
	if (v.b1 != 2 && v.b2 != 2)
		return 2;
	if (v.c != 3)
		return 3;
	if (v.d != 4)
		return 4;

	printf("PointerToGlobalInt = %d", PointerToGlobalInt[0]);
	int a = sizeof(a);
	test t = { .X = 1, .Y = 2, .Z = 3 };
	test t2 = {0};
	m44f m = {0};
	another_function();
	printf("Function name: %s\n", __func__);
	printf("AlsoSomeData[0] = %d\n", AlsoSomeData[1]);
	int x = 8;
	printf("CTZ: %d", __builtin_ctz(x));
	return 0;
}