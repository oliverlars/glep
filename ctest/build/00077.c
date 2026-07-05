unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int foo(unsigned long long v2) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v5;
    int v6;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v7;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v12;
    int v16;
    int v11;
    unsigned long long v18;
    unsigned long long v19;
    unsigned long long v22;
    unsigned long long v23;
    unsigned long long v24;
    unsigned long long v21;
    int v25;
    int v20;
    unsigned long long v27;
    unsigned long long v28;
    unsigned long long v31;
    unsigned long long v32;
    unsigned long long v33;
    unsigned long long v30;
    int v34;
    int v29;
    int v35;
    int v36;
    char alloca_v0[400] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[400] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v5[8] __attribute__((aligned(16)));
    v5 = (unsigned long long)alloca_v5;
    v1 = memset(v0, 0ll, 400ll    );
    *((unsigned long long*)v0) = v2;
    // LINE: 4
    // LINE: 4
    v4 = memset(v3, 0ll, 400ll    );
    // LINE: 5
    v6 = memset(v5, 0ll, 8ll    );
    // LINE: 7
    v8 = v3;
    v9 = (unsigned long long)0ll;
    v10 = v9 * 4llu;
    v7 = v8 + v10;
    *((int*)v7) = 2000ll;
    // LINE: 9
    v13 = v0;
    v14 = (unsigned long long)0ll;
    v15 = v14 * 4llu;
    v12 = v13 + v15;
    v16 = *((int*)v12);
    v11 = v16 != 1000ll;
    if(v11 == 0) goto l0;
    // LINE: 11
    // LINE: 11
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 14
    v18 = v0;
    v19 = (unsigned long long)v18;
    *((unsigned long long*)v5) = v19;
    // LINE: 16
    v22 = *((unsigned long long*)v5);
    v23 = (unsigned long long)0ll;
    v24 = v23 * 4llu;
    v21 = v22 + v24;
    v25 = *((int*)v21);
    v20 = v25 != 1000ll;
    if(v20 == 0) goto l2;
    // LINE: 18
    // LINE: 18
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 21
    v27 = v3;
    v28 = (unsigned long long)v27;
    *((unsigned long long*)v5) = v28;
    // LINE: 23
    v31 = *((unsigned long long*)v5);
    v32 = (unsigned long long)0ll;
    v33 = v32 * 4llu;
    v30 = v31 + v33;
    v34 = *((int*)v30);
    v29 = v34 != 2000ll;
    if(v29 == 0) goto l4;
    // LINE: 25
    // LINE: 25
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 28
    v35 = 400llu != 8llu;
    if(v35 == 0) goto l6;
    // LINE: 30
    // LINE: 30
    return 4ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 33
    v36 = 400llu <= 400llu;
    if(v36 == 0) goto l8;
    // LINE: 35
    // LINE: 35
    return 5ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 38
    return 0ll;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v2;
    unsigned long long v6;
    int v7;
    char alloca_v0[400] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 44
    // LINE: 44
    v1 = memset(v0, 0ll, 400ll    );
    // LINE: 45
    v3 = v0;
    v4 = (unsigned long long)0ll;
    v5 = v4 * 4llu;
    v2 = v3 + v5;
    *((int*)v2) = 1000ll;
    // LINE: 47
    v6 = v0;
    v7 = foo(v6    );
    return v7;
}
int main(int argc, char **args) { return entry(); }