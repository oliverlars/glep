unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern void voidfn() {
    // LINE: 4
    // LINE: 4
    return;
}
extern int entry() {
    // LINE: 10
    // LINE: 10
    voidfn(    );
    // LINE: 11
    return 0ll;
}
int main(int argc, char **args) { return entry(); }