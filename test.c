#include <stdio.h>

int Data[8] = {
	1, 2, 3, 4, 5, 6, 7, 8
};

int *AlsoSomeData = Data;


int main() {
	printf("AlsoSomeData[0] = %d\n", AlsoSomeData[1]);
	return 0;
}