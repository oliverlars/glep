unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v6;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v5;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v12;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v13;
    unsigned long long v17;
    unsigned long long v20;
    unsigned long long v21;
    unsigned long long v22;
    unsigned long long v19;
    int v23;
    int v18;
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
    v6 = v0;
    v7 = (unsigned long long)1ll;
    v8 = v7 * 4llu;
    v5 = v6 + v8;
    v9 = v5;
    v10 = (unsigned long long)v9;
    *((unsigned long long*)v2) = v10;
    // LINE: 8
    v12 = (unsigned long long)1ll;
    v14 = *((unsigned long long*)v2);
    v15 = v12 * 4llu;
    v13 = v14 - v15;
    *((unsigned long long*)v2) = v13;
    // LINE: 9
    v17 = *((unsigned long long*)v2);
    *((int*)v17) = 123ll;
    // LINE: 11
    v20 = v0;
    v21 = (unsigned long long)0ll;
    v22 = v21 * 4llu;
    v19 = v20 + v22;
    v23 = *((int*)v19);
    v18 = v23 != 123ll;
    if(v18 == 0) goto l0;
    // LINE: 12
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 13
    return 0ll;
}
int main(int argc, char **args) { return entry(); }