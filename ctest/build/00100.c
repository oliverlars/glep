unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int foo() {
    // LINE: 4
    // LINE: 4
    return 0ll;
}
extern int entry() {
    int v0;
    // LINE: 10
    // LINE: 10
    v0 = foo(    );
    return v0;
}
int main(int argc, char **args) { return entry(); }