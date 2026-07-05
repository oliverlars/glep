__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
1, 0, 0, 0, },
};
void *x = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v1;
    int v2;
    int v0;
    // LINE: 7
    // LINE: 7
    v1 = (unsigned long long)x;
    v2 = *((int*)v1);
    v0 = v2 - 1ll;
    return v0;
}
int main(int argc, char **args) { return entry(); }