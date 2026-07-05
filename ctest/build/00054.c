unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v2;
    int v3;
    int v4;
    int v6;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 10
    // LINE: 10
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 12
    v2 = 0ll != 0ll;
    if(v2 == 0) goto l0;
    // LINE: 13
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 14
    v3 = 1ll != 1ll;
    if(v3 == 0) goto l2;
    // LINE: 15
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 16
    v4 = 2ll != 2ll;
    if(v4 == 0) goto l4;
    // LINE: 17
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 19
    *((int*)v0) = 0ll;
    // LINE: 20
    v6 = *((int*)v0);
    return v6;
}
int main(int argc, char **args) { return entry(); }