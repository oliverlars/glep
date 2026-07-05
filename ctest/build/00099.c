unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
static void vecresize(unsigned long long v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    v1 = memset(v0, 0ll, 8ll    );
    *((unsigned long long*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 7
    // LINE: 7
    return;
}
extern int entry() {
    // LINE: 12
    // LINE: 12
    return 0ll;
}
int main(int argc, char **args) { return entry(); }