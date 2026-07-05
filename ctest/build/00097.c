unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    // LINE: 13
    // LINE: 13
    return 0ll;
}
int main(int argc, char **args) { return entry(); }