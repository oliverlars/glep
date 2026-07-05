__attribute__((aligned(1))) struct { 

    char b0[11];

}_g0 = {
.b0 = {
99, 32, 105, 115, 32, 78, 85, 76, 76, 10, 0, },
};
void *str3 = &_g0;
__attribute__((aligned(1))) struct { 

    char b0[11];

}_g1 = {
.b0 = {
98, 32, 105, 115, 32, 78, 85, 76, 76, 10, 0, },
};
void *str1 = &_g1;
__attribute__((aligned(1))) struct { 

    char b0[15];

}_g2 = {
.b0 = {
99, 32, 105, 115, 32, 110, 111, 116, 32, 78, 85, 76, 76, 10, 0, },
};
void *str4 = &_g2;
__attribute__((aligned(1))) struct { 

    char b0[15];

}_g3 = {
.b0 = {
98, 32, 105, 115, 32, 110, 111, 116, 32, 78, 85, 76, 76, 10, 0, },
};
void *str2 = &_g3;
__attribute__((aligned(1))) struct { 

    char b0[4];

}_g4 = {
.b0 = {
37, 100, 10, 0, },
};
void *str0 = &_g4;
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
    int v5;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v12;
    unsigned long long v13;
    unsigned long long v14;
    int v15;
    int v16;
    unsigned long long v18;
    unsigned long long v19;
    int v17;
    unsigned long long v20;
    int v21;
    unsigned long long v22;
    int v23;
    unsigned long long v25;
    unsigned long long v26;
    int v24;
    unsigned long long v27;
    int v28;
    unsigned long long v29;
    int v30;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[8] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[8] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 5
    // LINE: 5
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 7
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 9
    *((int*)v0) = 42ll;
    // LINE: 10
    v9 = v0;
    v10 = (unsigned long long)v9;
    *((unsigned long long*)v2) = v10;
    // LINE: 11
    v12 = (unsigned long long)0ll;
    *((unsigned long long*)v4) = v12;
    // LINE: 13
    v13 = (unsigned long long)str0;
    v14 = *((unsigned long long*)v2);
    v15 = *((int*)v14);
    v16 = printf(v13, v15    );
    // LINE: 15
    v18 = *((unsigned long long*)v2);
    v19 = (unsigned long long)0ll;
    v17 = v18 == v19;
    if(v17 == 0) goto l0;
    // LINE: 16
    v20 = (unsigned long long)str1;
    v21 = printf(v20    );
    goto l1;
    l0: (void)noop;
    // LINE: 18
    v22 = (unsigned long long)str2;
    v23 = printf(v22    );
    l1: (void)noop;
    // LINE: 20
    v25 = *((unsigned long long*)v4);
    v26 = (unsigned long long)0ll;
    v24 = v25 == v26;
    if(v24 == 0) goto l2;
    // LINE: 21
    v27 = (unsigned long long)str3;
    v28 = printf(v27    );
    goto l3;
    l2: (void)noop;
    // LINE: 23
    v29 = (unsigned long long)str4;
    v30 = printf(v29    );
    l3: (void)noop;
    // LINE: 25
    return 0ll;
}
int main(int argc, char **args) { return entry(); }