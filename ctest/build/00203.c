__attribute__((aligned(8))) struct { 

    char b0[24];

}_g0 = {
.b0 = {
},
};
__attribute__((aligned(1))) struct { 

    char b0[23];

}_g1 = {
.b0 = {
69, 114, 114, 111, 114, 58, 32, 50, 49, 52, 55, 52, 56, 51, 54, 52, 55, 32, 60, 32, 48, 10, 0, },
};
void *str1 = &_g1;
__attribute__((aligned(1))) struct { 

    char b0[29];

}_g2 = {
.b0 = {
108, 111, 110, 103, 32, 108, 111, 110, 103, 32, 99, 111, 110, 115, 116, 97, 110, 116, 32, 116, 101, 115, 116, 32, 111, 107, 46, 10, 0, },
};
void *str2 = &_g2;
__attribute__((aligned(1))) struct { 

    char b0[24];

}_g3 = {
.b0 = {
69, 114, 114, 111, 114, 58, 32, 48, 32, 60, 32, 45, 50, 49, 52, 55, 52, 56, 51, 54, 52, 56, 10, 0, },
};
void *str0 = &_g3;
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
    long long v2;
    long long v4;
    long long v5;
    int v3;
    unsigned long long v6;
    int v7;
    long long v9;
    int v8;
    unsigned long long v10;
    int v11;
    unsigned long long v12;
    int v13;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 5
    // LINE: 5
    v1 = memset(v0, 0ll, 8ll    );
    v2 = (long long)0ll;
    *((long long*)v0) = v2;
    // LINE: 7
    v4 = *((long long*)v0);
    v5 = -2147483648ll;
    v3 = v4 < v5;
    if(v3 == 0) goto l0;
    // LINE: 8
    // LINE: 8
    v6 = (unsigned long long)str0;
    v7 = printf(v6    );
    // LINE: 9
    return 1ll;
    goto l1;
    l0: (void)noop;
    // LINE: 12
    v9 = *((long long*)v0);
    v8 = 2147483647ll < v9;
    if(v8 == 0) goto l2;
    // LINE: 13
    // LINE: 13
    v10 = (unsigned long long)str1;
    v11 = printf(v10    );
    // LINE: 14
    return 2ll;
    goto l3;
    l2: (void)noop;
    // LINE: 17
    v12 = (unsigned long long)str2;
    v13 = printf(v12    );
    l3: (void)noop;
    l1: (void)noop;
    // LINE: 18
    return 0ll;
}
int main(int argc, char **args) { return entry(); }