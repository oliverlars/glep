__attribute__((aligned(1))) struct { 

    char b0[33];

}_g0 = {
.b0 = {
117, 110, 115, 105, 103, 110, 101, 100, 32, 101, 110, 117, 109, 32, 98, 105, 116, 45, 102, 105, 101, 108, 100, 115, 32, 98, 114, 111, 107, 101, 110, 10, 0, },
};
void *str0 = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
int printf(unsigned long long, ...);
extern int blah() {
    // LINE: 34
    // LINE: 34
    return 0ll;
}
extern int convert_like_real(unsigned long long v2) {
    unsigned long long v0;
    int v1;
    unsigned long long v6;
    unsigned long long v5;
    unsigned long long v4;
    int v7;
    int v3;
    int v8;
    int v9;
    unsigned long long v10;
    int v11;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    v1 = memset(v0, 0ll, 8ll    );
    *((unsigned long long*)v0) = v2;
    // LINE: 38
    // LINE: 38
    v6 = *((unsigned long long*)v0);
    v5 = v6 + 0llu;
    v4 = v5 + 16llu;
    v7 = *((int*)v4);
    v3 = (int)v7;
    v8 = v3 == 152ll;
    if(v8 != 0) goto l1;
    goto l2;
    l1: (void)noop;
    // LINE: 43
    v9 = blah(    );
    return v9;
    l2: (void)noop;
    // LINE: 45
    goto l0;
    l0: (void)noop;
    // LINE: 46
    // LINE: 47
    v10 = (unsigned long long)str0;
    v11 = printf(v10    );
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v2;
    unsigned long long v6;
    int v7;
    char alloca_v0[0] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 52
    // LINE: 52
    v1 = memset(v0, 0ll, 0ll    );
    // LINE: 54
    v3 = v0 + 0llu;
    v2 = v3 + 16llu;
    *((int*)v2) = 152ll;
    // LINE: 55
    v6 = v0;
    v7 = convert_like_real(v6    );
    // LINE: 56
    return 0ll;
}
int main(int argc, char **args) { return entry(); }