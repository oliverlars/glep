unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    // LINE: 10
    // LINE: 10
    if(0ll == 0) goto l0;
    // LINE: 11
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 12
    if(0ll == 0) goto l2;
    // LINE: 13
    return 1ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 14
    if(0ll == 0) goto l4;
    // LINE: 15
    return 1ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 16
    if(0ll == 0) goto l6;
    // LINE: 17
    return 1ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 18
    if(0ll == 0) goto l8;
    // LINE: 19
    return 1ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 20
    if(0ll == 0) goto l10;
    // LINE: 21
    return 1ll;
    goto l11;
    l10: (void)noop;
    l11: (void)noop;
    // LINE: 22
    if(0ll == 0) goto l12;
    // LINE: 23
    return 1ll;
    goto l13;
    l12: (void)noop;
    l13: (void)noop;
    // LINE: 25
    return 0ll;
}
int main(int argc, char **args) { return entry(); }