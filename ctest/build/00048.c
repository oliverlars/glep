__attribute__((aligned(4))) struct { 

    char b0[8];

}_g0 = {
.b0 = {
1, 0, 0, 0, 2, 0, 0, 0, },
};
void *s = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v2;
    unsigned long long v1;
    int v3;
    int v0;
    unsigned long long v6;
    unsigned long long v5;
    int v7;
    int v4;
    // LINE: 7
    // LINE: 7
    v2 = (unsigned long long)s;
    v1 = v2 + 0llu;
    v3 = *((int*)v1);
    v0 = v3 != 1ll;
    if(v0 == 0) goto l0;
    // LINE: 8
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 9
    v6 = (unsigned long long)s;
    v5 = v6 + 4llu;
    v7 = *((int*)v5);
    v4 = v7 != 2ll;
    if(v4 == 0) goto l2;
    // LINE: 10
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 11
    return 0ll;
}
int main(int argc, char **args) { return entry(); }