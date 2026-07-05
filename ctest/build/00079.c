unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    int v7;
    int v6;
    int v9;
    int v8;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 6
    // LINE: 6
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 7
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 9
    *((int*)v2) = 0ll;
    // LINE: 10
    v7 = *((int*)v2);
    v6 = v7 + 1ll;
    *((int*)v0) = v6;
    // LINE: 12
    v9 = *((int*)v0);
    v8 = v9 != 1ll;
    if(v8 == 0) goto l0;
    // LINE: 13
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 15
    return 0ll;
}
int main(int argc, char **args) { return entry(); }