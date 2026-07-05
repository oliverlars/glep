unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v4;
    int v5;
    int v3;
    int v7;
    int v8;
    int v9;
    int v6;
    int v11;
    int v12;
    int v13;
    int v10;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 4ll;
    // LINE: 7
    v4 = *((int*)v0);
    v5 = v4 == 0ll;
    v3 = v5 != 0ll;
    if(v3 == 0) goto l0;
    // LINE: 8
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 9
    v7 = *((int*)v0);
    v8 = v7 == 0ll;
    v9 = v8 == 0ll;
    v6 = v9 != 1ll;
    if(v6 == 0) goto l2;
    // LINE: 10
    return 1ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 11
    v11 = *((int*)v0);
    v12 = -v11;
    v13 = 0ll - 4ll;
    v10 = v12 != v13;
    if(v10 == 0) goto l4;
    // LINE: 12
    return 1ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 13
    return 0ll;
}
int main(int argc, char **args) { return entry(); }