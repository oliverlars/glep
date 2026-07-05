__attribute__((aligned(4))) struct { 

    char b0[120];

}_g0 = {
.b0 = {
0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
};
void *arr = &_g0;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern int entry() {
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v7;
    unsigned long long v3;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v2;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v1;
    int v12;
    unsigned long long v16;
    unsigned long long v17;
    unsigned long long v18;
    unsigned long long v19;
    unsigned long long v15;
    unsigned long long v20;
    unsigned long long v21;
    unsigned long long v14;
    unsigned long long v22;
    unsigned long long v23;
    unsigned long long v13;
    int v24;
    int v0;
    int v25;
    // LINE: 15
    // LINE: 15
    v4 = (unsigned long long)arr;
    v5 = v4;
    v6 = (unsigned long long)0ll;
    v7 = v6 * 60llu;
    v3 = v5 + v7;
    v8 = (unsigned long long)1ll;
    v9 = v8 * 20llu;
    v2 = v3 + v9;
    v10 = (unsigned long long)4ll;
    v11 = v10 * 4llu;
    v1 = v2 + v11;
    v12 = *((int*)v1);
    v16 = (unsigned long long)arr;
    v17 = v16;
    v18 = (unsigned long long)1ll;
    v19 = v18 * 60llu;
    v15 = v17 + v19;
    v20 = (unsigned long long)1ll;
    v21 = v20 * 20llu;
    v14 = v15 + v21;
    v22 = (unsigned long long)4ll;
    v23 = v22 * 4llu;
    v13 = v14 + v23;
    v24 = *((int*)v13);
    v0 = v12 == v24;
    v25 = v0 == 0ll;
    return v25;
}
int main(int argc, char **args) { return entry(); }