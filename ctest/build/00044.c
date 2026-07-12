__attribute__((aligned(4))) struct { 

    char b0[8];

}_g0 = {
.b0 = {
},
};
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v4;
    unsigned long long v7;
    int v9;
    int v6;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 10
    // LINE: 10
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 11
    // LINE: 11
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 12
    v4 = v0 + 0llu;
    *((int*)v4) = 2ll;
    // LINE: 13
    v7 = v0 + 0llu;
    v9 = *((int*)v7);
    v6 = v9 != 2ll;
    if(v6 == 0) goto l0;
    // LINE: 14
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 15
    return 0ll;
}
int main(int argc, char **args) { return entry(); }