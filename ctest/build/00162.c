unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
void foo(unsigned long long);
void fooc(unsigned long long);
void foos(unsigned long long);
void foov(unsigned long long);
void foor(unsigned long long);
void fooc(unsigned long long);
void foos(unsigned long long);
void foov(unsigned long long);
void foor(unsigned long long);
void fooc(unsigned long long);
void foos(unsigned long long);
void foov(unsigned long long);
void foor(unsigned long long);
void foovm(unsigned long long);
void foovm(unsigned long long);
extern void fooc(unsigned long long v2) {
    unsigned long long v0;
    int v1;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v3;
    char alloca_v0[20] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    v1 = memset(v0, 0ll, 24ll    );
    *((unsigned long long*)v0) = v2;
    // LINE: 16
    // LINE: 16
    v4 = v0;
    v5 = (unsigned long long)3ll;
    v6 = v5 * 4llu;
    v3 = v4 + v6;
    *((int*)v3) = 42ll;
}
extern int entry() {
    // LINE: 33
    // LINE: 33
    return 0ll;
}
int main(int argc, char **args) { return entry(); }