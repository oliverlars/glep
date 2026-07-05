unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    short v2;
    unsigned long long v3;
    int v4;
    long long v5;
    long long v7;
    short v8;
    short v10;
    short v9;
    short v11;
    char alloca_v0[2] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[8] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (short)1ll;
    *((short*)v0) = v2;
    // LINE: 5
    v4 = memset(v3, 0ll, 8ll    );
    v5 = (long long)1ll;
    *((long long*)v3) = v5;
    // LINE: 7
    v7 = *((long long*)v3);
    v8 = (short)v7;
    v10 = *((short*)v0);
    v9 = v10 - v8;
    *((short*)v0) = v9;
    // LINE: 8
    v11 = *((short*)v0);
    return v11;
}
int main(int argc, char **args) { return entry(); }