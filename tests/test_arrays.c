#include <stdio.h>
#include <assert.h>

int global_arr[5] = {100, 200, 300, 400, 500};

int main(int argc, char **args) {
	printf("=== test_arrays ===\n");

	// Local array initialization and access
	{
		int arr[5] = {1, 2, 3, 4, 5};
		assert(arr[0] == 1);
		assert(arr[2] == 3);
		assert(arr[4] == 5);
		printf("  local array access: PASS\n");
	}

	// Global array access
	{
		assert(global_arr[0] == 100);
		assert(global_arr[2] == 300);
		assert(global_arr[4] == 500);
		printf("  global array access: PASS\n");
	}

	// Array write
	{
		int arr[3] = {0, 0, 0};
		arr[0] = 10;
		arr[1] = 20;
		arr[2] = 30;
		assert(arr[0] == 10);
		assert(arr[1] == 20);
		assert(arr[2] == 30);
		printf("  array write: PASS\n");
	}

	// Array as loop accumulator
	{
		int arr[10];
		for (int i = 0; i < 10; ++i) {
			arr[i] = i * i;
		}
		assert(arr[0] == 0);
		assert(arr[3] == 9);
		assert(arr[9] == 81);
		printf("  array loop fill: PASS\n");
	}

	// Double array
	{
		double arr[3] = {1.5, 2.5, 3.5};
		assert(arr[0] > 1.49 && arr[0] < 1.51);
		assert(arr[1] > 2.49 && arr[1] < 2.51);
		assert(arr[2] > 3.49 && arr[2] < 3.51);
		printf("  double array: PASS\n");
	}

	// Sizeof array
	{
		int arr[10];
		assert(sizeof(arr) == 40);
		assert(sizeof(arr) / sizeof(int) == 10);
		printf("  sizeof array: PASS\n");
	}

	// Array of structs
	{
		typedef struct { int x; int y; } Point;
		Point pts[3] = {{1, 2}, {3, 4}, {5, 6}};
		assert(pts[0].x == 1);
		assert(pts[0].y == 2);
		assert(pts[1].x == 3);
		assert(pts[2].y == 6);
		printf("  array of structs: PASS\n");
	}

	printf("=== test_arrays: ALL PASS ===\n");
	return 0;
}
