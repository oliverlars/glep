#include <stdio.h>


int test(int a, int b) {
	return a + b;
}

typedef struct v3 {
	float x, y, z;
} v3;

v3 make_v3(float x, float y, float z) {
	return (v3){ x, y, z};
}

int main() {
	float abc = 5.4f;
	printf("abc: %f, %f\n", abc, 1.2);

	if(abc > 0) {
		printf("abc > 0\n");
	} else {
		printf("abc <= 0\n");
	}

	v3 v = make_v3(1, 2, 3);

	printf("v: [%f, %f, %f]\n", v.x, v.y, v.z);

	printf("a + b: %d\n", test(6, 7));
}