unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    unsigned long long v10;
    int v12;
    unsigned long long v13;
    int v15;
    int v9;
    int v8;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v4[8] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    v2 = v0 + 0llu;
    *((int*)v2) = 1ll;
    // LINE: 7
    // LINE: 7
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 8
    v6 = v4 + 4llu;
    *((int*)v6) = 1ll;
    // LINE: 9
    v10 = v0 + 0llu;
    v12 = *((int*)v10);
    v13 = v4 + 4llu;
    v15 = *((int*)v13);
    v9 = v12 - v15;
    v8 = v9 != 0ll;
    if(v8 == 0) goto l0;
    // LINE: 10
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 12
    return 0ll;
}
int main(int argc, char **args) { return entry(); }