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
    unsigned long long v10;
    unsigned long long v8;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v16;
    unsigned long long v15;
    unsigned long long v17;
    int v18;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[8] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 6
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 8
    *((int*)v0) = 0ll;
    // LINE: 10
    v10 = v0;
    v8 = (unsigned long long)v10;
    *((unsigned long long*)v2) = v8;
    // LINE: 11
    v13 = v2;
    v14 = (unsigned long long)v13;
    *((unsigned long long*)v4) = v14;
    // LINE: 13
    v16 = *((unsigned long long*)v4);
    v15 = (unsigned long long)v16;
    v17 = *((unsigned long long*)v15);
    v18 = *((int*)v17);
    return v18;
}
int main(int argc, char **args) { return entry(); }