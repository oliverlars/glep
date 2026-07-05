unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v6;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v11;
    unsigned long long v10;
    unsigned long long v15;
    unsigned long long v14;
    int v16;
    unsigned long long v18;
    unsigned long long v17;
    int v19;
    int v13;
    int v12;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    // LINE: 5
    // LINE: 5
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 8
    v6 = v0;
    v7 = (unsigned long long)v6;
    *((unsigned long long*)v2) = v7;
    // LINE: 9
    v8 = v0 + 0llu;
    *((int*)v8) = 1ll;
    // LINE: 10
    v11 = *((unsigned long long*)v2);
    v10 = v11 + 4llu;
    *((int*)v10) = 2ll;
    // LINE: 11
    v15 = *((unsigned long long*)v2);
    v14 = v15 + 4llu;
    v16 = *((int*)v14);
    v18 = *((unsigned long long*)v2);
    v17 = v18 + 0llu;
    v19 = *((int*)v17);
    v13 = v16 + v19;
    v12 = v13 - 3ll;
    return v12;
}
int main(int argc, char **args) { return entry(); }