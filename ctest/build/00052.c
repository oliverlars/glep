unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v4;
    int v6;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    // LINE: 6
    // LINE: 6
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 7
    v2 = v0 + 0llu;
    *((int*)v2) = 0ll;
    // LINE: 8
    v4 = v0 + 0llu;
    v6 = *((int*)v4);
    return v6;
}
int main(int argc, char **args) { return entry(); }