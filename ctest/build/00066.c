unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    int v2;
    int v1;
    int v0;
    int v4;
    int v3;
    // LINE: 8
    // LINE: 8
    v2 = 1ll + 2ll;
    v1 = v2 + 3ll;
    v0 = v1 != 6ll;
    if(v0 == 0) goto l0;
    // LINE: 9
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 10
    v4 = 0ll + 0ll;
    v3 = v4 + 0ll;
    return v3;
}
int main(int argc, char **args) { return entry(); }