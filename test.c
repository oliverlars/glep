#include <assert.h>

#include <stdio.h>

#include <stdlib.h>

#include <math.h>

#define true 1
#define false 0


typedef struct { double x, y, z; } Vec;

Vec vec(double x, double y, double z) { return (Vec){x, y, z}; }
Vec vadd(Vec a, Vec b)    { return vec(a.x+b.x, a.y+b.y, a.z+b.z); }
Vec vsub(Vec a, Vec b)    { return vec(a.x-b.x, a.y-b.y, a.z-b.z); }
Vec vmul(Vec a, double s) { return vec(a.x*s, a.y*s, a.z*s); }
Vec vmult(Vec a, Vec b)   { return vec(a.x*b.x, a.y*b.y, a.z*b.z); }
double vdot(Vec a, Vec b) { return a.x*b.x + a.y*b.y + a.z*b.z; }
Vec vcross(Vec a, Vec b)  { return vec(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x); }
Vec vnorm(Vec v)          { return vmul(v, 1.0/sqrt(vdot(v,v))); }

#define EPSILON 0.001
#define assert_eq(a, b) assert(fabs((a) - (b)) < EPSILON)

void assert_vec_eq(Vec a, Vec b) {
	printf("[%f, %f, %f]\n", a.x, a.y, a.z);
	printf("[%f, %f, %f]\n", b.x, b.y, b.z);
	assert_eq(a.x, b.x);
	assert_eq(a.y, b.y);
	assert_eq(a.z, b.z);
}

typedef struct { Vec o, d; } Ray;

#define TEST __LINE__

Vec global_vecs[2] = {
	{ .z = 1, .y = 2, .x = 3 },
	{ .y = 1, 2 }
};

int main(int argc, char **args) {
	printf("abc: %d\n", __LINE__);
	assert(-1 > 0u);
	assert(-1 < 0);

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

		assert((int) global_vecs[0].x == 3);
		assert((int) global_vecs[0].y == 2);
		assert((int) global_vecs[0].z == 1);

		assert((int) global_vecs[1].x == 0);
		assert((int) global_vecs[1].y == 1);
		assert((int) global_vecs[1].z == 2);

		Vec v = vec(1.0, 2.0, 3.0);
		assert_vec_eq(v, (Vec){1.0, 2.0, 3.0});

		assert_vec_eq(vadd(vec(1,2,3), vec(4,5,6)), vec(5,7,9));
		assert_vec_eq(vadd(vec(-1,-2,-3), vec(1,2,3)), vec(0,0,0));

		assert_vec_eq(vsub(vec(5,7,9), vec(4,5,6)), vec(1,2,3));
		assert_vec_eq(vsub(vec(1,1,1), vec(1,1,1)), vec(0,0,0));

		assert_vec_eq(vmul(vec(1,2,3), 2.0), vec(2,4,6));
		assert_vec_eq(vmul(vec(1,2,3), 0.0), vec(0,0,0));
		assert_vec_eq(vmul(vec(1,2,3), -1.0), vec(-1,-2,-3));

		assert_vec_eq(vmult(vec(2,3,4), vec(5,6,7)), vec(10,18,28));

		assert_eq(vdot(vec(1,0,0), vec(0,1,0)), 0.0);
		assert_eq(vdot(vec(1,2,3), vec(4,5,6)), 32.0);
		assert_eq(vdot(vec(1,0,0), vec(1,0,0)), 1.0);

		assert_vec_eq(vcross(vec(1,0,0), vec(0,1,0)), vec(0,0,1));
		assert_vec_eq(vcross(vec(0,1,0), vec(1,0,0)), vec(0,0,-1));
		assert_vec_eq(vcross(vec(1,0,0), vec(1,0,0)), vec(0,0,0));

		assert_vec_eq(vnorm(vec(3,0,0)), vec(1,0,0));
		assert_vec_eq(vnorm(vec(0,0,5)), vec(0,0,1));
		Vec n = vnorm(vec(1,1,1));
		assert_eq(vdot(n, n), 1.0);
	}

	if(true) {
		assert(true);
	} else {
		assert(false);
	}


	printf("Finished running tests without crashing\n");
}