__attribute__((aligned(8))) struct { 

    char b0[8];

}_g0 = {
.b0 = {
0, 0, 0, 0, 0, 0, 0, 0, },
};
void *s = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int zero() {
    // LINE: 4
    // LINE: 4
    return 0ll;
}
extern unsigned long long anon() {
    unsigned long long v0;
    unsigned long long v1;
    // LINE: 15
    // LINE: 15
    v0 = (unsigned long long)s;
    v1 = v0;
    return v1;
}
extern unsigned long long go() {
    unsigned long long v0;
    unsigned long long v1;
    // LINE: 23
    // LINE: 23
    v0 = (unsigned long long)anon;
    v1 = v0;
    return v1;
}
extern int entry() {
    unsigned long long v1;
    unsigned long long v2;
    unsigned long long v0;
    unsigned long long v3;
    int v4;
    // LINE: 29
    // LINE: 29
    v1 = go(    );
    v2 = ((unsigned long long (*)())v1)(    );
    v0 = v2 + 0llu;
    v3 = *((unsigned long long*)v0);
    v4 = ((int (*)())v3)(    );
    return v4;
}
int main(int argc, char **args) { return entry(); }