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
int strlen(unsigned long long);
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v6;
    int v7;
    int v5;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 6
    // LINE: 6
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 8
    v3 = (unsigned long long)str0;
    v4 = (unsigned long long)v3;
    *((unsigned long long*)v0) = v4;
    // LINE: 9
    v6 = *((unsigned long long*)v0);
    v7 = strlen(v6    );
    v5 = v7 - 5ll;
    return v5;
}
int main(int argc, char **args) { return entry(); }