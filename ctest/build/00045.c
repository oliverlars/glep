__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
5, 0, 0, 0, },
};
void *x = &_g0;
__attribute__((aligned(8))) struct { 

    char b0[8];

}_g1 = {
.b0 = {
6, 0, 0, 0, 0, 0, 0, 0, },
};
void *y = &_g1;
__attribute__((aligned(8))) struct { 

    char b0[8];

}_g2 = {
.b0 = {
0, 0, 0, 0, 0, 0, 0, 0, },
};
void *p = &_g2;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v1;
    int v2;
    int v0;
    unsigned long long v4;
    long long v5;
    long long v6;
    int v3;
    unsigned long long v8;
    unsigned long long v9;
    int v10;
    int v7;
    // LINE: 8
    // LINE: 8
    v1 = (unsigned long long)x;
    v2 = *((int*)v1);
    v0 = v2 != 5ll;
    if(v0 == 0) goto l0;
    // LINE: 9
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 10
    v4 = (unsigned long long)y;
    v5 = *((long long*)v4);
    v6 = (long long)6ll;
    v3 = v5 != v6;
    if(v3 == 0) goto l2;
    // LINE: 11
    return 2ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 12
    v8 = (unsigned long long)p;
    v9 = *((unsigned long long*)v8);
    v10 = *((int*)v9);
    v7 = v10 != 5ll;
    if(v7 == 0) goto l4;
    // LINE: 13
    return 3ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 14
    return 0ll;
}
int main(int argc, char **args) { return entry(); }