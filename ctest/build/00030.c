unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int f() {
    // LINE: 4
    // LINE: 4
    return 100ll;
}
extern int entry() {
    int v1;
    int v0;
    int v3;
    int v2;
    int v5;
    int v4;
    int v7;
    int v6;
    int v9;
    int v8;
    int v11;
    int v10;
    // LINE: 10
    // LINE: 10
    v1 = f(    );
    v0 = 1000ll < v1;
    if(v0 == 0) goto l0;
    // LINE: 11
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 12
    v3 = f(    );
    v2 = 1000ll <= v3;
    if(v2 == 0) goto l2;
    // LINE: 13
    return 1ll;
    goto l3;
    l2: (void)noop;
    l3: (void)noop;
    // LINE: 14
    v5 = f(    );
    v4 = 1000ll < v5;
    if(v4 == 0) goto l4;
    // LINE: 15
    return 1ll;
    goto l5;
    l4: (void)noop;
    l5: (void)noop;
    // LINE: 16
    v7 = f(    );
    v6 = 1000ll <= v7;
    if(v6 == 0) goto l6;
    // LINE: 17
    return 1ll;
    goto l7;
    l6: (void)noop;
    l7: (void)noop;
    // LINE: 18
    v9 = f(    );
    v8 = 1000ll == v9;
    if(v8 == 0) goto l8;
    // LINE: 19
    return 1ll;
    goto l9;
    l8: (void)noop;
    l9: (void)noop;
    // LINE: 20
    v11 = f(    );
    v10 = 100ll != v11;
    if(v10 == 0) goto l10;
    // LINE: 21
    return 1ll;
    goto l11;
    l10: (void)noop;
    l11: (void)noop;
    // LINE: 22
    return 0ll;
}
int main(int argc, char **args) { return entry(); }