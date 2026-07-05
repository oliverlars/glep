__attribute__((aligned(4))) struct { 

    char b0[12];

}_g0 = {
.b0 = {
1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, },
};
void *a = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v2;
    unsigned long long v1;
    int v7;
    int v0;
    unsigned long long v12;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v11;
    unsigned long long v10;
    unsigned long long v16;
    unsigned long long v17;
    unsigned long long v9;
    int v18;
    int v8;
    unsigned long long v23;
    unsigned long long v24;
    unsigned long long v25;
    unsigned long long v26;
    unsigned long long v22;
    unsigned long long v21;
    unsigned long long v27;
    unsigned long long v28;
    unsigned long long v20;
    int v29;
    int v19;
    // LINE: 11
    // LINE: 11
    v3 = (unsigned long long)a;
    v4 = v3;
    v5 = (unsigned long long)0ll;
    v6 = v5 * 12llu;
    v2 = v4 + v6;
    v1 = v2 + 0llu;
    v7 = *((int*)v1);
    v0 = v7 != 1ll;
    if(v0 == 0) goto l0;
    // LINE: 12
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 13
    v12 = (unsigned long long)a;
    v13 = v12;
    v14 = (unsigned long long)0ll;
    v15 = v14 * 12llu;
    v11 = v13 + v15;
    v10 = v11 + 4llu;
    v16 = (unsigned long long)0ll;
    v17 = v16 * 4llu;
    v9 = v10 + v17;
    v18 = *((int*)v9);
    v8 = v18 != 2ll;
    if(v8 == 0) goto l2;
    // LINE: 14
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 15
    v23 = (unsigned long long)a;
    v24 = v23;
    v25 = (unsigned long long)0ll;
    v26 = v25 * 12llu;
    v22 = v24 + v26;
    v21 = v22 + 4llu;
    v27 = (unsigned long long)1ll;
    v28 = v27 * 4llu;
    v20 = v21 + v28;
    v29 = *((int*)v20);
    v19 = v29 != 3ll;
    if(v19 == 0) goto l4;
    // LINE: 16
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 18
    return 0ll;
}
int main(int argc, char **args) { return entry(); }