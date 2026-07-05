__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
},
};
void *c = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    // LINE: 6
    // LINE: 6
    if(0ll == 0) goto l0;
    // LINE: 7
    // LINE: 7
    return 1ll;
    goto l1;
    l0: (void)noop;
    // LINE: 8
    if(0ll == 0) goto l2;
    // LINE: 9
    goto l3;
    l2: (void)noop;
    // LINE: 10
    // LINE: 10
    if(1ll == 0) goto l4;
    // LINE: 11
    // LINE: 11
    v0 = (unsigned long long)c;
    v1 = *((int*)v0);
    if(v1 == 0) goto l6;
    // LINE: 12
    return 1ll;
    goto l7;
    l6: (void)noop;
    // LINE: 14
    return 0ll;
    l7: (void)noop;
    goto l5;
    l4: (void)noop;
    // LINE: 16
    // LINE: 16
    return 1ll;
    l5: (void)noop;
    l3: (void)noop;
    l1: (void)noop;
    // LINE: 19
    return 1ll;
}
int main(int argc, char **args) { return entry(); }