unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v5;
    int v4;
    unsigned long long v7;
    int v6;
    unsigned long long v9;
    int v8;
    unsigned long long v12;
    unsigned long long v11;
    unsigned long long v13;
    int v10;
    int v14;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 6
    v5 = (unsigned long long)2ll;
    v4 = 4llu < v5;
    if(v4 == 0) goto l0;
    // LINE: 7
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 8
    v7 = (unsigned long long)2ll;
    v6 = 4llu < v7;
    if(v6 == 0) goto l2;
    // LINE: 9
    return 1ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 10
    v9 = (unsigned long long)1ll;
    v8 = 1llu < v9;
    if(v8 == 0) goto l4;
    // LINE: 11
    return 1ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 12
    v12 = (unsigned long long)2ll;
    v11 = 4llu - v12;
    v13 = (unsigned long long)0ll;
    v10 = v11 < v13;
    if(v10 == 0) goto l6;
    // LINE: 13
    return 1ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 14
    v14 = 8llu != 8llu;
    if(v14 == 0) goto l8;
    // LINE: 15
    return 1ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 16
    return 0ll;
}
int main(int argc, char **args) { return entry(); }