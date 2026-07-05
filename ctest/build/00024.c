__attribute__((aligned(4))) struct { 

    char b0[8];

}_g0 = {
.b0 = {
},
};
void *v = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v1;
    unsigned long long v0;
    unsigned long long v3;
    unsigned long long v2;
    unsigned long long v7;
    unsigned long long v6;
    int v8;
    int v5;
    unsigned long long v10;
    unsigned long long v9;
    int v11;
    int v4;
    // LINE: 8
    // LINE: 8
    v1 = (unsigned long long)v;
    v0 = v1 + 0llu;
    *((int*)v0) = 1ll;
    // LINE: 9
    v3 = (unsigned long long)v;
    v2 = v3 + 4llu;
    *((int*)v2) = 2ll;
    // LINE: 10
    v7 = (unsigned long long)v;
    v6 = v7 + 0llu;
    v8 = *((int*)v6);
    v5 = 3ll - v8;
    v10 = (unsigned long long)v;
    v9 = v10 + 4llu;
    v11 = *((int*)v9);
    v4 = v5 - v11;
    return v4;
}
int main(int argc, char **args) { return entry(); }