unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v4;
    int v3;
    int v7;
    int v6;
    int v9;
    int v8;
    int v12;
    int v11;
    int v14;
    int v13;
    int v17;
    int v16;
    int v19;
    int v18;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 0ll;
    // LINE: 7
    l0: (void)noop;
    if(1ll == 0) goto l1;
    // LINE: 8
    goto l1;
    goto l0;
    l1: (void)noop;
    // LINE: 9
    l3: (void)noop;
    if(1ll == 0) goto l4;
    // LINE: 10
    // LINE: 10
    v4 = *((int*)v0);
    v3 = v4 == 5ll;
    if(v3 == 0) goto l6;
    // LINE: 11
    // LINE: 11
    goto l4;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 13
    v7 = *((int*)v0);
    v6 = v7 + 1ll;
    *((int*)v0) = v6;
    // LINE: 14
    goto l4;
    goto l3;
    l4: (void)noop;
    // LINE: 16
    // LINE: 16
    l8: (void)noop;
    // LINE: 17
    // LINE: 17
    v9 = *((int*)v0);
    v8 = v9 == 10ll;
    if(v8 == 0) goto l11;
    // LINE: 18
    // LINE: 18
    goto l9;
    goto l12;
    l11: (void)noop;
    l12: (void)noop;
    // LINE: 20
    v12 = *((int*)v0);
    v11 = v12 + 1ll;
    *((int*)v0) = v11;
    // LINE: 21
    goto l10;
    l10: (void)noop;
    goto l8;
    l9: (void)noop;
    // LINE: 23
    l13: (void)noop;
    // LINE: 24
    // LINE: 24
    v14 = *((int*)v0);
    v13 = v14 == 15ll;
    if(v13 == 0) goto l16;
    // LINE: 25
    // LINE: 25
    goto l14;
    goto l17;
    l16: (void)noop;
    l17: (void)noop;
    // LINE: 27
    v17 = *((int*)v0);
    v16 = v17 + 1ll;
    *((int*)v0) = v16;
    // LINE: 28
    goto l15;
    l15: (void)noop;
    if(1ll != 0) goto l13;
    l14: (void)noop;
    // LINE: 30
    v19 = *((int*)v0);
    v18 = v19 - 15ll;
    return v18;
}
int main(int argc, char **args) { return entry(); }