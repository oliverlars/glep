unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    int v5;
    int v4;
    int v7;
    int v6;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = 0ll;
    // LINE: 5
    v3 = memset(v2, 0ll, 8ll    );
    *((int*)v2) = 1ll;
    // LINE: 6
    v5 = *((int*)v0);
    if(v5 == 0) goto l2;
    v4 = 1ll;
    goto l3;
    l2: (void)noop;
    v4 = 0ll;
    l3: (void)noop;
    if(v4 == 0) goto l0;
    // LINE: 7
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 8
    v7 = *((int*)v2);
    if(v7 == 0) goto l6;
    v6 = 0ll;
    goto l7;
    l6: (void)noop;
    v6 = 1ll;
    l7: (void)noop;
    if(v6 == 0) goto l4;
    // LINE: 9
    return 2ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 10
    return 0ll;
}
int main(int argc, char **args) { return entry(); }