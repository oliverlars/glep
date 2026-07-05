unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    int v4;
    char alloca_v0[16] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[16] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 16ll    );
    v3 = memset(v2, 0ll, 16ll    );
    // LINE: 6
    v4 = 16llu != 16llu;
    if(v4 == 0) goto l0;
    // LINE: 7
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 8
    return 0ll;
}
int main(int argc, char **args) { return entry(); }