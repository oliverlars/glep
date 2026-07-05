__attribute__((aligned(1))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
37, 105, 10, 0, },
};
void *str0 = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
void foo();
int printf(unsigned long long, ...);
extern void foo() {
    // LINE: 17
}
extern int actual_function() {
    // LINE: 23
    // LINE: 23
    return 42ll;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v5;
    int v6;
    unsigned long long v8;
    unsigned long long v7;
    int v9;
    unsigned long long v10;
    int v11;
    int v12;
    unsigned long long v13;
    int v14;
    unsigned long long v16;
    unsigned long long v15;
    int v17;
    unsigned long long v18;
    int v19;
    int v20;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v5[4] __attribute__((aligned(16)));
    v5 = (unsigned long long)alloca_v5;
    char alloca_v13[4] __attribute__((aligned(16)));
    v13 = (unsigned long long)alloca_v13;
    // LINE: 29
    // LINE: 29
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (unsigned long long)actual_function;
    v3 = v2;
    v4 = (unsigned long long)v3;
    *((unsigned long long*)v0) = v4;
    // LINE: 31
    v6 = memset(v5, 0ll, 8ll    );
    v8 = *((unsigned long long*)v0);
    v7 = (unsigned long long)v8;
    v9 = ((int (*)())v7)(    );
    *((int*)v5) = v9;
    // LINE: 32
    v10 = (unsigned long long)str0;
    v11 = *((int*)v5);
    v12 = printf(v10, v11    );
    // LINE: 36
    v14 = memset(v13, 0ll, 8ll    );
    v16 = *((unsigned long long*)v0);
    v15 = (unsigned long long)v16;
    v17 = ((int (*)())v15)(    );
    *((int*)v13) = v17;
    // LINE: 37
    v18 = (unsigned long long)str0;
    v19 = *((int*)v13);
    v20 = printf(v18, v19    );
    // LINE: 39
    return 0ll;
}
int main(int argc, char **args) { return entry(); }