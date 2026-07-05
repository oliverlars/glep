unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v4;
    int v7;
    int v6;
    int v8;
    int v10;
    int v13;
    int v12;
    int v14;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 1ll;
    // LINE: 7
    // LINE: 7
    *((int*)v0) = 10ll;
    l0: (void)noop;
    v4 = *((int*)v0);
    if(v4 == 0) goto l1;
    // LINE: 8
    l2: (void)noop;
    v7 = *((int*)v0);
    v6 = v7 - 1ll;
    *((int*)v0) = v6;
    goto l0;
    l1: (void)noop;
    // LINE: 9
    v8 = *((int*)v0);
    if(v8 == 0) goto l3;
    // LINE: 10
    return 1ll;
    goto l4;
    l3: (void)noop;
    l4: (void)noop;
    // LINE: 11
    *((int*)v0) = 10ll;
    // LINE: 12
    // LINE: 12
    l5: (void)noop;
    v10 = *((int*)v0);
    if(v10 == 0) goto l6;
    // LINE: 13
    v13 = *((int*)v0);
    v12 = v13 - 1ll;
    *((int*)v0) = v12;
    l7: (void)noop;
    goto l5;
    l6: (void)noop;
    // LINE: 14
    v14 = *((int*)v0);
    return v14;
}
int main(int argc, char **args) { return entry(); }