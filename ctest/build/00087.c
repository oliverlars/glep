unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int foo() {
    // LINE: 9
    // LINE: 9
    return 0ll;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v8;
    int v9;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 15
    // LINE: 15
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 17
    v2 = v0 + 0llu;
    v4 = (unsigned long long)foo;
    v5 = (unsigned long long)v4;
    *((unsigned long long*)v2) = v5;
    // LINE: 18
    v6 = v0 + 0llu;
    v8 = *((unsigned long long*)v6);
    v9 = ((int (*)())v8)(    );
    return v9;
}
int main(int argc, char **args) { return entry(); }