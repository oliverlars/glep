unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v3;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 5
    *((int*)v0) = 0ll;
    // LINE: 7
    l0: (void)noop;
    // LINE: 7
    l2: (void)noop;
    if(0ll != 0) goto l0;
    l1: (void)noop;
    // LINE: 9
    v3 = *((int*)v0);
    return v3;
}
int main(int argc, char **args) { return entry(); }