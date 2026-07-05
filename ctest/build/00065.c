unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    int v1;
    int v0;
    // LINE: 7
    // LINE: 1
    v1 = 1ll + 2ll;
    v0 = v1 - 3ll;
    return v0;
}
int main(int argc, char **args) { return entry(); }