__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
},
};
void *a = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
int f(int);
int g(int);
extern int entry() {
    int v1;
    int v2;
    int v0;
    // LINE: 7
    // LINE: 7
    v1 = f(1ll    );
    v2 = g(1ll    );
    v0 = v1 - v2;
    return v0;
}
extern int f(int v2) {
    unsigned long long v0;
    int v1;
    int v3;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    // LINE: 13
    // LINE: 13
    v3 = *((int*)v0);
    return v3;
}
extern int g(int v2) {
    unsigned long long v0;
    int v1;
    int v3;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    // LINE: 19
    // LINE: 19
    v3 = *((int*)v0);
    return v3;
}
int main(int argc, char **args) { return entry(); }