unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v4;
    int v3;
    int v5;
    int v6;
    int v8;
    int v9;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    // LINE: 6
    *((int*)v0) = 0ll;
    l0: (void)noop;
    v4 = *((int*)v0);
    v3 = v4 < 10ll;
    if(v3 == 0) goto l1;
    // LINE: 7
    v5 = *((int*)v0);
    v6 = v5 == 0ll;
    if(v6 == 0) goto l3;
    // LINE: 8
    goto l2;
    goto l4;
    l3: (void)noop;
    l4: (void)noop;
    l2: (void)noop;
    v8 = *((int*)v0);
    v9 = v8 + 1ll;
    *((int*)v0) = v9;
    goto l0;
    l1: (void)noop;
    // LINE: 10
    return 0ll;
}
int main(int argc, char **args) { return entry(); }