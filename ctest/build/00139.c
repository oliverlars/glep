unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v3;
    int v2;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 12
    // LINE: 12
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = 0ll;
    // LINE: 14
    v3 = *((int*)v0);
    v2 = 2ll * v3;
    return v2;
}
int main(int argc, char **args) { return entry(); }