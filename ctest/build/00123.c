__attribute__((aligned(8))) struct { 

    char b0[8];

}_g0 = {
.b0 = {
0, 0, 0, 0, 0, 0, 89, 64, },
};
void *x = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v1;
    double v2;
    double v3;
    int v0;
    // LINE: 6
    // LINE: 6
    v1 = (unsigned long long)x;
    v2 = *((double*)v1);
    v3 = (double)1ll;
    v0 = v2 < v3;
    return v0;
}
int main(int argc, char **args) { return entry(); }