unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v5;
    int v4;
    int v7;
    int v6;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 1ll;
    // LINE: 7
    v5 = *((int*)v0);
    v4 = v5 & 3ll;
    *((int*)v0) = v4;
    // LINE: 8
    v7 = *((int*)v0);
    v6 = v7 - 1ll;
    return v6;
}
int main(int argc, char **args) { return entry(); }