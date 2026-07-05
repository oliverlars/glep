unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    long long v5;
    int v7;
    long long v8;
    long long v10;
    unsigned int v12;
    long long v13;
    long long v15;
    long long v20;
    long long v19;
    long long v21;
    long long v18;
    long long v22;
    long long v17;
    long long v28;
    long long v27;
    long long v29;
    long long v26;
    long long v25;
    long long v30;
    int v24;
    long long v31;
    unsigned int v34;
    unsigned int v35;
    int v33;
    long long v36;
    unsigned long long v38;
    int v40;
    unsigned long long v41;
    long long v43;
    unsigned long long v44;
    unsigned int v46;
    unsigned long long v47;
    long long v49;
    unsigned long long v50;
    long long v55;
    long long v54;
    long long v56;
    long long v53;
    long long v57;
    long long v52;
    unsigned long long v58;
    long long v64;
    long long v63;
    long long v65;
    long long v62;
    long long v61;
    long long v66;
    int v60;
    unsigned long long v67;
    unsigned int v70;
    unsigned int v71;
    int v69;
    unsigned long long v72;
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
    v5 = (long long)1ll;
    *((long long*)v0) = v5;
    // LINE: 8
    v7 = -1ll;
    v8 = (long long)v7;
    *((long long*)v0) = v8;
    // LINE: 9
    v10 = -1ll;
    *((long long*)v0) = v10;
    // LINE: 10
    v12 = -1llu;
    v13 = (long long)v12;
    *((long long*)v0) = v13;
    // LINE: 11
    v15 = -1ll;
    *((long long*)v0) = v15;
    // LINE: 12
    v20 = (long long)32ll;
    v19 = 1ll << v20;
    v21 = (long long)1ll;
    v18 = v19 - v21;
    v22 = (long long)3ll;
    v17 = v18 & v22;
    *((long long*)v0) = v17;
    // LINE: 13
    v28 = (long long)32ll;
    v27 = 1ll << v28;
    v29 = (long long)1ll;
    v26 = v27 - v29;
    v25 = (long long)v26;
    v30 = (long long)0ll;
    v24 = v25 < v30;
    v31 = (long long)v24;
    *((long long*)v0) = v31;
    // LINE: 14
    v34 = -1llu;
    v35 = (unsigned int)0ll;
    v33 = v34 < v35;
    v36 = (long long)v33;
    *((long long*)v0) = v36;
    // LINE: 16
    v38 = (unsigned long long)1ll;
    *((unsigned long long*)v2) = v38;
    // LINE: 17
    v40 = -1ll;
    v41 = (unsigned long long)v40;
    *((unsigned long long*)v2) = v41;
    // LINE: 18
    v43 = -1ll;
    v44 = (unsigned long long)v43;
    *((unsigned long long*)v2) = v44;
    // LINE: 19
    v46 = -1llu;
    v47 = (unsigned long long)v46;
    *((unsigned long long*)v2) = v47;
    // LINE: 20
    v49 = -1ll;
    v50 = (unsigned long long)v49;
    *((unsigned long long*)v2) = v50;
    // LINE: 21
    v55 = (long long)32ll;
    v54 = 1ll << v55;
    v56 = (long long)1ll;
    v53 = v54 - v56;
    v57 = (long long)3ll;
    v52 = v53 & v57;
    v58 = (unsigned long long)v52;
    *((unsigned long long*)v2) = v58;
    // LINE: 22
    v64 = (long long)32ll;
    v63 = 1ll << v64;
    v65 = (long long)1ll;
    v62 = v63 - v65;
    v61 = (long long)v62;
    v66 = (long long)0ll;
    v60 = v61 < v66;
    v67 = (unsigned long long)v60;
    *((unsigned long long*)v2) = v67;
    // LINE: 23
    v70 = -1llu;
    v71 = (unsigned int)0ll;
    v69 = v70 < v71;
    v72 = (unsigned long long)v69;
    *((unsigned long long*)v2) = v72;
    // LINE: 24
    return 0ll;
}
int main(int argc, char **args) { return entry(); }