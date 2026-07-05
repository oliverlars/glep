unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    int v0;
    // LINE: 4
    // LINE: 4
    v0 = 97ll != 97ll;
    if(v0 == 0) goto l0;
    // LINE: 5
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 7
    return 0ll;
}
int main(int argc, char **args) { return entry(); }