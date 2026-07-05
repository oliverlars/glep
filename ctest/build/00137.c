__attribute__((aligned(1))) struct { 

    char b0[25];

}_g0 = {
.b0 = {
104, 101, 108, 108, 111, 32, 105, 115, 32, 98, 101, 116, 116, 101, 114, 32, 116, 104, 97, 110, 32, 98, 121, 101, 0, },
};
void *str0 = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v7;
    char v8;
    int v9;
    int v6;
    int v5;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 6
    // LINE: 6
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 7
    v3 = (unsigned long long)str0;
    v4 = (unsigned long long)v3;
    *((unsigned long long*)v0) = v4;
    // LINE: 9
    v7 = *((unsigned long long*)v0);
    v8 = *((char*)v7);
    v9 = (int)v8;
    v6 = v9 == 104ll;
    if(v6 == 0) goto l0;
    v5 = 0ll;
    goto l1;
    l0: (void)noop;
    v5 = 1ll;
    l1: (void)noop;
    return v5;
}
int main(int argc, char **args) { return entry(); }