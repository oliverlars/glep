__attribute__((aligned(8))) struct { 

    char b0[8];

}_g0 = {
.b0 = {
0, 0, 0, 0, 0, 0, 0, 0, },
};
void *fptr = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    unsigned long long v1;
    // LINE: 7
    // LINE: 7
    v0 = (unsigned long long)fptr;
    v1 = *((unsigned long long*)v0);
    if(v1 == 0) goto l0;
    // LINE: 8
    return 1ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 9
    return 0ll;
}
int main(int argc, char **args) { return entry(); }