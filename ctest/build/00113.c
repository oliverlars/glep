unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    int v5;
    int v4;
    float v6;
    float v8;
    int v9;
    float v10;
    int v7;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = 0ll;
    // LINE: 5
    v3 = memset(v2, 0ll, 8ll    );
    v5 = *((int*)v0);
    v4 = v5 + 1ll;
    v6 = (float)v4;
    *((float*)v2) = v6;
    // LINE: 7
    v8 = *((float*)v2);
    v9 = *((int*)v0);
    v10 = (float)v9;
    v7 = v8 == v10;
    return v7;
}
int main(int argc, char **args) { return entry(); }