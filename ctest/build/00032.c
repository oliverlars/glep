unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v7;
    unsigned long long v4;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v8;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v16;
    unsigned long long v13;
    unsigned long long v17;
    unsigned long long v18;
    unsigned long long v21;
    unsigned long long v22;
    int v23;
    int v19;
    unsigned long long v26;
    unsigned long long v27;
    int v28;
    int v24;
    unsigned long long v31;
    unsigned long long v32;
    unsigned long long v33;
    unsigned long long v30;
    unsigned long long v34;
    unsigned long long v35;
    unsigned long long v38;
    unsigned long long v39;
    int v40;
    int v36;
    unsigned long long v43;
    unsigned long long v44;
    int v45;
    int v41;
    unsigned long long v48;
    unsigned long long v49;
    unsigned long long v50;
    unsigned long long v47;
    unsigned long long v51;
    unsigned long long v52;
    unsigned long long v55;
    unsigned long long v56;
    int v57;
    int v53;
    unsigned long long v60;
    unsigned long long v61;
    unsigned long long v62;
    unsigned long long v59;
    unsigned long long v63;
    unsigned long long v64;
    unsigned long long v67;
    unsigned long long v68;
    int v69;
    int v65;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 7
    v5 = v0;
    v6 = (unsigned long long)0ll;
    v7 = v6 * 4llu;
    v4 = v5 + v7;
    *((int*)v4) = 2ll;
    // LINE: 8
    v9 = v0;
    v10 = (unsigned long long)1ll;
    v11 = v10 * 4llu;
    v8 = v9 + v11;
    *((int*)v8) = 3ll;
    // LINE: 9
    v14 = v0;
    v15 = (unsigned long long)0ll;
    v16 = v15 * 4llu;
    v13 = v14 + v16;
    v17 = v13;
    v18 = (unsigned long long)v17;
    *((unsigned long long*)v2) = v18;
    // LINE: 10
    v21 = *((unsigned long long*)v2);
    v22 = v21 + 4ll;
    *((unsigned long long*)v2) = v22;
    v23 = *((int*)v21);
    v19 = v23 != 2ll;
    if(v19 == 0) goto l0;
    // LINE: 11
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 12
    v26 = *((unsigned long long*)v2);
    v27 = v26 + 4ll;
    *((unsigned long long*)v2) = v27;
    v28 = *((int*)v26);
    v24 = v28 != 3ll;
    if(v24 == 0) goto l2;
    // LINE: 13
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 15
    v31 = v0;
    v32 = (unsigned long long)1ll;
    v33 = v32 * 4llu;
    v30 = v31 + v33;
    v34 = v30;
    v35 = (unsigned long long)v34;
    *((unsigned long long*)v2) = v35;
    // LINE: 16
    v38 = *((unsigned long long*)v2);
    v39 = v38 - 4ll;
    *((unsigned long long*)v2) = v39;
    v40 = *((int*)v38);
    v36 = v40 != 3ll;
    if(v36 == 0) goto l4;
    // LINE: 17
    return 1ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 18
    v43 = *((unsigned long long*)v2);
    v44 = v43 - 4ll;
    *((unsigned long long*)v2) = v44;
    v45 = *((int*)v43);
    v41 = v45 != 2ll;
    if(v41 == 0) goto l6;
    // LINE: 19
    return 2ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 21
    v48 = v0;
    v49 = (unsigned long long)0ll;
    v50 = v49 * 4llu;
    v47 = v48 + v50;
    v51 = v47;
    v52 = (unsigned long long)v51;
    *((unsigned long long*)v2) = v52;
    // LINE: 22
    v55 = *((unsigned long long*)v2);
    v56 = v55 + 4ll;
    *((unsigned long long*)v2) = v56;
    v57 = *((int*)v56);
    v53 = v57 != 3ll;
    if(v53 == 0) goto l8;
    // LINE: 23
    return 1ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 25
    v60 = v0;
    v61 = (unsigned long long)1ll;
    v62 = v61 * 4llu;
    v59 = v60 + v62;
    v63 = v59;
    v64 = (unsigned long long)v63;
    *((unsigned long long*)v2) = v64;
    // LINE: 26
    v67 = *((unsigned long long*)v2);
    v68 = v67 - 4ll;
    *((unsigned long long*)v2) = v68;
    v69 = *((int*)v68);
    v65 = v69 != 2ll;
    if(v65 == 0) goto l10;
    // LINE: 27
    return 1ll;
    goto l11;
    l10: (void)noop;
    l11: (void)noop;
    // LINE: 29
    return 0ll;
}
int main(int argc, char **args) { return entry(); }