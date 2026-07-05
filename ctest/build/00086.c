unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    short v3;
    short v6;
    int v7;
    int v5;
    short v8;
    short v10;
    int v11;
    int v9;
    char alloca_v0[2] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    v3 = (short)0ll;
    *((short*)v0) = v3;
    // LINE: 7
    v6 = *((short*)v0);
    v7 = (int)v6;
    v5 = v7 + 1ll;
    v8 = (short)v5;
    *((short*)v0) = v8;
    // LINE: 8
    v10 = *((short*)v0);
    v11 = (int)v10;
    v9 = v11 != 1ll;
    if(v9 == 0) goto l0;
    // LINE: 9
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 10
    return 0ll;
}
int main(int argc, char **args) { return entry(); }