unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v5;
    unsigned long long v4;
    unsigned long long v8;
    unsigned long long v7;
    unsigned long long v13;
    int v15;
    unsigned long long v17;
    unsigned long long v16;
    int v19;
    int v12;
    unsigned long long v21;
    unsigned long long v20;
    int v23;
    int v11;
    int v10;
    char alloca_v0[12] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 11
    // LINE: 11
    v1 = memset(v0, 0ll, 16ll    );
    // LINE: 12
    v2 = v0 + 0llu;
    *((int*)v2) = 1ll;
    // LINE: 13
    v5 = v0 + 4llu;
    v4 = v5 + 0llu;
    *((int*)v4) = 2ll;
    // LINE: 14
    v8 = v0 + 4llu;
    v7 = v8 + 4llu;
    *((int*)v7) = 3ll;
    // LINE: 15
    v13 = v0 + 0llu;
    v15 = *((int*)v13);
    v17 = v0 + 4llu;
    v16 = v17 + 0llu;
    v19 = *((int*)v16);
    v12 = v15 + v19;
    v21 = v0 + 4llu;
    v20 = v21 + 4llu;
    v23 = *((int*)v20);
    v11 = v12 + v23;
    v10 = v11 != 6ll;
    if(v10 == 0) goto l0;
    // LINE: 16
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 17
    return 0ll;
}
int main(int argc, char **args) { return entry(); }