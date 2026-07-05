__attribute__((aligned(1))) struct { 

    char b0[3];

}_g0 = {
.b0 = {
104, 105, 0, },
};
void *str0 = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v6;
    char v10;
    int v11;
    int v5;
    int v4;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 7
    // LINE: 7
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (unsigned long long)str0;
    v3 = memcpy(v0, v2, 3ll    );
    // LINE: 9
    v7 = *((unsigned long long*)v0);
    v8 = (unsigned long long)1ll;
    v9 = v8 * 1llu;
    v6 = v7 + v9;
    v10 = *((char*)v6);
    v11 = (int)v10;
    v5 = v11 == 105ll;
    if(v5 == 0) goto l0;
    v4 = 0ll;
    goto l1;
    l0: (void)noop;
    v4 = 1ll;
    l1: (void)noop;
    return v4;
}
int main(int argc, char **args) { return entry(); }