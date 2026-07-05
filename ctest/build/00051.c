__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
0, 0, 0, 0, },
};
void *x = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v2;
    unsigned long long v3;
    int v4;
    int v5;
    unsigned long long v6;
    int v7;
    int v8;
    unsigned long long v9;
    int v10;
    int v11;
    unsigned long long v12;
    int v13;
    int v14;
    unsigned long long v15;
    int v16;
    unsigned long long v17;
    int v18;
    int v19;
    int v20;
    unsigned long long v21;
    int v22;
    // LINE: 6
    // LINE: 6
    v0 = (unsigned long long)x;
    v1 = *((int*)v0);
    v2 = v1 == 0ll;
    if(v2 != 0) goto l1;
    goto l0;
    l1: (void)noop;
    // LINE: 8
    l0: (void)noop;
    // LINE: 9
    v3 = (unsigned long long)x;
    v4 = *((int*)v3);
    v5 = v4 == 0ll;
    if(v5 != 0) goto l3;
    goto l2;
    l3: (void)noop;
    // LINE: 11
    v6 = (unsigned long long)x;
    v7 = *((int*)v6);
    v8 = v7 == 0ll;
    if(v8 != 0) goto l5;
    goto l6;
    l5: (void)noop;
    // LINE: 13
    goto lnext_main;
    // LINE: 13
    l6: (void)noop;
    // LINE: 15
    return 1ll;
    l4: (void)noop;
    l2: (void)noop;
    // LINE: 17
    return 1ll;
    // LINE: 18
    lnext_main: (void)noop;
    // LINE: 19
    v9 = (unsigned long long)x;
    v10 = *((int*)v9);
    v11 = v10 == 1ll;
    if(v11 != 0) goto l8;
    goto l7;
    l8: (void)noop;
    // LINE: 21
    return 1ll;
    l7: (void)noop;
    // LINE: 22
    v12 = (unsigned long long)x;
    v13 = *((int*)v12);
    v14 = v13 == 1ll;
    if(v14 != 0) goto l10;
    goto l9;
    // LINE: 24
    v15 = (unsigned long long)x;
    v16 = 1ll + 1ll;
    *((int*)v15) = v16;
    // LINE: 25
    lfoo_main: (void)noop;
    l10: (void)noop;
    // LINE: 27
    return 1ll;
    l9: (void)noop;
    // LINE: 30
    v17 = (unsigned long long)x;
    v18 = *((int*)v17);
    v19 = v18 == 0ll;
    if(v19 != 0) goto l12;
    v20 = v18 == 1ll;
    if(v20 != 0) goto l13;
    goto l14;
    l12: (void)noop;
    // LINE: 32
    v21 = (unsigned long long)x;
    v22 = *((int*)v21);
    return v22;
    l13: (void)noop;
    // LINE: 34
    return 1ll;
    l14: (void)noop;
    // LINE: 36
    return 1ll;
    l11: (void)noop;
}
int main(int argc, char **args) { return entry(); }