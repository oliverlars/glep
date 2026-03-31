//#include <stdio.h>

//#include <assert.h>

typedef struct { double x, y, z; } Vec;

// Vec vec(double x, double y, double z) { return (Vec){x, y, z}; }
// Vec vadd(Vec a, Vec b)    { return vec(a.x+b.x, a.y+b.y, a.z+b.z); }
// Vec vsub(Vec a, Vec b)    { return vec(a.x-b.x, a.y-b.y, a.z-b.z); }
// Vec vmul(Vec a, double s) { return vec(a.x*s, a.y*s, a.z*s); }
// Vec vmult(Vec a, Vec b)   { return vec(a.x*b.x, a.y*b.y, a.z*b.z); }
// double vdot(Vec a, Vec b) { return a.x*b.x + a.y*b.y + a.z*b.z; }
// Vec vcross(Vec a, Vec b)  { return vec(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x); }

// void print_vec(Vec v) {
// 	printf("[%f, %f, %f]", v.x, v.y, v.z);
// }

// void print_array(double *array, int n) {
// 	printf("[ ");
// 	for(int i = 0; i < n; i++) {
// 		printf("%f ", array[i]);
// 	}
// 	printf("]\n");
// }

// Vec global_vec = {1.0, 2.0, 3.0};

// Vec array[2] = {
// 	{1, 2, 3},
// 	{4, 5, 6}
// };

int abc(int a, int b, int c) {
	return a + b + c;
}


int main() {


	//Vec some_vec = vec(1, 2, 3);
	//print_vec(some_vec);

	// abc[0] = 1.0;
	// abc[1] = 2.0;
	// abc[2] = 3.0;

	// double abc[3] = { 1, 2, 3};

	// printf("abc = %f\n", abc[0]);

	// printf("*(abc + 1) = %f\n", *(abc + 1));

	//print_array(abc, 3);

	Vec test;

	//int a = test + 1;

	abc(1, 2, test);

	Vec asdfasdf = abc(1, 2, 3);

	int a = *1;

	return 0;
}