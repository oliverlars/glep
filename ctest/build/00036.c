unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v5;
    int v4;
    int v8;
    int v7;
    int v10;
    int v9;
    int v13;
    int v12;
    int v15;
    int v14;
    int v18;
    int v17;
    int v20;
    int v19;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 0ll;
    // LINE: 7
    v5 = *((int*)v0);
    v4 = v5 + 2ll;
    *((int*)v0) = v4;
    // LINE: 8
    v8 = *((int*)v0);
    v7 = v8 + 2ll;
    *((int*)v0) = v7;
    // LINE: 9
    v10 = *((int*)v0);
    v9 = v10 != 4ll;
    if(v9 == 0) goto l0;
    // LINE: 10
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 11
    v13 = *((int*)v0);
    v12 = v13 - 1ll;
    *((int*)v0) = v12;
    // LINE: 12
    v15 = *((int*)v0);
    v14 = v15 != 3ll;
    if(v14 == 0) goto l2;
    // LINE: 13
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 14
    v18 = *((int*)v0);
    v17 = v18 * 2ll;
    *((int*)v0) = v17;
    // LINE: 15
    v20 = *((int*)v0);
    v19 = v20 != 6ll;
    if(v19 == 0) goto l4;
    // LINE: 16
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 18
    return 0ll;
}
int main(int argc, char **args) { return entry(); }