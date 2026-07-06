__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
10, 0, 0, 0, },
};
void *x = &_g0;
__attribute__((aligned(8))) struct { 

    char _b0[8]; void *_r0;

}_g1 = {
._b0 = {
1, 0, 0, 0, 0, 0, 0, 0, 0, },
};
void *s = &_g1;
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
    unsigned long long v7;
    int v8;
    int v4;
    // LINE: 9
    // LINE: 9
    v2 = (unsigned long long)s;
    v1 = v2 + 0llu;
    v3 = *((int*)v1);
    v0 = v3 != 1ll;
    if(v0 == 0) goto l0;
    // LINE: 10
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 11
    v6 = (unsigned long long)s;
    v5 = v6 + 8llu;
    v7 = *((unsigned long long*)v5);
    v8 = *((int*)v7);
    v4 = v8 != 10ll;
    if(v4 == 0) goto l2;
    // LINE: 12
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 13
    return 0ll;
}
int main(int argc, char **args) { return entry(); }