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
    int v8;
    long long v7;
    int v9;
    int v12;
    unsigned long long v13;
    unsigned long long v11;
    int v16;
    unsigned long long v15;
    unsigned long long v17;
    int v20;
    unsigned long long v19;
    unsigned long long v21;
    int v24;
    unsigned long long v23;
    unsigned long long v25;
    int v28;
    unsigned long long v29;
    unsigned long long v27;
    int v32;
    unsigned long long v33;
    unsigned long long v31;
    int v36;
    unsigned long long v35;
    unsigned long long v37;
    unsigned long long v39;
    int v38;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[8] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 5
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 7
    v8 = *((int*)v0);
    if(v8 == 0) goto l0;
    v7 = 0ll;
    goto l1;
    l0: (void)noop;
    v7 = 0ll;
    l1: (void)noop;
    v9 = (int)v7;
    *((int*)v0) = v9;
    // LINE: 8
    v12 = *((int*)v0);
    if(v12 == 0) goto l2;
    v13 = (unsigned long long)0ll;
    v11 = v13;
    goto l3;
    l2: (void)noop;
    v11 = 0ll;
    l3: (void)noop;
    *((unsigned long long*)v4) = v11;
    // LINE: 9
    v16 = *((int*)v0);
    if(v16 == 0) goto l4;
    v15 = 0ll;
    goto l5;
    l4: (void)noop;
    v17 = (unsigned long long)0ll;
    v15 = v17;
    l5: (void)noop;
    *((unsigned long long*)v4) = v15;
    // LINE: 10
    v20 = *((int*)v0);
    if(v20 == 0) goto l6;
    v19 = 0ll;
    goto l7;
    l6: (void)noop;
    v21 = (unsigned long long)0ll;
    v19 = v21;
    l7: (void)noop;
    *((unsigned long long*)v4) = v19;
    // LINE: 11
    v24 = *((int*)v0);
    if(v24 == 0) goto l8;
    v23 = 0ll;
    goto l9;
    l8: (void)noop;
    v25 = *((unsigned long long*)v4);
    v23 = v25;
    l9: (void)noop;
    *((unsigned long long*)v2) = v23;
    // LINE: 12
    v28 = *((int*)v0);
    if(v28 == 0) goto l10;
    v29 = *((unsigned long long*)v4);
    v27 = v29;
    goto l11;
    l10: (void)noop;
    v27 = 0ll;
    l11: (void)noop;
    *((unsigned long long*)v2) = v27;
    // LINE: 13
    v32 = *((int*)v0);
    if(v32 == 0) goto l12;
    v33 = *((unsigned long long*)v2);
    v31 = v33;
    goto l13;
    l12: (void)noop;
    v31 = 0ll;
    l13: (void)noop;
    *((unsigned long long*)v2) = v31;
    // LINE: 14
    v36 = *((int*)v0);
    if(v36 == 0) goto l14;
    v35 = 0ll;
    goto l15;
    l14: (void)noop;
    v37 = *((unsigned long long*)v2);
    v35 = v37;
    l15: (void)noop;
    *((unsigned long long*)v2) = v35;
    // LINE: 16
    v39 = *((unsigned long long*)v2);
    v38 = (int)v39;
    return v38;
}
int main(int argc, char **args) { return entry(); }