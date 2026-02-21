#include <stdio.h>
#include <assert.h>
#include <math.h>

#define EPSILON 0.001
#define assert_eq(a, b) assert(fabs((a) - (b)) < EPSILON)

typedef struct { double x, y, z; } Vec;

Vec vec(double x, double y, double z) { return (Vec){x, y, z}; }
Vec vadd(Vec a, Vec b) { return vec(a.x + b.x, a.y + b.y, a.z + b.z); }
Vec vmul(Vec a, double s) { return vec(a.x * s, a.y * s, a.z * s); }
double vdot(Vec a, Vec b) { return a.x * b.x + a.y * b.y + a.z * b.z; }

int main(int argc, char **args) {
	printf("=== test_structs ===\n");

	// Struct creation and member access
	{
		Vec v;
		v.x = 1.0;
		v.y = 2.0;
		v.z = 3.0;
		assert_eq(v.x, 1.0);
		assert_eq(v.y, 2.0);
		assert_eq(v.z, 3.0);
		printf("  member access: PASS\n");
	}

	// Compound literal
	{
		Vec v = (Vec){4.0, 5.0, 6.0};
		assert_eq(v.x, 4.0);
		assert_eq(v.y, 5.0);
		assert_eq(v.z, 6.0);
		printf("  compound literal: PASS\n");
	}

	// Struct return from function
	{
		Vec v = vec(1.0, 2.0, 3.0);
		assert_eq(v.x, 1.0);
		assert_eq(v.y, 2.0);
		assert_eq(v.z, 3.0);
		printf("  struct return: PASS\n");
	}

	// Struct pass by value
	{
		Vec a = vec(1.0, 2.0, 3.0);
		Vec b = vec(4.0, 5.0, 6.0);
		Vec c = vadd(a, b);
		assert_eq(c.x, 5.0);
		assert_eq(c.y, 7.0);
		assert_eq(c.z, 9.0);
		// Originals unchanged
		assert_eq(a.x, 1.0);
		assert_eq(b.x, 4.0);
		printf("  struct pass by value: PASS\n");
	}

	// Arrow access through pointer
	{
		Vec v = vec(10.0, 20.0, 30.0);
		Vec *p = &v;
		assert_eq(p->x, 10.0);
		assert_eq(p->y, 20.0);
		assert_eq(p->z, 30.0);
		printf("  arrow access: PASS\n");
	}

	// Nested struct
	{
		typedef struct { Vec origin, direction; } Ray;
		Ray r = (Ray){vec(1.0, 2.0, 3.0), vec(0.0, 1.0, 0.0)};
		assert_eq(r.origin.x, 1.0);
		assert_eq(r.origin.y, 2.0);
		assert_eq(r.direction.y, 1.0);
		printf("  nested struct: PASS\n");
	}

	// Struct assignment
	{
		Vec a = vec(1.0, 2.0, 3.0);
		Vec b;
		b = a;
		assert_eq(b.x, 1.0);
		assert_eq(b.y, 2.0);
		assert_eq(b.z, 3.0);
		// Modify b, a unchanged
		b.x = 99.0;
		assert_eq(a.x, 1.0);
		printf("  struct assignment: PASS\n");
	}

	// Struct with mixed types
	{
		typedef struct {
			int id;
			double value;
			int flag;
		} Item;
		Item item;
		item.id = 42;
		item.value = 3.14;
		item.flag = 1;
		assert(item.id == 42);
		assert_eq(item.value, 3.14);
		assert(item.flag == 1);
		printf("  mixed type struct: PASS\n");
	}

	// Dot product (struct HFA passing)
	{
		Vec a = vec(1.0, 2.0, 3.0);
		Vec b = vec(4.0, 5.0, 6.0);
		double d = vdot(a, b);
		assert_eq(d, 32.0);
		printf("  dot product (HFA): PASS\n");
	}

	// Scalar multiply (struct + double return)
	{
		Vec a = vec(2.0, 3.0, 4.0);
		Vec b = vmul(a, 2.5);
		assert_eq(b.x, 5.0);
		assert_eq(b.y, 7.5);
		assert_eq(b.z, 10.0);
		printf("  scalar multiply: PASS\n");
	}

	printf("=== test_structs: ALL PASS ===\n");
	return 0;
}
