unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v4;
    int v5;
    int v7;
    int v8;
    int v10;
    int v11;
    int v13;
    int v14;
    int v16;
    int v15;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 3ll;
    // LINE: 7
    v4 = *((int*)v0);
    v5 = v4 == 0ll;
    *((int*)v0) = v5;
    // LINE: 8
    v7 = *((int*)v0);
    v8 = v7 == 0ll;
    *((int*)v0) = v8;
    // LINE: 9
    v10 = *((int*)v0);
    *((int*)v0) = v11;
    // LINE: 10
    v13 = *((int*)v0);
    v14 = -v13;
    *((int*)v0) = v14;
    // LINE: 11
    v16 = *((int*)v0);
    v15 = v16 != 2ll;
    if(v15 == 0) goto l0;
    // LINE: 12
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 13
    return 0ll;
}
int main(int argc, char **args) { return entry(); }