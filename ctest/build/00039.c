unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v11;
    unsigned long long v10;
    int v12;
    int v9;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 7
    *((int*)v2) = 2ll;
    // LINE: 8
    v7 = v2;
    v8 = (unsigned long long)v7;
    *((unsigned long long*)v0) = v8;
    // LINE: 10
    v11 = *((unsigned long long*)v0);
    v10 = (unsigned long long)v11;
    v12 = *((int*)v10);
    v9 = v12 != 2ll;
    if(v9 == 0) goto l0;
    // LINE: 11
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 12
    return 0ll;
}
int main(int argc, char **args) { return entry(); }