#include <assert.h>

#include <stdio.h>

#include <stdlib.h>

#include <math.h>

#define true 1
#define false 0

#define TEST __LINE__

typedef struct { double x, y, z; } Vec;

Vec vec(double x, double y, double z) { return (Vec){x, y, z}; }
Vec vadd(Vec a, Vec b)    { return vec(a.x+b.x, a.y+b.y, a.z+b.z); }
Vec vsub(Vec a, Vec b)    { return vec(a.x-b.x, a.y-b.y, a.z-b.z); }
Vec vmul(Vec a, double s) { return vec(a.x*s, a.y*s, a.z*s); }
Vec vmult(Vec a, Vec b)   { return vec(a.x*b.x, a.y*b.y, a.z*b.z); }
double vdot(Vec a, Vec b) { return a.x*b.x + a.y*b.y + a.z*b.z; }
Vec vcross(Vec a, Vec b)  { return vec(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x); }
Vec vnorm(Vec v)          { return vmul(v, 1.0/sqrt(vdot(v,v))); }

typedef struct { Vec o, d; } Ray;

int main(int argc, char **args) {
	printf("abc: %d\n", TEST);
	assert(-1 > 0u);
	assert(-1 < 0);
	assert(__LINE__ == 31);
	{
		Vec vecs[2];
		Vec *heap_vecs = malloc(2 * sizeof(Vec));
		Vec a = (Vec) { 1, 2, 3 };
		Vec b = (Vec) { 4, 5, 6 };
		vecs[0] = a;
		vecs[1] = b;
		heap_vecs[0] = a;
		heap_vecs[1] = b;

		Vec c = vadd(vecs[0], vecs[1]);
		assert((int)c.x == 5);
		assert((int)c.y == 7);
		assert((int)c.z == 9);
		c = vadd(heap_vecs[0], heap_vecs[1]);
		assert((int)c.x == 5);
		assert((int)c.y == 7);
		assert((int)c.z == 9);
	}

	if(true) {
		assert(true);
	} else {
		assert(false);
	}


	printf("Finished running tests without crashing\n");
}