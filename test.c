#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **args) {
	printf("how many args: %d first and second args are: %s, %s", argc, *(args + 8), *(args + 16));
	FILE *a = fopen("my_compiler_is_awesome.txt", "w");
	fprintf(a, "writing to a file now works");
	fclose(a);
	return 0;
}