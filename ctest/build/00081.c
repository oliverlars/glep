unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    long long v3;
    long long v6;
    long long v7;
    long long v5;
    long long v9;
    long long v10;
    int v8;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    v3 = (long long)0ll;
    *((long long*)v0) = v3;
    // LINE: 7
    v6 = *((long long*)v0);
    v7 = (long long)1ll;
    v5 = v6 + v7;
    *((long long*)v0) = v5;
    // LINE: 8
    v9 = *((long long*)v0);
    v10 = (long long)1ll;
    v8 = v9 != v10;
    if(v8 == 0) goto l0;
    // LINE: 9
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 10
    return 0ll;
}
int main(int argc, char **args) { return entry(); }