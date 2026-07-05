__attribute__((aligned(8))) struct { 

    char b0[8];

}_g0 = {
.b0 = {
},
};
void *e = &_g0;
__attribute__((aligned(8))) struct { 

    char b0[8];

}_g1 = {
.b0 = {
},
};
void *e1 = &_g1;
__attribute__((aligned(8))) struct { 

    char b0[8];

}_g2 = {
.b0 = {
},
};
void *e2 = &_g2;
__attribute__((aligned(8))) struct { 

    char b0[8];

}_g3 = {
.b0 = {
},
};
void *s = &_g3;
__attribute__((aligned(8))) struct { 

    char b0[8];

}_g4 = {
.b0 = {
},
};
void *s1 = &_g4;
__attribute__((aligned(8))) struct { 

    char b0[8];

}_g5 = {
.b0 = {
},
};
void *s2 = &_g5;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
int f1(int,int);
int f2(,int);
int f3(,int);
int f4(unsigned long long,int);
int f5(,unsigned long long);
int f8(unsigned long long,int);
extern int f1(unsigned long long v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
     v7;
    int v8;
    int v9;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    v1 = memset(v0, 0ll, 8ll    );
    *((unsigned long long*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 24
    // LINE: 24
    v6 = *((unsigned long long*)v0);
    v7 = *((*)v6);
    v8 = *((int*)v3);
    v9 = ((int (*)())v7)(v8    );
    return v9;
}
extern int f2(unsigned long long v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
     v7;
    int v8;
    int v9;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    v1 = memset(v0, 0ll, 8ll    );
    *((unsigned long long*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 28
    // LINE: 28
    v6 = *((unsigned long long*)v0);
    v7 = *((*)v6);
    v8 = *((int*)v3);
    v9 = ((int (*)())v7)(v8    );
    return v9;
}
extern int f3(unsigned long long v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
     v7;
    int v8;
    int v9;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    v1 = memset(v0, 0ll, 8ll    );
    *((unsigned long long*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 32
    // LINE: 32
    v6 = *((unsigned long long*)v0);
    v7 = *((*)v6);
    v8 = *((int*)v3);
    v9 = ((int (*)())v7)(v8    );
    return v9;
}
extern int f4(unsigned long long v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    int v7;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v6;
    unsigned long long v11;
     v12;
    int v13;
    int v14;
    char alloca_v0[32] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    v1 = memset(v0, 0ll, 32ll    );
    *((unsigned long long*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 36
    // LINE: 36
    v7 = *((int*)v3);
    v8 = v0;
    v9 = (unsigned long long)v7;
    v10 = v9 * 8llu;
    v6 = v8 + v10;
    v11 = *((unsigned long long*)v6);
    v12 = *((*)v11);
    v13 = *((int*)v3);
    v14 = ((int (*)())v12)(v13    );
    return v14;
}
extern int f5(unsigned long long v2,
unsigned long long v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
    unsigned long long v7;
    int v8;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[8] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    v1 = memset(v0, 0ll, 8ll    );
    *((unsigned long long*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((unsigned long long*)v3) = v5;
    // LINE: 40
    // LINE: 40
    v6 = *((unsigned long long*)v0);
    v7 = *((unsigned long long*)v3);
    v8 = ((int (*)())v6)(v7    );
    return v8;
}
extern int entry() {
    // LINE: 43
    // LINE: 43
    return 0ll;
}
int main(int argc, char **args) { return entry(); }