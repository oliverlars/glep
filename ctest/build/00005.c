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
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v15;
    int v16;
    unsigned long long v17;
    unsigned long long v18;
    int v19;
    unsigned long long v21;
    unsigned long long v22;
    int v23;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[8] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 6
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 8
    *((int*)v0) = 0ll;
    // LINE: 9
    v9 = v0;
    v10 = (unsigned long long)v9;
    *((unsigned long long*)v2) = v10;
    // LINE: 10
    v13 = v2;
    v14 = (unsigned long long)v13;
    *((unsigned long long*)v4) = v14;
    // LINE: 12
    v15 = *((unsigned long long*)v2);
    v16 = *((int*)v15);
    if(v16 == 0) goto l0;
    // LINE: 13
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 14
    v17 = *((unsigned long long*)v4);
    v18 = *((unsigned long long*)v17);
    v19 = *((int*)v18);
    if(v19 == 0) goto l2;
    // LINE: 15
    return 1ll;
    goto l3;
    l2: (void)noop;
    // LINE: 17
    v21 = *((unsigned long long*)v4);
    v22 = *((unsigned long long*)v21);
    *((int*)v22) = 1ll;
    l3: (void)noop;
    // LINE: 19
    v23 = *((int*)v0);
    if(v23 == 0) goto l4;
    // LINE: 20
    return 0ll;
    goto l5;
    l4: (void)noop;
    // LINE: 22
    return 1ll;
    l5: (void)noop;
}
int main(int argc, char **args) { return entry(); }