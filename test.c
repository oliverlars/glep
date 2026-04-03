#include <stdio.h>

int main() {

	char *strings[2][2] = {
		{"A", "B"},
		{"Z", "Y"},
	};

	// prints pointer?
	printf("sizeof strings2d[0] = %p\n", strings[0]);

	// prints pointer ?
	printf("sizeof strings2d[0] = ps\n", strings[1]);

	// crashes
	printf("sizeof strings2d[0] = %s\n", strings[0][0]);

	// crashes
	printf("sizeof strings2d[0] = %s\n", *(*(strings + 0) + 0));

	return 0;
}