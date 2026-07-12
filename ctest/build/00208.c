__attribute__((aligned(8))) struct { 

    char b0[24];

}_g0 = {
.b0 = {
},
};
__attribute__((aligned(1))) struct { 

    char b0[5];

}_g1 = {
.b0 = {
98, 117, 103, 115, 0, },
};
void *str1 = &_g1;
__attribute__((aligned(1))) struct { 

    char b0[5];

}_g2 = {
.b0 = {
98, 108, 97, 10, 0, },
};
void *str2 = &_g2;
__attribute__((aligned(1))) struct { 

    char b0[7];

}_g3 = {
.b0 = {
110, 111, 110, 111, 110, 111, 0, },
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
extern int f1char() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v8;
    char v12;
    char v13;
    char alloca_v0[9] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v4[16] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 9
    // LINE: 9
    v1 = memset(v0, 0ll, 16ll    );
    v2 = (unsigned long long)str0;
    v3 = memcpy(v0, v2, 7ll    );
    // LINE: 10
    v5 = memset(v4, 0ll, 16ll    );
    v6 = (unsigned long long)str1;
    v7 = memcpy(v4, v6, 5ll    );
    // LINE: 11
    v9 = v0;
    v10 = (unsigned long long)0ll;
    v11 = v10 * 1llu;
    v8 = v9 + v11;
    v12 = *((char*)v8);
    v13 = v12 == 0ll;
    return v13;
}
extern int f1int() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v8;
    char v12;
    char v13;
    char alloca_v0[9] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v4[16] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 14
    // LINE: 14
    v1 = memset(v0, 0ll, 16ll    );
    v2 = (unsigned long long)str0;
    v3 = memcpy(v0, v2, 7ll    );
    // LINE: 15
    v5 = memset(v4, 0ll, 16ll    );
    v6 = (unsigned long long)str1;
    v7 = memcpy(v4, v6, 5ll    );
    // LINE: 16
    v9 = v0;
    v10 = (unsigned long long)0ll;
    v11 = v10 * 1llu;
    v8 = v9 + v11;
    v12 = *((char*)v8);
    v13 = v12 == 0ll;
    return v13;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    unsigned long long v4;
    int v5;
    unsigned long long v6;
    int v7;
    unsigned long long v8;
    char v9;
    int v11;
    int v10;
    int v12;
    unsigned long long v13;
    int v14;
    unsigned long long v16;
    unsigned long long v17;
    unsigned long long v18;
    unsigned long long v15;
    char v19;
    char v20;
    char alloca_v0[9] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v4[16] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    // LINE: 19
    // LINE: 19
    v1 = memset(v0, 0ll, 16ll    );
    v2 = (unsigned long long)str0;
    v3 = memcpy(v0, v2, 7ll    );
    // LINE: 20
    v5 = memset(v4, 0ll, 16ll    );
    v6 = (unsigned long long)str1;
    v7 = memcpy(v4, v6, 5ll    );
    v8 = v4 + 8llu;
    v9 = (char)99ll;
    *((char*)v8) = v9;
    // LINE: 22
    v11 = f1char(    );
    v10 = v11 != 0ll;
    if(v11 != 0) goto l2;
    v12 = f1int(    );
    v10 = v12 != 0ll;
    l2: (void)noop;
    if(v10 == 0) goto l0;
    // LINE: 23
    v13 = (unsigned long long)str2;
    v14 = printf(v13    );
    goto l1;
    l0: (void)noop;
    l1: (void)noop;
    // LINE: 24
    v16 = v0;
    v17 = (unsigned long long)0ll;
    v18 = v17 * 1llu;
    v15 = v16 + v18;
    v19 = *((char*)v15);
    v20 = v19 == 0ll;
    return v20;
}
int main(int argc, char **args) { return entry(); }