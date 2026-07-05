__attribute__((aligned(1))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
97, 98, 99, 0, },
};
void *str0 = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v1;
    unsigned long long v2;
    unsigned long long v3;
    int v0;
    // LINE: 4
    // LINE: 4
    v1 = (unsigned long long)str0;
    v2 = (unsigned long long)0ll;
    v3 = (unsigned long long)v2;
    v0 = v1 == v3;
    return v0;
}
int main(int argc, char **args) { return entry(); }