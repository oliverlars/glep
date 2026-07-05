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
    int v8;
    int v9;
    int v7;
    int v12;
    int v13;
    int v11;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[4] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 9
    // LINE: 9
    v1 = memset(v0, 0ll, 8ll    );
    v3 = memset(v2, 0ll, 8ll    );
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 11
    v8 = *((int*)v0);
    v9 = *((int*)v2);
    v7 = v8 + v9;
    *((int*)v4) = v7;
    // LINE: 3
    v12 = *((int*)v0);
    v13 = *((int*)v2);
    v11 = v12 + v13;
    *((int*)v4) = v11;
    // LINE: 13
    return 0ll;
}
int main(int argc, char **args) { return entry(); }