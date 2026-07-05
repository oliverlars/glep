unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v4;
    unsigned long long v8;
    int v10;
    unsigned long long v11;
    int v13;
    int v7;
    int v6;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    v2 = v0 + 0llu;
    *((int*)v2) = 3ll;
    // LINE: 7
    v4 = v0 + 4llu;
    *((int*)v4) = 5ll;
    // LINE: 8
    v8 = v0 + 4llu;
    v10 = *((int*)v8);
    v11 = v0 + 0llu;
    v13 = *((int*)v11);
    v7 = v10 - v13;
    v6 = v7 - 2ll;
    return v6;
}
int main(int argc, char **args) { return entry(); }