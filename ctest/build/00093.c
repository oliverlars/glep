__attribute__((aligned(4))) struct { 

    char b0[16];

}_g0 = {
.b0 = {
1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4, 0, 0, 0, },
};
void *a = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v2;
    unsigned long long v1;
    int v0;
    // LINE: 6
    // LINE: 6
    v2 = (unsigned long long)4ll;
    v1 = v2 * 4llu;
    v0 = 16llu != v1;
    if(v0 == 0) goto l0;
    // LINE: 7
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 9
    return 0ll;
}
int main(int argc, char **args) { return entry(); }