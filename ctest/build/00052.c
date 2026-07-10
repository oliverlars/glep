unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v4;
    unsigned long long v6;
    int v8;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    // LINE: 6
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 7
    v4 = v2 + 0llu;
    *((int*)v4) = 0ll;
    // LINE: 8
    v6 = v2 + 0llu;
    v8 = *((int*)v6);
    return v8;
}
int main(int argc, char **args) { return entry(); }