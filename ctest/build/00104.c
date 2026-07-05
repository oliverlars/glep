unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    long long v6;
    int v8;
    int v9;
    int v11;
    unsigned int v12;
    int v10;
    long long v14;
    long long v15;
    int v17;
    unsigned long long v18;
    int v16;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 6
    // LINE: 6
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 7
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 9
    *((int*)v0) = 0ll;
    // LINE: 10
    v6 = (long long)0ll;
    *((long long*)v2) = v6;
    // LINE: 12
    v8 = *((int*)v0);
    *((int*)v0) = v9;
    // LINE: 13
    v11 = *((int*)v0);
    v12 = (unsigned int)v11;
    v10 = v12 != 4294967295llu;
    if(v10 == 0) goto l0;
    // LINE: 14
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 16
    v14 = *((long long*)v2);
    *((long long*)v2) = v15;
    // LINE: 17
    v17 = *((int*)v0);
    v18 = (unsigned long long)v17;
    v16 = v18 != 18446744073709551615llu;
    if(v16 == 0) goto l2;
    // LINE: 18
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 21
    return 0ll;
}
int main(int argc, char **args) { return entry(); }