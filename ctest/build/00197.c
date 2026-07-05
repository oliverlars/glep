__attribute__((aligned(4))) struct { 

    char b0[4];

}_g0 = {
.b0 = {
210, 4, 0, 0, },
};
void *fred = &_g0;
__attribute__((aligned(4))) struct { 

    char b0[4];

}_g1 = {
.b0 = {
},
};
void *joe = &_g1;
__attribute__((aligned(1))) struct { 

    char b0[4];

}_g2 = {
.b0 = {
37, 100, 10, 0, },
};
void *str0 = &_g2;
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
extern void henry() {
    unsigned long long v0;
    int v1;
    unsigned long long v2;
    int v3;
    int v4;
    int v6;
    int v7;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 8
    // LINE: 8
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = 4567ll;
    // LINE: 10
    v2 = (unsigned long long)str0;
    v3 = *((int*)v0);
    v4 = printf(v2, v3    );
    // LINE: 11
    v6 = *((int*)v0);
    v7 = v6 + 1ll;
    *((int*)v0) = v7;
}
extern int entry() {
    unsigned long long v0;
    unsigned long long v1;
    int v2;
    int v3;
    unsigned long long v4;
    unsigned long long v5;
    int v6;
    int v7;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    int v12;
    int v13;
    unsigned long long v14;
    unsigned long long v15;
    int v16;
    int v17;
    // LINE: 16
    // LINE: 16
    v0 = (unsigned long long)str0;
    v1 = (unsigned long long)fred;
    v2 = *((int*)v1);
    v3 = printf(v0, v2    );
    // LINE: 17
    henry(    );
    // LINE: 18
    henry(    );
    // LINE: 19
    henry(    );
    // LINE: 20
    henry(    );
    // LINE: 21
    v4 = (unsigned long long)str0;
    v5 = (unsigned long long)fred;
    v6 = *((int*)v5);
    v7 = printf(v4, v6    );
    // LINE: 22
    v8 = (unsigned long long)fred;
    *((int*)v8) = 8901ll;
    // LINE: 23
    v9 = (unsigned long long)joe;
    *((int*)v9) = 2345ll;
    // LINE: 24
    v10 = (unsigned long long)str0;
    v11 = (unsigned long long)fred;
    v12 = *((int*)v11);
    v13 = printf(v10, v12    );
    // LINE: 25
    v14 = (unsigned long long)str0;
    v15 = (unsigned long long)joe;
    v16 = *((int*)v15);
    v17 = printf(v14, v16    );
    // LINE: 27
    return 0ll;
}
int main(int argc, char **args) { return entry(); }