unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    int v6;
    long long v8;
    int v9;
    unsigned int v11;
    int v12;
    long long v14;
    int v15;
    int v18;
    int v17;
    int v21;
    int v20;
    unsigned int v24;
    unsigned int v25;
    int v23;
    unsigned int v27;
    int v29;
    unsigned int v30;
    long long v32;
    unsigned int v33;
    unsigned int v35;
    long long v37;
    unsigned int v38;
    unsigned int v41;
    unsigned int v42;
    int v40;
    unsigned int v43;
    int v46;
    int v45;
    unsigned int v47;
    unsigned int v50;
    unsigned int v51;
    int v49;
    unsigned int v52;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 3
    // LINE: 3
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 4
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 1ll;
    // LINE: 7
    v6 = -1ll;
    *((int*)v0) = v6;
    // LINE: 8
    v8 = -1ll;
    v9 = (int)v8;
    *((int*)v0) = v9;
    // LINE: 9
    v11 = -1llu;
    v12 = (int)v11;
    *((int*)v0) = v12;
    // LINE: 10
    v14 = -1ll;
    v15 = (int)v14;
    *((int*)v0) = v15;
    // LINE: 11
    v18 = 32766ll + 1ll;
    v17 = v18 & 3ll;
    *((int*)v0) = v17;
    // LINE: 12
    v21 = (int)32768ll;
    v20 = v21 < 0ll;
    *((int*)v0) = v20;
    // LINE: 13
    v24 = -1llu;
    v25 = (unsigned int)0ll;
    v23 = v24 < v25;
    *((int*)v0) = v23;
    // LINE: 15
    v27 = (unsigned int)1ll;
    *((unsigned int*)v2) = v27;
    // LINE: 16
    v29 = -1ll;
    v30 = (unsigned int)v29;
    *((unsigned int*)v2) = v30;
    // LINE: 17
    v32 = -1ll;
    v33 = (unsigned int)v32;
    *((unsigned int*)v2) = v33;
    // LINE: 18
    v35 = -1llu;
    *((unsigned int*)v2) = v35;
    // LINE: 19
    v37 = -1ll;
    v38 = (unsigned int)v37;
    *((unsigned int*)v2) = v38;
    // LINE: 20
    v41 = (unsigned int)32768ll;
    v42 = (unsigned int)0ll;
    v40 = v41 < v42;
    v43 = (unsigned int)v40;
    *((unsigned int*)v2) = v43;
    // LINE: 21
    v46 = 32766ll + 1ll;
    v45 = v46 & 3ll;
    v47 = (unsigned int)v45;
    *((unsigned int*)v2) = v47;
    // LINE: 22
    v50 = -1llu;
    v51 = (unsigned int)0ll;
    v49 = v50 < v51;
    v52 = (unsigned int)v49;
    *((unsigned int*)v2) = v52;
    // LINE: 23
    return 0ll;
}
int main(int argc, char **args) { return entry(); }