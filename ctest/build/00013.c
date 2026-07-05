unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v12;
    unsigned long long v9;
    int v13;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 7
    *((int*)v0) = 0ll;
    // LINE: 8
    v7 = v0;
    v8 = (unsigned long long)v7;
    *((unsigned long long*)v2) = v8;
    // LINE: 9
    v10 = *((unsigned long long*)v2);
    v11 = (unsigned long long)0ll;
    v12 = v11 * 4llu;
    v9 = v10 + v12;
    v13 = *((int*)v9);
    return v13;
}
int main(int argc, char **args) { return entry(); }