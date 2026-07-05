unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int f1(unsigned long long v2) {
    unsigned long long v0;
    int v1;
    unsigned long long v4;
    char v5;
    int v6;
    int v3;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    v1 = memset(v0, 0ll, 8ll    );
    *((unsigned long long*)v0) = v2;
    // LINE: 4
    // LINE: 4
    v4 = *((unsigned long long*)v0);
    v5 = *((char*)v4);
    v6 = (int)v5;
    v3 = v6 + 1ll;
    return v3;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    char v2;
    unsigned long long v3;
    int v4;
    unsigned long long v5;
    int v6;
     v8;
    unsigned long long v10;
    int v11;
    int v7;
    char alloca_v0[1] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4000] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v5[0] __attribute__((aligned(16)));
    v5 = (unsigned long long)alloca_v5;
    // LINE: 10
    // LINE: 10
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (char)1ll;
    *((char*)v0) = v2;
    // LINE: 11
    v4 = memset(v3, 0ll, 4000ll    );
    // LINE: 12
    v6 = memset(v5, 0ll, 0ll    );
    // LINE: 14
    v8 = *((*)v5);
    v10 = v0;
    v11 = ((int (*)())v8)(v10    );
    v7 = v11 != 2ll;
    if(v7 == 0) goto l0;
    // LINE: 15
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 16
    return 0ll;
}
int main(int argc, char **args) { return entry(); }