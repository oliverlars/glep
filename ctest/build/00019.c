unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v4;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v14;
    unsigned long long v16;
    unsigned long long v13;
    unsigned long long v17;
    unsigned long long v12;
    unsigned long long v18;
    unsigned long long v11;
    unsigned long long v19;
    unsigned long long v10;
    unsigned long long v20;
    unsigned long long v9;
    int v21;
    char alloca_v0[16] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 16ll    );
    // LINE: 6
    v2 = v0 + 8llu;
    *((int*)v2) = 0ll;
    // LINE: 7
    v4 = v0 + 0llu;
    v7 = v0;
    v8 = (unsigned long long)v7;
    *((unsigned long long*)v4) = v8;
    // LINE: 8
    v14 = v0 + 0llu;
    v16 = *((unsigned long long*)v14);
    v13 = v16 + 0llu;
    v17 = *((unsigned long long*)v13);
    v12 = v17 + 0llu;
    v18 = *((unsigned long long*)v12);
    v11 = v18 + 0llu;
    v19 = *((unsigned long long*)v11);
    v10 = v19 + 0llu;
    v20 = *((unsigned long long*)v10);
    v9 = v20 + 8llu;
    v21 = *((int*)v9);
    return v21;
}
int main(int argc, char **args) { return entry(); }