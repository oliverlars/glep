unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    int v11;
    int v10;
    int v16;
    int v17;
    int v15;
    int v18;
    int v14;
    int v21;
    int v22;
    int v20;
    int v19;
    int v25;
    int v26;
    int v28;
    int v29;
    int v30;
    int v32;
    int v33;
    int v35;
    int v34;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[4] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    char alloca_v6[4] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    // LINE: 3
    // LINE: 3
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 4
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 5
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 6
    v7 = memset(v6, 0ll, 8ll    );
    // LINE: 8
    *((int*)v4) = 0ll;
    // LINE: 9
    *((int*)v0) = 2ll;
    // LINE: 10
    l0: (void)noop;
    v11 = *((int*)v0);
    v10 = v11 < 5000ll;
    if(v10 == 0) goto l1;
    // LINE: 11
    // LINE: 11
    *((int*)v2) = 2ll;
    // LINE: 12
    *((int*)v6) = 1ll;
    // LINE: 13
    l3: (void)noop;
    v16 = *((int*)v2);
    v17 = *((int*)v2);
    v15 = v16 * v17;
    v18 = *((int*)v0);
    v14 = v15 <= v18;
    if(v14 == 0) goto l4;
    // LINE: 14
    // LINE: 14
    v21 = *((int*)v0);
    v22 = *((int*)v2);
    v20 = v21 % v22;
    v19 = v20 == 0ll;
    if(v19 == 0) goto l6;
    // LINE: 15
    *((int*)v6) = 0ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 16
    v25 = *((int*)v2);
    v26 = v25 + 1ll;
    *((int*)v2) = v26;
    goto l3;
    l4: (void)noop;
    // LINE: 18
    v28 = *((int*)v0);
    v29 = v28 + 1ll;
    *((int*)v0) = v29;
    // LINE: 19
    v30 = *((int*)v6);
    if(v30 == 0) goto l8;
    // LINE: 20
    v32 = *((int*)v4);
    v33 = v32 + 1ll;
    *((int*)v4) = v33;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    goto l0;
    l1: (void)noop;
    // LINE: 22
    v35 = *((int*)v4);
    v34 = v35 != 669ll;
    if(v34 == 0) goto l10;
    // LINE: 23
    return 1ll;
    goto l11;
    l10: (void)noop;
    l11: (void)noop;
    // LINE: 24
    return 0ll;
}
int main(int argc, char **args) { return entry(); }