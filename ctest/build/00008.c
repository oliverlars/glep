unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v5;
    int v4;
    int v6;
    int v7;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 50ll;
    // LINE: 8
    l0: (void)noop;
    // LINE: 8
    v5 = *((int*)v0);
    v4 = v5 - 1ll;
    *((int*)v0) = v4;
    l2: (void)noop;
    v6 = *((int*)v0);
    if(v6 != 0) goto l0;
    l1: (void)noop;
    // LINE: 10
    v7 = *((int*)v0);
    return v7;
}
int main(int argc, char **args) { return entry(); }