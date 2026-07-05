unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    int v2;
    int v1;
    int v0;
    // LINE: 4
    // LINE: 4
    v2 = 2ll + 2ll;
    v1 = v2 * 2ll;
    v0 = v1 - 8ll;
    return v0;
}
int main(int argc, char **args) { return entry(); }