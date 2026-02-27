#include <stdio.h>
#include <stdlib.h>

int main() {
	int n = 1000000, hits = 0;
	for (int i = 0; i < n; i++) {
		double x = (double)rand() / RAND_MAX;
		double y = (double)rand() / RAND_MAX;
		if (x*x + y*y <= 1.0) hits++;
	}
	printf("pi ≈ %f\n", 4.0 * hits / n);
}