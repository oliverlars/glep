unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    int v0;
    int v1;
    // LINE: 4
    // LINE: 4
    if(0ll == 0) goto l2;
    v0 = 1ll;
    goto l3;
    l2: (void)noop;
    v0 = 0ll;
    l3: (void)noop;
    if(v0 == 0) goto l0;
    // LINE: 5
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 6
    if(1ll == 0) goto l6;
    v1 = 0ll;
    goto l7;
    l6: (void)noop;
    v1 = 1ll;
    l7: (void)noop;
    if(v1 == 0) goto l4;
    // LINE: 7
    return 2ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 8
    return 0ll;
}
int main(int argc, char **args) { return entry(); }