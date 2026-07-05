unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v2;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v6;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v12;
    int v16;
    unsigned long long v18;
    unsigned long long v19;
    unsigned long long v20;
    unsigned long long v17;
    int v21;
    int v11;
    int v10;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    v3 = v0;
    v4 = (unsigned long long)0ll;
    v5 = v4 * 4llu;
    v2 = v3 + v5;
    *((int*)v2) = 1ll;
    // LINE: 7
    v7 = v0;
    v8 = (unsigned long long)1ll;
    v9 = v8 * 4llu;
    v6 = v7 + v9;
    *((int*)v6) = 2ll;
    // LINE: 9
    v13 = v0;
    v14 = (unsigned long long)0ll;
    v15 = v14 * 4llu;
    v12 = v13 + v15;
    v16 = *((int*)v12);
    v18 = v0;
    v19 = (unsigned long long)1ll;
    v20 = v19 * 4llu;
    v17 = v18 + v20;
    v21 = *((int*)v17);
    v11 = v16 + v21;
    v10 = v11 - 3ll;
    return v10;
}
int main(int argc, char **args) { return entry(); }