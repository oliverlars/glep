unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int foo(int v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    int v8;
    int v7;
    int v9;
    int v6;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 4
    // LINE: 4
    v8 = *((int*)v0);
    v7 = 2ll + v8;
    v9 = *((int*)v3);
    v6 = v7 - v9;
    return v6;
}
extern int entry() {
    int v0;
    // LINE: 10
    // LINE: 10
    v0 = foo(1ll, 3ll    );
    return v0;
}
int main(int argc, char **args) { return entry(); }