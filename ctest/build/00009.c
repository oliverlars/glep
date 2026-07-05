unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    int v5;
    int v4;
    int v8;
    int v7;
    int v11;
    int v10;
    int v13;
    int v12;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    *((int*)v0) = 1ll;
    // LINE: 7
    v5 = *((int*)v0);
    v4 = v5 * 10ll;
    *((int*)v0) = v4;
    // LINE: 8
    v8 = *((int*)v0);
    v7 = v8 / 2ll;
    *((int*)v0) = v7;
    // LINE: 9
    v11 = *((int*)v0);
    v10 = v11 % 3ll;
    *((int*)v0) = v10;
    // LINE: 10
    v13 = *((int*)v0);
    v12 = v13 - 2ll;
    return v12;
}
int main(int argc, char **args) { return entry(); }