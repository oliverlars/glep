__attribute__((aligned(4))) struct { 

    char b0[12];

}_g0 = {
.b0 = {
5, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, },
};
void *a = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v2;
    unsigned long long v1;
    int v0;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v4;
    int v9;
    int v3;
    unsigned long long v12;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v11;
    int v16;
    int v10;
    unsigned long long v19;
    unsigned long long v20;
    unsigned long long v21;
    unsigned long long v22;
    unsigned long long v18;
    int v23;
    int v17;
    unsigned long long v26;
    unsigned long long v27;
    unsigned long long v28;
    unsigned long long v29;
    unsigned long long v25;
    int v30;
    int v24;
    // LINE: 6
    // LINE: 6
    v2 = (unsigned long long)4ll;
    v1 = v2 * 4llu;
    v0 = 12llu != v1;
    if(v0 == 0) goto l0;
    // LINE: 7
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 9
    v5 = (unsigned long long)a;
    v6 = v5;
    v7 = (unsigned long long)0ll;
    v8 = v7 * 4llu;
    v4 = v6 + v8;
    v9 = *((int*)v4);
    v3 = v9 != 5ll;
    if(v3 == 0) goto l2;
    // LINE: 10
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 11
    v12 = (unsigned long long)a;
    v13 = v12;
    v14 = (unsigned long long)1ll;
    v15 = v14 * 4llu;
    v11 = v13 + v15;
    v16 = *((int*)v11);
    v10 = v16 != 0ll;
    if(v10 == 0) goto l4;
    // LINE: 12
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 13
    v19 = (unsigned long long)a;
    v20 = v19;
    v21 = (unsigned long long)2ll;
    v22 = v21 * 4llu;
    v18 = v20 + v22;
    v23 = *((int*)v18);
    v17 = v23 != 2ll;
    if(v17 == 0) goto l6;
    // LINE: 14
    return 4ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 15
    v26 = (unsigned long long)a;
    v27 = v26;
    v28 = (unsigned long long)3ll;
    v29 = v28 * 4llu;
    v25 = v27 + v29;
    v30 = *((int*)v25);
    v24 = v30 != 3ll;
    if(v24 == 0) goto l8;
    // LINE: 16
    return 5ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 18
    return 0ll;
}
int main(int argc, char **args) { return entry(); }