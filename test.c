#include <assert.h>

#include <stdio.h>

#define TEST __LINE__

int main(int argc, char **args) {
	printf("abc: %d\n", TEST);
	assert(-1 > 0u);
	assert(-1 < 0);
}