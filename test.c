#include <stdio.h>

int main(int argc, char **args) {
	FILE *a = fopen("my_compiler_is_awesome.txt", "w");
	fprintf(a, "writing to a file now works");
	fclose(a);
	return 0;
}