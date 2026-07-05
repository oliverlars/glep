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
    long long v18;
    long long v19;
    long long v17;
    long long v22;
    long long v23;
    int v21;
    long long v24;
    unsigned long long v26;
    int v28;
    unsigned long long v29;
    long long v31;
    unsigned long long v32;
    unsigned int v34;
    unsigned long long v35;
    long long v37;
    unsigned long long v38;
    unsigned long long v41;
    unsigned long long v42;
    unsigned long long v40;
    unsigned long long v45;
    unsigned long long v46;
    int v44;
    unsigned long long v47;
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
    v18 = -1ll;
    v19 = (long long)3ll;
    v17 = v18 & v19;
    *((long long*)v0) = v17;
    // LINE: 13
    v22 = -1ll;
    v23 = (long long)0ll;
    v21 = v22 < v23;
    v24 = (long long)v21;
    *((long long*)v0) = v24;
    // LINE: 15
    v26 = (unsigned long long)1ll;
    *((unsigned long long*)v2) = v26;
    // LINE: 16
    v28 = -1ll;
    v29 = (unsigned long long)v28;
    *((unsigned long long*)v2) = v29;
    // LINE: 17
    v31 = -1ll;
    v32 = (unsigned long long)v31;
    *((unsigned long long*)v2) = v32;
    // LINE: 18
    v34 = -1llu;
    v35 = (unsigned long long)v34;
    *((unsigned long long*)v2) = v35;
    // LINE: 19
    v37 = -1ll;
    v38 = (unsigned long long)v37;
    *((unsigned long long*)v2) = v38;
    // LINE: 20
    v41 = -1llu;
    v42 = (unsigned long long)3ll;
    v40 = v41 & v42;
    *((unsigned long long*)v2) = v40;
    // LINE: 21
    v45 = -1llu;
    v46 = (unsigned long long)0ll;
    v44 = v45 < v46;
    v47 = (unsigned long long)v44;
    *((unsigned long long*)v2) = v47;
    // LINE: 22
    return 0ll;
}
int main(int argc, char **args) { return entry(); }