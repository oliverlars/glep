__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
3, 0, 0, 0, },
};
void *x = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v1;
    int v2;
    int v0;
    unsigned long long v3;
    unsigned long long v4;
    int v5;
    // LINE: 6
    // LINE: 6
    v1 = (unsigned long long)x;
    v2 = *((int*)v1);
    v0 = v2 != 3ll;
    if(v0 == 0) goto l0;
    // LINE: 7
    return 0ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 9
    v3 = (unsigned long long)x;
    *((int*)v3) = 0ll;
    // LINE: 10
    v4 = (unsigned long long)x;
    v5 = *((int*)v4);
    return v5;
}
int main(int argc, char **args) { return entry(); }