__attribute__((aligned(1))) struct { 

    char b0[7];

}_g0 = {
.b0 = {
97, 98, 99, 100, 101, 102, 0, },
};
void *str0 = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v6;
    char v10;
    int v11;
    int v5;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v16;
    unsigned long long v13;
    char v17;
    int v18;
    int v12;
    unsigned long long v21;
    unsigned long long v22;
    unsigned long long v23;
    unsigned long long v20;
    char v24;
    int v25;
    int v19;
    unsigned long long v28;
    unsigned long long v29;
    unsigned long long v30;
    unsigned long long v27;
    char v31;
    int v32;
    int v26;
    unsigned long long v35;
    unsigned long long v36;
    unsigned long long v37;
    unsigned long long v34;
    char v38;
    int v39;
    int v33;
    unsigned long long v42;
    unsigned long long v43;
    unsigned long long v44;
    unsigned long long v41;
    char v45;
    int v46;
    int v40;
    unsigned long long v49;
    unsigned long long v50;
    unsigned long long v51;
    unsigned long long v48;
    char v52;
    int v53;
    int v47;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 3
    // LINE: 3
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    v3 = (unsigned long long)str0;
    v4 = (unsigned long long)v3;
    *((unsigned long long*)v0) = v4;
    // LINE: 6
    v7 = *((unsigned long long*)v0);
    v8 = (unsigned long long)0ll;
    v9 = v8 * 1llu;
    v6 = v7 + v9;
    v10 = *((char*)v6);
    v11 = (int)v10;
    v5 = v11 != 97ll;
    if(v5 == 0) goto l0;
    // LINE: 6
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 7
    v14 = *((unsigned long long*)v0);
    v15 = (unsigned long long)1ll;
    v16 = v15 * 1llu;
    v13 = v14 + v16;
    v17 = *((char*)v13);
    v18 = (int)v17;
    v12 = v18 != 98ll;
    if(v12 == 0) goto l2;
    // LINE: 7
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 8
    v21 = *((unsigned long long*)v0);
    v22 = (unsigned long long)2ll;
    v23 = v22 * 1llu;
    v20 = v21 + v23;
    v24 = *((char*)v20);
    v25 = (int)v24;
    v19 = v25 != 99ll;
    if(v19 == 0) goto l4;
    // LINE: 8
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 9
    v28 = *((unsigned long long*)v0);
    v29 = (unsigned long long)3ll;
    v30 = v29 * 1llu;
    v27 = v28 + v30;
    v31 = *((char*)v27);
    v32 = (int)v31;
    v26 = v32 != 100ll;
    if(v26 == 0) goto l6;
    // LINE: 9
    return 4ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 10
    v35 = *((unsigned long long*)v0);
    v36 = (unsigned long long)4ll;
    v37 = v36 * 1llu;
    v34 = v35 + v37;
    v38 = *((char*)v34);
    v39 = (int)v38;
    v33 = v39 != 101ll;
    if(v33 == 0) goto l8;
    // LINE: 10
    return 5ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 11
    v42 = *((unsigned long long*)v0);
    v43 = (unsigned long long)5ll;
    v44 = v43 * 1llu;
    v41 = v42 + v44;
    v45 = *((char*)v41);
    v46 = (int)v45;
    v40 = v46 != 102ll;
    if(v40 == 0) goto l10;
    // LINE: 11
    return 6ll;
    goto l11;
    l10: (void)noop;
    l11: (void)noop;
    // LINE: 12
    v49 = *((unsigned long long*)v0);
    v50 = (unsigned long long)6ll;
    v51 = v50 * 1llu;
    v48 = v49 + v51;
    v52 = *((char*)v48);
    v53 = (int)v52;
    v47 = v53 != 0ll;
    if(v47 == 0) goto l12;
    // LINE: 12
    return 7ll;
    goto l13;
    l12: (void)noop;
    l13: (void)noop;
    // LINE: 14
    return 0ll;
}
int main(int argc, char **args) { return entry(); }