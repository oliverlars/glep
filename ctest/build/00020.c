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
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v16;
    int v17;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[8] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    v3 = memset(v2, 0ll, 8ll    );
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 0ll;
    // LINE: 7
    v9 = v0;
    v10 = (unsigned long long)v9;
    *((unsigned long long*)v2) = v10;
    // LINE: 8
    v13 = v2;
    v14 = (unsigned long long)v13;
    *((unsigned long long*)v4) = v14;
    // LINE: 9
    v15 = *((unsigned long long*)v4);
    v16 = *((unsigned long long*)v15);
    v17 = *((int*)v16);
    return v17;
}
int main(int argc, char **args) { return entry(); }