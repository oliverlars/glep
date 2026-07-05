unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    // LINE: 4
    // LINE: 4
    lstart_main: (void)noop;
    // LINE: 5
    goto lnext_main;
    // LINE: 5
    // LINE: 6
    return 1ll;
    // LINE: 7
    lsuccess_main: (void)noop;
    // LINE: 8
    return 0ll;
    // LINE: 9
    lnext_main: (void)noop;
    // LINE: 10
    lfoo_main: (void)noop;
    // LINE: 11
    goto lsuccess_main;
    // LINE: 11
    // LINE: 12
    return 1ll;
}
int main(int argc, char **args) { return entry(); }