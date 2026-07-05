unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v5;
    int v4;
    int v3;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 1ll;
    // LINE: 7
    v5 = *((int*)v0);
    v4 = v5 << 1ll;
    v3 = v4 != 2ll;
    if(v3 == 0) goto l0;
    // LINE: 8
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 10
    return 0ll;
}
int main(int argc, char **args) { return entry(); }