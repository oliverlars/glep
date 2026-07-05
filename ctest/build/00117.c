unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v3;
    int v7;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 3
    // LINE: 3
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = 1ll;
    v2 = v0 + 4llu;
    *((int*)v2) = 0ll;
    // LINE: 4
    v4 = v0;
    v5 = (unsigned long long)1ll;
    v6 = v5 * 4llu;
    v3 = v4 + v6;
    v7 = *((int*)v3);
    return v7;
}
int main(int argc, char **args) { return entry(); }