#include <stdio.h>

int Data[1024];

int *AlsoSomeData = Data;


int main() {
	printf("AlsoSomeData[0] = %d", AlsoSomeData[1]);
	return 0;
}