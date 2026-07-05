__attribute__((aligned(4))) struct { 

    char b0[124];

}_g0 = {
.b0 = {
},
};
void *array = &_g0;
__attribute__((aligned(1))) struct { 

    char b0[10];

}_g1 = {
.b0 = {
110, 43, 49, 32, 61, 32, 37, 100, 10, 0, },
};
void *str0 = &_g1;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
int printf(unsigned long long, ...);
extern int entry() {
    unsigned long long v0;
    int v1;
    int v2;
    // LINE: 10
    // LINE: 10
    v0 = (unsigned long long)str0;
    v1 = 14ll + 1ll;
    v2 = printf(v0, v1    );
}
int main(int argc, char **args) { return entry(); }