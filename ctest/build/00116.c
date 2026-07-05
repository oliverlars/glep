unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int f(int v2) {
    unsigned long long v0;
    int v1;
    int v3;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    // LINE: 4
    // LINE: 4
    v3 = *((int*)v0);
    return v3;
}
extern int entry() {
    int v0;
    int v1;
    // LINE: 10
    // LINE: 10
    v0 = *((int*)v0);
    v1 = ((int (*)())v0)(0ll    );
    return v1;
}
int main(int argc, char **args) { return entry(); }