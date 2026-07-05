unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v16;
    unsigned long long v13;
    unsigned long long v17;
    unsigned long long v18;
    unsigned long long v12;
    unsigned long long v19;
    unsigned long long v20;
    unsigned long long v23;
    unsigned long long v24;
    unsigned long long v25;
    unsigned long long v22;
    unsigned long long v26;
    unsigned long long v27;
    unsigned long long v21;
    char v28;
    unsigned long long v30;
    unsigned long long v31;
    unsigned long long v32;
    unsigned long long v29;
    unsigned long long v36;
    unsigned long long v37;
    unsigned long long v38;
    unsigned long long v35;
    unsigned long long v39;
    unsigned long long v40;
    unsigned long long v34;
    char v41;
    int v42;
    int v33;
    unsigned long long v46;
    unsigned long long v47;
    unsigned long long v48;
    unsigned long long v45;
    unsigned long long v49;
    unsigned long long v50;
    unsigned long long v44;
    char v51;
    int v52;
    int v43;
    unsigned long long v54;
    char v55;
    int v56;
    int v53;
    unsigned long long v58;
    int v59;
    int v57;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[8] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    char alloca_v6[16] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    v3 = memset(v2, 0ll, 8ll    );
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 5
    v7 = memset(v6, 0ll, 16ll    );
    // LINE: 7
    v9 = v0;
    v10 = (unsigned long long)v9;
    *((unsigned long long*)v2) = v10;
    // LINE: 8
    v14 = v0;
    v15 = (unsigned long long)1ll;
    v16 = v15 * 4llu;
    v13 = v14 + v16;
    v17 = (unsigned long long)3ll;
    v18 = v17 * 1llu;
    v12 = v13 + v18;
    v19 = v12;
    v20 = (unsigned long long)v19;
    *((unsigned long long*)v4) = v20;
    // LINE: 9
    v23 = v0;
    v24 = (unsigned long long)1ll;
    v25 = v24 * 4llu;
    v22 = v23 + v25;
    v26 = (unsigned long long)3ll;
    v27 = v26 * 1llu;
    v21 = v22 + v27;
    v28 = (char)2ll;
    *((char*)v21) = v28;
    // LINE: 10
    v30 = v6;
    v31 = (unsigned long long)0ll;
    v32 = v31 * 4llu;
    v29 = v30 + v32;
    *((int*)v29) = 2ll;
    // LINE: 12
    v36 = v0;
    v37 = (unsigned long long)1ll;
    v38 = v37 * 4llu;
    v35 = v36 + v38;
    v39 = (unsigned long long)3ll;
    v40 = v39 * 1llu;
    v34 = v35 + v40;
    v41 = *((char*)v34);
    v42 = (int)v41;
    v33 = v42 != 2ll;
    if(v33 == 0) goto l0;
    // LINE: 13
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 14
    v46 = *((unsigned long long*)v2);
    v47 = (unsigned long long)1ll;
    v48 = v47 * 4llu;
    v45 = v46 + v48;
    v49 = (unsigned long long)3ll;
    v50 = v49 * 1llu;
    v44 = v45 + v50;
    v51 = *((char*)v44);
    v52 = (int)v51;
    v43 = v52 != 2ll;
    if(v43 == 0) goto l2;
    // LINE: 15
    return 1ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 16
    v54 = *((unsigned long long*)v4);
    v55 = *((char*)v54);
    v56 = (int)v55;
    v53 = v56 != 2ll;
    if(v53 == 0) goto l4;
    // LINE: 17
    return 1ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 18
    v58 = v6;
    v59 = *((int*)v58);
    v57 = v59 != 2ll;
    if(v57 == 0) goto l6;
    // LINE: 19
    return 1ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 21
    return 0ll;
}
int main(int argc, char **args) { return entry(); }