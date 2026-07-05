__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
},
};
void *g = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int effect() {
    unsigned long long v0;
    // LINE: 6
    // LINE: 6
    v0 = (unsigned long long)g;
    *((int*)v0) = 1ll;
    // LINE: 7
    return 1ll;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v5;
    int v6;
    int v4;
    unsigned long long v7;
    int v8;
    int v11;
    int v12;
    int v10;
    unsigned long long v14;
    int v15;
    int v13;
    unsigned long long v16;
    int v19;
    int v18;
    int v20;
    unsigned long long v21;
    int v22;
    int v25;
    int v24;
    int v26;
    unsigned long long v28;
    int v29;
    int v27;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 13
    // LINE: 13
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 15
    v2 = (unsigned long long)g;
    *((int*)v2) = 0ll;
    // LINE: 16
    *((int*)v0) = 0ll;
    // LINE: 17
    v5 = *((int*)v0);
    if(v5 == 0) goto l2;
    v6 = effect(    );
    v4 = v6 != 0ll;
    goto l3;
    l2: (void)noop;
    v4 = 0ll;
    l3: (void)noop;
    if(v4 == 0) goto l0;
    // LINE: 18
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 19
    v7 = (unsigned long long)g;
    v8 = *((int*)v7);
    if(v8 == 0) goto l4;
    // LINE: 20
    return 2ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 21
    *((int*)v0) = 1ll;
    // LINE: 22
    v11 = *((int*)v0);
    if(v11 == 0) goto l8;
    v12 = effect(    );
    v10 = v12 != 0ll;
    goto l9;
    l8: (void)noop;
    v10 = 0ll;
    l9: (void)noop;
    if(v10 == 0) goto l6;
    // LINE: 23
    // LINE: 23
    v14 = (unsigned long long)g;
    v15 = *((int*)v14);
    v13 = v15 != 1ll;
    if(v13 == 0) goto l10;
    // LINE: 24
    return 3ll;
    goto l11;
    l10: (void)noop;
    l11: (void)noop;
    goto l7;
    l6: (void)noop;
    // LINE: 26
    // LINE: 26
    return 4ll;
    l7: (void)noop;
    // LINE: 28
    v16 = (unsigned long long)g;
    *((int*)v16) = 0ll;
    // LINE: 29
    *((int*)v0) = 1ll;
    // LINE: 30
    v19 = *((int*)v0);
    v18 = v19 != 0ll;
    if(v19 != 0) goto l14;
    v20 = effect(    );
    v18 = v20 != 0ll;
    l14: (void)noop;
    if(v18 == 0) goto l12;
    // LINE: 31
    // LINE: 31
    v21 = (unsigned long long)g;
    v22 = *((int*)v21);
    if(v22 == 0) goto l15;
    // LINE: 32
    return 5ll;
    goto l16;
    l15: (void)noop;
    l16: (void)noop;
    goto l13;
    l12: (void)noop;
    // LINE: 34
    // LINE: 34
    return 6ll;
    l13: (void)noop;
    // LINE: 36
    *((int*)v0) = 0ll;
    // LINE: 37
    v25 = *((int*)v0);
    v24 = v25 != 0ll;
    if(v25 != 0) goto l19;
    v26 = effect(    );
    v24 = v26 != 0ll;
    l19: (void)noop;
    if(v24 == 0) goto l17;
    // LINE: 38
    // LINE: 38
    v28 = (unsigned long long)g;
    v29 = *((int*)v28);
    v27 = v29 != 1ll;
    if(v27 == 0) goto l20;
    // LINE: 39
    return 7ll;
    goto l21;
    l20: (void)noop;
    l21: (void)noop;
    goto l18;
    l17: (void)noop;
    // LINE: 41
    // LINE: 41
    return 8ll;
    l18: (void)noop;
    // LINE: 43
    return 0ll;
}
int main(int argc, char **args) { return entry(); }