unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int f1(int v2,
int v4,
int v6,
unsigned long long v8,
float v10,
unsigned long long v14,
int v17, ...) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v5;
    unsigned long long v7;
    unsigned long long v9;
    unsigned long long v11;
    unsigned long long v12;
    int v13;
    unsigned long long v15;
    int v16;
    unsigned long long v19;
    int v21;
    unsigned long long v23;
    unsigned long long v22;
    int v24;
    int v18;
    unsigned long long v27;
    unsigned long long v26;
    int v28;
    int v29;
    int v25;
    char alloca_v0[32] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v12[8] __attribute__((aligned(16)));
    v12 = (unsigned long long)alloca_v12;
    char alloca_v15[4] __attribute__((aligned(16)));
    v15 = (unsigned long long)alloca_v15;
    v1 = memset(v0, 0ll, 32ll    );
    v3 = v0 + 0llu;
    *((int*)v3) = v2;
    v5 = v0 + 4llu;
    *((int*)v5) = v4;
    v7 = v0 + 8llu;
    *((int*)v7) = v6;
    v9 = v0 + 16llu;
    *((unsigned long long*)v9) = v8;
    v11 = v0 + 24llu;
    *((float*)v11) = v10;
    v13 = memset(v12, 0ll, 8ll    );
    *((unsigned long long*)v12) = v14;
    v16 = memset(v15, 0ll, 8ll    );
    *((int*)v15) = v17;
    // LINE: 10
    // LINE: 10
    v19 = v0 + 0llu;
    v21 = *((int*)v19);
    v23 = *((unsigned long long*)v12);
    v22 = v23 + 0llu;
    v24 = *((int*)v22);
    v18 = v21 != v24;
    if(v18 == 0) goto l0;
    // LINE: 11
    return 0ll;
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 12
    v27 = *((unsigned long long*)v12);
    v26 = v27 + 4llu;
    v28 = *((int*)v26);
    v29 = *((int*)v15);
    v25 = v28 + v29;
    return v25;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    unsigned long long v4;
    int v7;
    unsigned long long v8;
    int v9;
    unsigned long long v10;
    int v11;
    unsigned long long v12;
    unsigned long long v13;
    unsigned long long v14;
    float v15;
    unsigned long long v17;
    int v18;
    int v20;
    unsigned long long v21;
    int v22;
    unsigned long long v23;
    int v24;
    unsigned long long v25;
    unsigned long long v26;
    unsigned long long v27;
    float v28;
    unsigned long long v30;
    int v32;
    unsigned long long v33;
    int v34;
    unsigned long long v35;
    int v36;
    unsigned long long v37;
    unsigned long long v38;
    unsigned long long v39;
    float v40;
    unsigned long long v42;
    int v43;
    char alloca_v0[32] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 18
    // LINE: 18
    v1 = memset(v0, 0ll, 32ll    );
    // LINE: 20
    v2 = v0 + 0llu;
    v4 = v0 + 4llu;
    *((int*)v4) = 1ll;
    *((int*)v2) = 1ll;
    // LINE: 21
    v7 = *((int*)v0);
    v8 = v0 + 4llu;
    v9 = *((int*)v8);
    v10 = v0 + 8llu;
    v11 = *((int*)v10);
    v12 = v0 + 16llu;
    v13 = *((unsigned long long*)v12);
    v14 = v0 + 24llu;
    v15 = *((float*)v14);
    v17 = v0;
    v18 = f1(v7, v9, v11, v13, v15, v17, 2ll    );
    // LINE: 22
    v20 = *((int*)v0);
    v21 = v0 + 4llu;
    v22 = *((int*)v21);
    v23 = v0 + 8llu;
    v24 = *((int*)v23);
    v25 = v0 + 16llu;
    v26 = *((unsigned long long*)v25);
    v27 = v0 + 24llu;
    v28 = *((float*)v27);
    v30 = v0;
    v32 = *((int*)v0);
    v33 = v0 + 4llu;
    v34 = *((int*)v33);
    v35 = v0 + 8llu;
    v36 = *((int*)v35);
    v37 = v0 + 16llu;
    v38 = *((unsigned long long*)v37);
    v39 = v0 + 24llu;
    v40 = *((float*)v39);
    v42 = v0;
    v43 = f1(v20, v22, v24, v26, v28, v30, 2ll, 1ll, v32, v34, v36, v38, v40, v42    );
    // LINE: 24
    return 0ll;
}
int main(int argc, char **args) { return entry(); }