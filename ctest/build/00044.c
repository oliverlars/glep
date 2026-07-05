unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v5;
    int v7;
    int v4;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 10
    // LINE: 10
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 11
    // LINE: 11
    // LINE: 12
    v2 = v0 + 0llu;
    *((int*)v2) = 2ll;
    // LINE: 13
    v5 = v0 + 0llu;
    v7 = *((int*)v5);
    v4 = v7 != 2ll;
    if(v4 == 0) goto l0;
    // LINE: 14
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 15
    return 0ll;
}
int main(int argc, char **args) { return entry(); }