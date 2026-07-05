unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    int v0;
    // LINE: 4
    // LINE: 4
    v0 = 3ll - 3ll;
    return v0;
}
int main(int argc, char **args) { return entry(); }