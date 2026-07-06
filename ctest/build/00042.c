unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v4;
    unsigned long long v8;
    int v10;
    int v7;
    int v6;
    unsigned long long v12;
    int v14;
    int v11;
    char alloca_v0[0] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 0ll    );
    // LINE: 5
    v2 = v0 + 0llu;
    *((int*)v2) = 1ll;
    // LINE: 6
    v4 = v0 + 0llu;
    *((int*)v4) = 3ll;
    // LINE: 8
    v8 = v0 + 0llu;
    v10 = *((int*)v8);
    v7 = v10 != 3ll;
    v6 = v7 != 0ll;
    if(v7 != 0) goto l2;
    v12 = v0 + 0llu;
    v14 = *((int*)v12);
    v11 = v14 != 3ll;
    v6 = v11 != 0ll;
    l2: (void)noop;
    if(v6 == 0) goto l0;
    // LINE: 9
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 10
    return 0ll;
}
int main(int argc, char **args) { return entry(); }