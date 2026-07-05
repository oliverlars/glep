__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
},
};
void *x = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern char x[];
extern int entry() {
    unsigned long long v0;
    int v1;
    // LINE: 7
    // LINE: 7
    v0 = (unsigned long long)x;
    v1 = *((int*)v0);
    return v1;
}
int main(int argc, char **args) { return entry(); }