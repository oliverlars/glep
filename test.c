#include <assert.h>
int main() {
	static_assert(1 < 2, "ooga booga");
	return 0;
}