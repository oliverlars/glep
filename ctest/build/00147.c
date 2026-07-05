__attribute__((aligned(4))) struct { 

    char b0[12];

}_g0 = {
.b0 = {
0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, },
};
void *arr = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v2;
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v1;
    int v6;
    int v0;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v12;
    unsigned long long v8;
    int v13;
    int v7;
    unsigned long long v16;
    unsigned long long v17;
    unsigned long long v18;
    unsigned long long v19;
    unsigned long long v15;
    int v20;
    int v14;
    // LINE: 6
    // LINE: 6
    v2 = (unsigned long long)arr;
    v3 = v2;
    v4 = (unsigned long long)0ll;
    v5 = v4 * 4llu;
    v1 = v3 + v5;
    v6 = *((int*)v1);
    v0 = v6 != 0ll;
    if(v0 == 0) goto l0;
    // LINE: 7
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 8
    v9 = (unsigned long long)arr;
    v10 = v9;
    v11 = (unsigned long long)1ll;
    v12 = v11 * 4llu;
    v8 = v10 + v12;
    v13 = *((int*)v8);
    v7 = v13 != 1ll;
    if(v7 == 0) goto l2;
    // LINE: 9
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 10
    v16 = (unsigned long long)arr;
    v17 = v16;
    v18 = (unsigned long long)2ll;
    v19 = v18 * 4llu;
    v15 = v17 + v19;
    v20 = *((int*)v15);
    v14 = v20 != 2ll;
    if(v14 == 0) goto l4;
    // LINE: 11
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 12
    return 0ll;
}
int main(int argc, char **args) { return entry(); }