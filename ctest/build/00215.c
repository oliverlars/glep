__attribute__((aligned(1))) struct { 

    char b0[5];

}_g0 = {
.b0 = {
101, 110, 100, 10, 0, },
};
void *str6 = &_g0;
__attribute__((aligned(1))) struct { 

    char b0[13];

}_g1 = {
.b0 = {
116, 105, 109, 101, 111, 117, 116, 32, 105, 115, 32, 50, 0, },
};
void *str2 = &_g1;
__attribute__((aligned(1))) struct { 

    char b0[14];

}_g2 = {
.b0 = {
116, 105, 109, 101, 111, 117, 116, 32, 105, 115, 32, 48, 63, 0, },
};
void *str4 = &_g2;
__attribute__((aligned(1))) struct { 

    char b0[13];

}_g3 = {
.b0 = {
116, 105, 109, 101, 111, 117, 116, 61, 37, 108, 100, 10, 0, },
};
void *str0 = &_g3;
__attribute__((aligned(1))) struct { 

    char b0[13];

}_g4 = {
.b0 = {
116, 105, 109, 101, 111, 117, 116, 32, 105, 115, 32, 49, 0, },
};
void *str3 = &_g4;
__attribute__((aligned(1))) struct { 

    char b0[7];

}_g5 = {
.b0 = {
98, 101, 103, 105, 110, 10, 0, },
};
void *str5 = &_g5;
__attribute__((aligned(1))) struct { 

    char b0[7];

}_g6 = {
.b0 = {
101, 114, 114, 111, 114, 10, 0, },
};
void *str1 = &_g6;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
int printf(unsigned long long, ...);
static void kb_wait_1() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 4
    // LINE: 4
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (unsigned long long)2ll;
    *((unsigned long long*)v0) = v2;
    // LINE: 5
    l0: (void)noop;
    // LINE: 6
    // LINE: 6
    if(1ll == 0) goto l3;
    // LINE: 6
    v3 = (unsigned long long)str0;
    v4 = *((unsigned long long*)v0);
    v5 = printf(v3, v4    );
    goto l4;
    l3: (void)noop;
    // LINE: 9
    // LINE: 9
    l5: (void)noop;
    if(1ll == 0) goto l6;
    // LINE: 10
    v6 = (unsigned long long)str1;
    v7 = printf(v6    );
    goto l5;
    l6: (void)noop;
    l4: (void)noop;
    // LINE: 12
    v9 = *((unsigned long long*)v0);
    v10 = v9 - 1llu;
    *((unsigned long long*)v0) = v10;
    l2: (void)noop;
    v11 = *((unsigned long long*)v0);
    if(v11 != 0) goto l0;
    l1: (void)noop;
}
static void kb_wait_2() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 17
    // LINE: 17
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (unsigned long long)2ll;
    *((unsigned long long*)v0) = v2;
    // LINE: 18
    l8: (void)noop;
    // LINE: 19
    // LINE: 19
    if(1ll == 0) goto l11;
    // LINE: 19
    v3 = (unsigned long long)str0;
    v4 = *((unsigned long long*)v0);
    v5 = printf(v3, v4    );
    goto l12;
    l11: (void)noop;
    // LINE: 22
    // LINE: 22
    // LINE: 22
    l13: (void)noop;
    // LINE: 23
    v6 = (unsigned long long)str1;
    v7 = printf(v6    );
    l15: (void)noop;
    goto l13;
    l14: (void)noop;
    l12: (void)noop;
    // LINE: 25
    v9 = *((unsigned long long*)v0);
    v10 = v9 - 1llu;
    *((unsigned long long*)v0) = v10;
    l10: (void)noop;
    v11 = *((unsigned long long*)v0);
    if(v11 != 0) goto l8;
    l9: (void)noop;
}
static void kb_wait_2_1() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 30
    // LINE: 30
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (unsigned long long)2ll;
    *((unsigned long long*)v0) = v2;
    // LINE: 31
    l16: (void)noop;
    // LINE: 32
    // LINE: 32
    if(1ll == 0) goto l19;
    // LINE: 32
    v3 = (unsigned long long)str0;
    v4 = *((unsigned long long*)v0);
    v5 = printf(v3, v4    );
    goto l20;
    l19: (void)noop;
    // LINE: 35
    // LINE: 35
    l21: (void)noop;
    // LINE: 36
    // LINE: 36
    v6 = (unsigned long long)str1;
    v7 = printf(v6    );
    l23: (void)noop;
    if(1ll != 0) goto l21;
    l22: (void)noop;
    l20: (void)noop;
    // LINE: 39
    v9 = *((unsigned long long*)v0);
    v10 = v9 - 1llu;
    *((unsigned long long*)v0) = v10;
    l18: (void)noop;
    v11 = *((unsigned long long*)v0);
    if(v11 != 0) goto l16;
    l17: (void)noop;
}
static void kb_wait_2_2() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 44
    // LINE: 44
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (unsigned long long)2ll;
    *((unsigned long long*)v0) = v2;
    // LINE: 45
    l24: (void)noop;
    // LINE: 46
    // LINE: 46
    if(1ll == 0) goto l27;
    // LINE: 46
    v3 = (unsigned long long)str0;
    v4 = *((unsigned long long*)v0);
    v5 = printf(v3, v4    );
    goto l28;
    l27: (void)noop;
    // LINE: 49
    // LINE: 49
    llabel_kb_wait_2_2: (void)noop;
    // LINE: 50
    v6 = (unsigned long long)str1;
    v7 = printf(v6    );
    // LINE: 51
    goto llabel_kb_wait_2_2;
    // LINE: 51
    l28: (void)noop;
    // LINE: 53
    v9 = *((unsigned long long*)v0);
    v10 = v9 - 1llu;
    *((unsigned long long*)v0) = v10;
    l26: (void)noop;
    v11 = *((unsigned long long*)v0);
    if(v11 != 0) goto l24;
    l25: (void)noop;
}
static void kb_wait_3() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    int v10;
    int v9;
    int v13;
    int v12;
    unsigned long long v15;
    unsigned long long v16;
    unsigned long long v17;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v6[4] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    // LINE: 58
    // LINE: 58
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (unsigned long long)2ll;
    *((unsigned long long*)v0) = v2;
    // LINE: 59
    l29: (void)noop;
    // LINE: 60
    // LINE: 60
    if(1ll == 0) goto l32;
    // LINE: 60
    v3 = (unsigned long long)str0;
    v4 = *((unsigned long long*)v0);
    v5 = printf(v3, v4    );
    goto l33;
    l32: (void)noop;
    // LINE: 63
    // LINE: 63
    v7 = memset(v6, 0ll, 8ll    );
    *((int*)v6) = 1ll;
    // LINE: 64
    goto llabel_kb_wait_3;
    // LINE: 64
    // LINE: 65
    v10 = *((int*)v6);
    v9 = v10 + 2ll;
    *((int*)v6) = v9;
    // LINE: 66
    llabel_kb_wait_3: (void)noop;
    // LINE: 67
    v13 = *((int*)v6);
    v12 = v13 + 3ll;
    *((int*)v6) = v12;
    l33: (void)noop;
    // LINE: 69
    v15 = *((unsigned long long*)v0);
    v16 = v15 - 1llu;
    *((unsigned long long*)v0) = v16;
    l31: (void)noop;
    v17 = *((unsigned long long*)v0);
    if(v17 != 0) goto l29;
    l30: (void)noop;
}
static void kb_wait_4() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v9;
    int v10;
    unsigned long long v11;
    int v12;
    unsigned long long v13;
    int v14;
    unsigned long long v16;
    unsigned long long v17;
    unsigned long long v18;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 74
    // LINE: 74
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (unsigned long long)2ll;
    *((unsigned long long*)v0) = v2;
    // LINE: 75
    l34: (void)noop;
    // LINE: 76
    // LINE: 76
    if(1ll == 0) goto l37;
    // LINE: 76
    v3 = (unsigned long long)str0;
    v4 = *((unsigned long long*)v0);
    v5 = printf(v3, v4    );
    goto l38;
    l37: (void)noop;
    // LINE: 79
    // LINE: 79
    v6 = *((unsigned long long*)v0);
    v7 = v6 == 2ll;
    if(v7 != 0) goto l40;
    v8 = v6 == 1ll;
    if(v8 != 0) goto l41;
    goto l42;
    l40: (void)noop;
    // LINE: 81
    v9 = (unsigned long long)str2;
    v10 = printf(v9    );
    // LINE: 82
    goto l39;
    l41: (void)noop;
    // LINE: 84
    v11 = (unsigned long long)str3;
    v12 = printf(v11    );
    // LINE: 85
    goto l39;
    l42: (void)noop;
    // LINE: 87
    v13 = (unsigned long long)str4;
    v14 = printf(v13    );
    // LINE: 88
    goto l39;
    l39: (void)noop;
    // LINE: 89
    l38: (void)noop;
    // LINE: 92
    v16 = *((unsigned long long*)v0);
    v17 = v16 - 1llu;
    *((unsigned long long*)v0) = v17;
    l36: (void)noop;
    v18 = *((unsigned long long*)v0);
    if(v18 != 0) goto l34;
    l35: (void)noop;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    // LINE: 97
    // LINE: 97
    v0 = (unsigned long long)str5;
    v1 = printf(v0    );
    // LINE: 98
    kb_wait_1(    );
    // LINE: 99
    kb_wait_2(    );
    // LINE: 100
    kb_wait_2_1(    );
    // LINE: 101
    kb_wait_2_2(    );
    // LINE: 102
    kb_wait_3(    );
    // LINE: 103
    kb_wait_4(    );
    // LINE: 104
    v2 = (unsigned long long)str6;
    v3 = printf(v2    );
    // LINE: 105
    return 0ll;
}
int main(int argc, char **args) { return entry(); }