__attribute__((aligned(4))) struct { 

    char b0[8];

}_g0 = {
.b0 = {
},
};
__attribute__((aligned(4))) struct { 

    char b0[16];

}_g1 = {
.b0 = {
1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, },
};
void *arr = &_g1;
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
    unsigned long long v11;
    unsigned long long v12;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v10;
    unsigned long long v9;
    int v15;
    int v8;
    unsigned long long v19;
    unsigned long long v20;
    unsigned long long v21;
    unsigned long long v22;
    unsigned long long v18;
    unsigned long long v17;
    int v23;
    int v16;
    unsigned long long v27;
    unsigned long long v28;
    unsigned long long v29;
    unsigned long long v30;
    unsigned long long v26;
    unsigned long long v25;
    int v31;
    int v24;
    // LINE: 7
    // LINE: 7
    v3 = (unsigned long long)arr;
    v4 = v3;
    v5 = (unsigned long long)0ll;
    v6 = v5 * 8llu;
    v2 = v4 + v6;
    v1 = v2 + 0llu;
    v7 = *((int*)v1);
    v0 = v7 != 1ll;
    if(v0 == 0) goto l0;
    // LINE: 8
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 9
    v11 = (unsigned long long)arr;
    v12 = v11;
    v13 = (unsigned long long)0ll;
    v14 = v13 * 8llu;
    v10 = v12 + v14;
    v9 = v10 + 4llu;
    v15 = *((int*)v9);
    v8 = v15 != 2ll;
    if(v8 == 0) goto l2;
    // LINE: 10
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 11
    v19 = (unsigned long long)arr;
    v20 = v19;
    v21 = (unsigned long long)1ll;
    v22 = v21 * 8llu;
    v18 = v20 + v22;
    v17 = v18 + 0llu;
    v23 = *((int*)v17);
    v16 = v23 != 3ll;
    if(v16 == 0) goto l4;
    // LINE: 12
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 13
    v27 = (unsigned long long)arr;
    v28 = v27;
    v29 = (unsigned long long)1ll;
    v30 = v29 * 8llu;
    v26 = v28 + v30;
    v25 = v26 + 4llu;
    v31 = *((int*)v25);
    v24 = v31 != 4ll;
    if(v24 == 0) goto l6;
    // LINE: 14
    return 4ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 15
    return 0ll;
}
int main(int argc, char **args) { return entry(); }