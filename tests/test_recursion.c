#include <stdio.h>
#include <assert.h>
#include <math.h>

#define EPSILON 0.001
#define assert_eq(a, b) assert(fabs((a) - (b)) < EPSILON)

// Simple integer recursion: factorial
int factorial(int n) {
	if (n <= 1) return 1;
	return n * factorial(n - 1);
}

// Fibonacci
int fib(int n) {
	if (n <= 0) return 0;
	if (n == 1) return 1;
	return fib(n - 1) + fib(n - 2);
}

// Recursive with struct return
typedef struct { double x, y, z; } Vec;
Vec vec(double x, double y, double z) { return (Vec){x, y, z}; }
Vec vadd(Vec a, Vec b) { return vec(a.x + b.x, a.y + b.y, a.z + b.z); }
Vec vmul(Vec a, double s) { return vec(a.x * s, a.y * s, a.z * s); }

Vec recursive_sum(int depth) {
	if (depth <= 0) return vec(0.0, 0.0, 0.0);
	Vec child = recursive_sum(depth - 1);
	return vadd(child, vec(1.0, 2.0, 3.0));
}

// Recursive struct-returning with multiple parameters
Vec recursive_scale(Vec v, int depth) {
	if (depth <= 0) return v;
	return recursive_scale(vmul(v, 0.5), depth - 1);
}

// Mutual recursion
int is_even(int n);
int is_odd(int n);

int is_even(int n) {
	if (n == 0) return 1;
	return is_odd(n - 1);
}

int is_odd(int n) {
	if (n == 0) return 0;
	return is_even(n - 1);
}

int main(int argc, char **args) {
	printf("=== test_recursion ===\n");

	// Factorial
	{
		assert(factorial(0) == 1);
		assert(factorial(1) == 1);
		assert(factorial(5) == 120);
		assert(factorial(10) == 3628800);
		printf("  factorial: PASS\n");
	}

	// Fibonacci
	{
		assert(fib(0) == 0);
		assert(fib(1) == 1);
		assert(fib(10) == 55);
		assert(fib(15) == 610);
		printf("  fibonacci: PASS\n");
	}

	// Recursive struct sum
	{
		Vec r = recursive_sum(5);
		assert_eq(r.x, 5.0);
		assert_eq(r.y, 10.0);
		assert_eq(r.z, 15.0);
		printf("  recursive struct sum: PASS\n");
	}

	// Recursive scale
	{
		Vec v = vec(16.0, 32.0, 64.0);
		Vec r = recursive_scale(v, 4);
		assert_eq(r.x, 1.0);
		assert_eq(r.y, 2.0);
		assert_eq(r.z, 4.0);
		printf("  recursive scale: PASS\n");
	}

	// Mutual recursion
	{
		assert(is_even(0));
		assert(!is_odd(0));
		assert(is_odd(5));
		assert(is_even(10));
		assert(!is_even(7));
		printf("  mutual recursion: PASS\n");
	}

	// Deep recursion
	{
		int r = factorial(12);
		assert(r == 479001600);
		printf("  deep recursion: PASS\n");
	}

	printf("=== test_recursion: ALL PASS ===\n");
	return 0;
}
