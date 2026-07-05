unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int zero() {
    // LINE: 4
    // LINE: 4
    return 0ll;
}
extern int one() {
    // LINE: 10
    // LINE: 10
    return 1ll;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    int v5;
    int v8;
    int v9;
    int v11;
    int v10;
    int v13;
    int v12;
    int v15;
    int v18;
    int v19;
    int v21;
    int v20;
    int v23;
    int v22;
    int v25;
    int v28;
    int v29;
    int v31;
    int v30;
    int v33;
    int v32;
    int v35;
    int v38;
    int v39;
    int v41;
    int v40;
    int v43;
    int v42;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 16
    // LINE: 16
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 17
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 19
    v5 = zero(    );
    *((int*)v0) = v5;
    // LINE: 20
    v8 = *((int*)v0);
    v9 = v8 + 1ll;
    *((int*)v0) = v9;
    *((int*)v2) = v9;
    // LINE: 21
    v11 = *((int*)v0);
    v10 = v11 != 1ll;
    if(v10 == 0) goto l0;
    // LINE: 22
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 23
    v13 = *((int*)v2);
    v12 = v13 != 1ll;
    if(v12 == 0) goto l2;
    // LINE: 24
    return 1ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 26
    v15 = one(    );
    *((int*)v0) = v15;
    // LINE: 27
    v18 = *((int*)v0);
    v19 = v18 - 1ll;
    *((int*)v0) = v19;
    *((int*)v2) = v19;
    // LINE: 28
    v21 = *((int*)v0);
    v20 = v21 != 0ll;
    if(v20 == 0) goto l4;
    // LINE: 29
    return 1ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 30
    v23 = *((int*)v2);
    v22 = v23 != 0ll;
    if(v22 == 0) goto l6;
    // LINE: 31
    return 1ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 33
    v25 = zero(    );
    *((int*)v0) = v25;
    // LINE: 34
    v28 = *((int*)v0);
    v29 = v28 + 1ll;
    *((int*)v0) = v29;
    *((int*)v2) = v28;
    // LINE: 35
    v31 = *((int*)v0);
    v30 = v31 != 1ll;
    if(v30 == 0) goto l8;
    // LINE: 36
    return 1ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 37
    v33 = *((int*)v2);
    v32 = v33 != 0ll;
    if(v32 == 0) goto l10;
    // LINE: 38
    return 1ll;
    goto l11;
    l10: (void)noop;
    l11: (void)noop;
    // LINE: 40
    v35 = one(    );
    *((int*)v0) = v35;
    // LINE: 41
    v38 = *((int*)v0);
    v39 = v38 - 1ll;
    *((int*)v0) = v39;
    *((int*)v2) = v38;
    // LINE: 42
    v41 = *((int*)v0);
    v40 = v41 != 0ll;
    if(v40 == 0) goto l12;
    // LINE: 43
    return 1ll;
    goto l13;
    l12: (void)noop;
    l13: (void)noop;
    // LINE: 44
    v43 = *((int*)v2);
    v42 = v43 != 1ll;
    if(v42 == 0) goto l14;
    // LINE: 45
    return 1ll;
    goto l15;
    l14: (void)noop;
    l15: (void)noop;
    // LINE: 47
    return 0ll;
}
int main(int argc, char **args) { return entry(); }