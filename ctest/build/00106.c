unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v2;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 7
    // LINE: 7
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 8
    v3 = v0 + 0llu;
    v2 = v3 + 0llu;
    *((int*)v2) = 1ll;
    // LINE: 9
    return 0ll;
}
int main(int argc, char **args) { return entry(); }