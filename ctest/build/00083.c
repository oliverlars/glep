unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int one(int v2) {
    unsigned long long v0;
    int v1;
    int v4;
    int v3;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    // LINE: 6
    // LINE: 6
    v4 = *((int*)v0);
    v3 = v4 != 1ll;
    if(v3 == 0) goto l0;
    // LINE: 7
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 9
    return 0ll;
}
extern int two(int v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    int v7;
    int v6;
    int v9;
    int v8;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 15
    // LINE: 15
    v7 = *((int*)v0);
    v6 = v7 != 1ll;
    if(v6 == 0) goto l2;
    // LINE: 16
    return 1ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 17
    v9 = *((int*)v3);
    v8 = v9 != 2ll;
    if(v8 == 0) goto l4;
    // LINE: 18
    return 1ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 20
    return 0ll;
}
extern int three(int v2,
int v5,
int v8) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
    int v7;
    int v10;
    int v9;
    int v12;
    int v11;
    int v14;
    int v13;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v6[4] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    v7 = memset(v6, 0ll, 8ll    );
    *((int*)v6) = v8;
    // LINE: 26
    // LINE: 26
    v10 = *((int*)v0);
    v9 = v10 != 1ll;
    if(v9 == 0) goto l6;
    // LINE: 27
    return 1ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 28
    v12 = *((int*)v3);
    v11 = v12 != 2ll;
    if(v11 == 0) goto l8;
    // LINE: 29
    return 1ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 30
    v14 = *((int*)v6);
    v13 = v14 != 3ll;
    if(v13 == 0) goto l10;
    // LINE: 31
    return 1ll;
    goto l11;
    l10: (void)noop;
    l11: (void)noop;
    // LINE: 33
    return 0ll;
}
extern int entry() {
    int v0;
    int v1;
    int v2;
    // LINE: 39
    // LINE: 39
    v0 = one(1ll    );
    if(v0 == 0) goto l12;
    // LINE: 40
    return 2ll;
    goto l13;
    l12: (void)noop;
    l13: (void)noop;
    // LINE: 41
    v1 = two(1ll, 2ll    );
    if(v1 == 0) goto l14;
    // LINE: 42
    return 3ll;
    goto l15;
    l14: (void)noop;
    l15: (void)noop;
    // LINE: 43
    v2 = three(1ll, 2ll, 3ll    );
    if(v2 == 0) goto l16;
    // LINE: 44
    return 4ll;
    goto l17;
    l16: (void)noop;
    l17: (void)noop;
    // LINE: 46
    return 0ll;
}
int main(int argc, char **args) { return entry(); }