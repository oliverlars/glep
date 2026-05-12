#include <stdio.h>
#include <sys/stat.h>

static int test(int a) {
	return a;
}

int main(void) {
	struct stat FileStat;
	printf("sizeof stat: %zu\n", sizeof(FileStat));
}