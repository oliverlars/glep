unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v7;
    unsigned long long v4;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v12;
    unsigned long long v9;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v17;
    unsigned long long v18;
    unsigned long long v19;
    unsigned long long v16;
    unsigned long long v21;
    int v22;
    int v20;
    unsigned long long v26;
    unsigned long long v27;
    unsigned long long v28;
    unsigned long long v25;
    unsigned long long v29;
    unsigned long long v31;
    unsigned long long v32;
    unsigned long long v33;
    unsigned long long v30;
    unsigned long long v34;
    unsigned long long v24;
    unsigned long long v35;
    int v23;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 7
    v5 = v0;
    v6 = (unsigned long long)1ll;
    v7 = v6 * 4llu;
    v4 = v5 + v7;
    *((int*)v4) = 7ll;
    // LINE: 8
    v10 = v0;
    v11 = (unsigned long long)0ll;
    v12 = v11 * 4llu;
    v9 = v10 + v12;
    v13 = v9;
    v14 = (unsigned long long)v13;
    *((unsigned long long*)v2) = v14;
    // LINE: 9
    v17 = *((unsigned long long*)v2);
    v18 = (unsigned long long)1ll;
    v19 = v18 * 4llu;
    v16 = v17 + v19;
    *((unsigned long long*)v2) = v16;
    // LINE: 11
    v21 = *((unsigned long long*)v2);
    v22 = *((int*)v21);
    v20 = v22 != 7ll;
    if(v20 == 0) goto l0;
    // LINE: 12
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 13
    v26 = v0;
    v27 = (unsigned long long)1ll;
    v28 = v27 * 4llu;
    v25 = v26 + v28;
    v29 = v25;
    v31 = v0;
    v32 = (unsigned long long)0ll;
    v33 = v32 * 4llu;
    v30 = v31 + v33;
    v34 = v30;
    v24 = v29 - v34;
    v35 = (unsigned long long)1ll;
    v23 = v24 != v35;
    if(v23 == 0) goto l2;
    // LINE: 14
    return 1ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 16
    return 0ll;
}
int main(int argc, char **args) { return entry(); }