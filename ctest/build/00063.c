__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
0, 0, 0, 0, },
};
void *x = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    // LINE: 19
    // LINE: 1
    return 0ll;
}
int main(int argc, char **args) { return entry(); }