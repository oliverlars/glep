__attribute__((aligned(8))) struct { 

    char b0[24];

}_g0 = {
.b0 = {
},
};
__attribute__((aligned(1))) struct { 

    char b0[8];

}_g1 = {
.b0 = {
37, 100, 58, 32, 37, 100, 10, 0, },
};
void *str0 = &_g1;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern char __stdinp[];
extern char __stdoutp[];
extern char __stderrp[];
extern char sys_nerr[];
extern char sys_errlist[];
int renameat(int,unsigned long long,int,unsigned long long);
int renamex_np(unsigned long long,unsigned long long,unsigned int);
int renameatx_np(int,unsigned long long,int,unsigned long long,unsigned int);
int printf(unsigned long long, ...);
void clearerr(unsigned long long);
int fclose(unsigned long long);
int feof(unsigned long long);
int ferror(unsigned long long);
int fflush(unsigned long long);
int fgetc(unsigned long long);
int fgetpos(unsigned long long,unsigned long long);
unsigned long long fgets(unsigned long long,int,unsigned long long);
unsigned long long fopen(unsigned long long,unsigned long long);
int fprintf(unsigned long long,unsigned long long, ...);
int fputc(int,unsigned long long);
int fputs(unsigned long long,unsigned long long);
unsigned long long fread(unsigned long long,unsigned long long,unsigned long long,unsigned long long);
unsigned long long freopen(unsigned long long,unsigned long long,unsigned long long);
int fscanf(unsigned long long,unsigned long long, ...);
int fseek(unsigned long long,long long,int);
int fsetpos(unsigned long long,unsigned long long);
long long ftell(unsigned long long);
unsigned long long fwrite(unsigned long long,unsigned long long,unsigned long long,unsigned long long);
int getc(unsigned long long);
int getchar();
unsigned long long gets(unsigned long long);
void perror(unsigned long long);
int putc(int,unsigned long long);
int putchar(int);
int puts(unsigned long long);
int remove(unsigned long long);
int rename(unsigned long long,unsigned long long);
void rewind(unsigned long long);
int scanf(unsigned long long, ...);
void setbuf(unsigned long long,unsigned long long);
int setvbuf(unsigned long long,unsigned long long,int,unsigned long long);
int sprintf(unsigned long long,unsigned long long, ...);
int sscanf(unsigned long long,unsigned long long, ...);
unsigned long long tmpfile();
unsigned long long tmpnam(unsigned long long);
int ungetc(int,unsigned long long);
int vfprintf(unsigned long long,unsigned long long,unsigned long long);
int vprintf(unsigned long long,unsigned long long);
int vsprintf(unsigned long long,unsigned long long,unsigned long long);
unsigned long long ctermid(unsigned long long);
unsigned long long fdopen(int,unsigned long long);
int fileno(unsigned long long);
int pclose(unsigned long long);
unsigned long long popen(unsigned long long,unsigned long long);
int __srget(unsigned long long);
int __svfscanf(unsigned long long,unsigned long long,unsigned long long);
int __swbuf(int,unsigned long long);
void flockfile(unsigned long long);
int ftrylockfile(unsigned long long);
void funlockfile(unsigned long long);
int getc_unlocked(unsigned long long);
int getchar_unlocked();
int putc_unlocked(int,unsigned long long);
int putchar_unlocked(int);
int getw(unsigned long long);
int putw(int,unsigned long long);
unsigned long long tempnam(unsigned long long,unsigned long long);
int fseeko(unsigned long long,long long,int);
long long ftello(unsigned long long);
int snprintf(unsigned long long,unsigned long long,unsigned long long, ...);
int vfscanf(unsigned long long,unsigned long long,unsigned long long);
int vscanf(unsigned long long,unsigned long long);
int vsnprintf(unsigned long long,unsigned long long,unsigned long long,unsigned long long);
int vsscanf(unsigned long long,unsigned long long,unsigned long long);
int dprintf(int,unsigned long long, ...);
int vdprintf(int,unsigned long long,unsigned long long);
long long getdelim(unsigned long long,unsigned long long,int,unsigned long long);
long long getline(unsigned long long,unsigned long long,unsigned long long);
unsigned long long fmemopen(unsigned long long,unsigned long long,unsigned long long);
unsigned long long open_memstream(unsigned long long,unsigned long long);
int asprintf(unsigned long long,unsigned long long, ...);
unsigned long long ctermid_r(unsigned long long);
unsigned long long fgetln(unsigned long long,unsigned long long);
unsigned long long fmtcheck(unsigned long long,unsigned long long);
int fpurge(unsigned long long);
void setbuffer(unsigned long long,unsigned long long,int);
int setlinebuf(unsigned long long);
int vasprintf(unsigned long long,unsigned long long,unsigned long long);
unsigned long long funopen(unsigned long long,unsigned long long,unsigned long long,unsigned long long,unsigned long long);
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v7;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v12;
    int v15;
    int v14;
    unsigned long long v16;
    int v17;
    int v19;
    unsigned long long v20;
    unsigned long long v21;
    unsigned long long v22;
    unsigned long long v18;
    int v23;
    int v24;
    int v26;
    int v27;
    unsigned long long v28;
    int v29;
    unsigned long long v30;
    unsigned long long v31;
    unsigned long long v32;
    unsigned long long v33;
    unsigned long long v34;
    unsigned long long v35;
    unsigned long long v36;
    unsigned long long v37;
    unsigned long long v38;
    int v41;
    int v40;
    unsigned long long v42;
    int v43;
    int v45;
    unsigned long long v46;
    unsigned long long v47;
    unsigned long long v48;
    unsigned long long v44;
    int v49;
    int v50;
    int v52;
    int v53;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[40] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v28[40] __attribute__((aligned(16)));
    v28 = (unsigned long long)alloca_v28;
    // LINE: 5
    // LINE: 5
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 7
    v3 = memset(v2, 0ll, 40ll    );
    *((int*)v2) = 12ll;
    v4 = v2 + 4llu;
    *((int*)v4) = 34ll;
    v5 = v2 + 8llu;
    *((int*)v5) = 56ll;
    v6 = v2 + 12llu;
    *((int*)v6) = 78ll;
    v7 = v2 + 16llu;
    *((int*)v7) = 90ll;
    v8 = v2 + 20llu;
    *((int*)v8) = 123ll;
    v9 = v2 + 24llu;
    *((int*)v9) = 456ll;
    v10 = v2 + 28llu;
    *((int*)v10) = 789ll;
    v11 = v2 + 32llu;
    *((int*)v11) = 8642ll;
    v12 = v2 + 36llu;
    *((int*)v12) = 9753ll;
    // LINE: 9
    // LINE: 9
    *((int*)v0) = 0ll;
    l0: (void)noop;
    v15 = *((int*)v0);
    v14 = v15 < 10ll;
    if(v14 == 0) goto l1;
    // LINE: 10
    v16 = (unsigned long long)str0;
    v17 = *((int*)v0);
    v19 = *((int*)v0);
    v20 = v2;
    v21 = (unsigned long long)v19;
    v22 = v21 * 4llu;
    v18 = v20 + v22;
    v23 = *((int*)v18);
    v24 = printf(v16, v17, v23    );
    l2: (void)noop;
    v26 = *((int*)v0);
    v27 = v26 + 1ll;
    *((int*)v0) = v27;
    goto l0;
    l1: (void)noop;
    // LINE: 12
    v29 = memset(v28, 0ll, 40ll    );
    *((int*)v28) = 12ll;
    v30 = v28 + 4llu;
    *((int*)v30) = 34ll;
    v31 = v28 + 8llu;
    *((int*)v31) = 56ll;
    v32 = v28 + 12llu;
    *((int*)v32) = 78ll;
    v33 = v28 + 16llu;
    *((int*)v33) = 90ll;
    v34 = v28 + 20llu;
    *((int*)v34) = 123ll;
    v35 = v28 + 24llu;
    *((int*)v35) = 456ll;
    v36 = v28 + 28llu;
    *((int*)v36) = 789ll;
    v37 = v28 + 32llu;
    *((int*)v37) = 8642ll;
    v38 = v28 + 36llu;
    *((int*)v38) = 9753ll;
    // LINE: 14
    // LINE: 14
    *((int*)v0) = 0ll;
    l3: (void)noop;
    v41 = *((int*)v0);
    v40 = v41 < 10ll;
    if(v40 == 0) goto l4;
    // LINE: 15
    v42 = (unsigned long long)str0;
    v43 = *((int*)v0);
    v45 = *((int*)v0);
    v46 = v28;
    v47 = (unsigned long long)v45;
    v48 = v47 * 4llu;
    v44 = v46 + v48;
    v49 = *((int*)v44);
    v50 = printf(v42, v43, v49    );
    l5: (void)noop;
    v52 = *((int*)v0);
    v53 = v52 + 1ll;
    *((int*)v0) = v53;
    goto l3;
    l4: (void)noop;
    // LINE: 18
    return 0ll;
}
int main(int argc, char **args) { return entry(); }