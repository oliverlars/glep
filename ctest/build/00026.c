__attribute__((aligned(1))) struct { 

    char b0[6];

}_g0 = {
.b0 = {
104, 101, 108, 108, 111, 0, },
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
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v6;
    char v10;
    int v11;
    int v5;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    v3 = (unsigned long long)str0;
    v4 = (unsigned long long)v3;
    *((unsigned long long*)v0) = v4;
    // LINE: 7
    v7 = *((unsigned long long*)v0);
    v8 = (unsigned long long)0ll;
    v9 = v8 * 1llu;
    v6 = v7 + v9;
    v10 = *((char*)v6);
    v11 = (int)v10;
    v5 = v11 - 104ll;
    return v5;
}
int main(int argc, char **args) { return entry(); }