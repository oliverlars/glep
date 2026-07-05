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
    unsigned long long v8;
    int v9;
    unsigned long long v10;
    int v11;
    int v14;
    int v13;
    int v16;
    unsigned long long v17;
    unsigned long long v18;
    unsigned long long v19;
    unsigned long long v15;
    int v20;
    short v21;
    int v23;
    unsigned long long v24;
    unsigned long long v25;
    unsigned long long v26;
    unsigned long long v22;
    short v27;
    int v29;
    int v30;
    unsigned long long v32;
    unsigned long long v33;
    unsigned long long v35;
    unsigned long long v36;
    int v41;
    int v40;
    int v39;
    int v43;
    int v42;
    int v44;
    unsigned long long v47;
    unsigned long long v48;
    unsigned long long v50;
    unsigned long long v51;
    short v52;
    int v55;
    int v56;
    int v53;
    int v59;
    int v58;
    int v62;
    unsigned long long v63;
    unsigned long long v64;
    unsigned long long v65;
    unsigned long long v61;
    short v66;
    int v68;
    unsigned long long v69;
    unsigned long long v70;
    unsigned long long v71;
    unsigned long long v67;
    short v72;
    int v60;
    int v74;
    int v75;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[8] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    char alloca_v6[8] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    char alloca_v8[78] __attribute__((aligned(16)));
    v8 = (unsigned long long)alloca_v8;
    char alloca_v10[78] __attribute__((aligned(16)));
    v10 = (unsigned long long)alloca_v10;
    // LINE: 10
    // LINE: 10
    v1 = memset(v0, 0ll, 8ll    );
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 11
    v5 = memset(v4, 0ll, 8ll    );
    v7 = memset(v6, 0ll, 8ll    );
    // LINE: 12
    v9 = memset(v8, 0ll, 80ll    );
    v11 = memset(v10, 0ll, 80ll    );
    // LINE: 14
    // LINE: 14
    *((int*)v2) = 0ll;
    l0: (void)noop;
    v14 = *((int*)v2);
    v13 = v14 < 39ll;
    if(v13 == 0) goto l1;
    // LINE: 15
    // LINE: 15
    v16 = *((int*)v2);
    v17 = v8;
    v18 = (unsigned long long)v16;
    v19 = v18 * 2llu;
    v15 = v17 + v19;
    v20 = *((int*)v2);
    v21 = (short)v20;
    *((short*)v15) = v21;
    // LINE: 16
    v23 = *((int*)v2);
    v24 = v10;
    v25 = (unsigned long long)v23;
    v26 = v25 * 2llu;
    v22 = v24 + v26;
    v27 = (short)0ll;
    *((short*)v22) = v27;
    l2: (void)noop;
    v29 = *((int*)v2);
    v30 = v29 + 1ll;
    *((int*)v2) = v30;
    goto l0;
    l1: (void)noop;
    // LINE: 18
    v32 = v8;
    v33 = (unsigned long long)v32;
    *((unsigned long long*)v4) = v33;
    // LINE: 19
    v35 = v10;
    v36 = (unsigned long long)v35;
    *((unsigned long long*)v6) = v36;
    // LINE: 20
    *((int*)v0) = 39ll;
    // LINE: 21
    v41 = *((int*)v0);
    v40 = v41 + 7ll;
    v39 = v40 / 8ll;
    *((int*)v2) = v39;
    // LINE: 22
    v43 = *((int*)v0);
    v42 = v43 % 8ll;
    v44 = v42 == 0ll;
    if(v44 != 0) goto l4;
    goto l3;
    l4: (void)noop;
    // LINE: 23
    l5: (void)noop;
    // LINE: 23
    // LINE: 23
    v47 = *((unsigned long long*)v6);
    v48 = v47 + 2ll;
    *((unsigned long long*)v6) = v48;
    v50 = *((unsigned long long*)v4);
    v51 = v50 + 2ll;
    *((unsigned long long*)v4) = v51;
    v52 = *((short*)v50);
    *((short*)v47) = v52;
    // LINE: 24
    // LINE: 25
    // LINE: 26
    // LINE: 27
    // LINE: 28
    // LINE: 29
    // LINE: 30
    l7: (void)noop;
    v55 = *((int*)v2);
    v56 = v55 - 1ll;
    *((int*)v2) = v56;
    v53 = 0ll < v56;
    if(v53 != 0) goto l5;
    l6: (void)noop;
    l3: (void)noop;
    // LINE: 33
    // LINE: 33
    *((int*)v2) = 0ll;
    l8: (void)noop;
    v59 = *((int*)v2);
    v58 = v59 < 39ll;
    if(v58 == 0) goto l9;
    // LINE: 34
    v62 = *((int*)v2);
    v63 = v8;
    v64 = (unsigned long long)v62;
    v65 = v64 * 2llu;
    v61 = v63 + v65;
    v66 = *((short*)v61);
    v68 = *((int*)v2);
    v69 = v10;
    v70 = (unsigned long long)v68;
    v71 = v70 * 2llu;
    v67 = v69 + v71;
    v72 = *((short*)v67);
    v60 = v66 != v72;
    if(v60 == 0) goto l11;
    // LINE: 35
    return 1ll;
    goto l12;
    l11: (void)noop;
    l12: (void)noop;
    l10: (void)noop;
    v74 = *((int*)v2);
    v75 = v74 + 1ll;
    *((int*)v2) = v75;
    goto l8;
    l9: (void)noop;
    // LINE: 36
    return 0ll;
}
int main(int argc, char **args) { return entry(); }