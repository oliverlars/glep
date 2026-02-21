#include <stdio.h>
#include <assert.h>

// Tests switch/case/default statements
// These are parsed but not codegen'd (compile_statement has no case for Node_Switch)

int classify(int x) {
	int result = -1;
	switch (x) {
		case 0:
			result = 0;
			break;
		case 1:
			result = 1;
			break;
		case 2:
		case 3:
			result = 23;
			break;
		default:
			result = 99;
			break;
	}
	return result;
}

int main(int argc, char **args) {
	printf("=== test_switch ===\n");

	assert(classify(0) == 0);
	assert(classify(1) == 1);
	assert(classify(2) == 23);
	assert(classify(3) == 23);
	assert(classify(42) == 99);
	printf("  switch/case: PASS\n");

	printf("=== test_switch: ALL PASS ===\n");
	return 0;
}
