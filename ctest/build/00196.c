__attribute__((aligned(1))) struct { 

    char b0[5];

}_g0 = {
.b0 = {
106, 111, 101, 10, 0, },
};
void *str1 = &_g0;
__attribute__((aligned(1))) struct { 

    char b0[6];

}_g1 = {
.b0 = {
102, 114, 101, 100, 10, 0, },
};
void *str0 = &_g1;
__attribute__((aligned(1))) struct { 

    char b0[4];

}_g2 = {
.b0 = {
37, 100, 10, 0, },
};
void *str2 = &_g2;
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
extern int fred() {
    unsigned long long v0;
    int v1;
    // LINE: 5
    // LINE: 5
    v0 = (unsigned long long)str0;
    v1 = printf(v0    );
    // LINE: 6
    return 0ll;
}
extern int joe() {
    unsigned long long v0;
    int v1;
    // LINE: 11
    // LINE: 11
    v0 = (unsigned long long)str1;
    v1 = printf(v0    );
    // LINE: 12
    return 1ll;
}
extern int entry() {
    unsigned long long v0;
    int v2;
    int v3;
    int v1;
    int v4;
    unsigned long long v5;
    int v7;
    int v6;
    int v8;
    int v9;
    unsigned long long v10;
    int v12;
    int v13;
    int v11;
    int v14;
    unsigned long long v15;
    int v17;
    int v16;
    int v18;
    int v19;
    unsigned long long v20;
    int v22;
    int v24;
    int v23;
    int v21;
    int v25;
    unsigned long long v26;
    int v28;
    int v27;
    int v30;
    int v29;
    int v31;
    unsigned long long v32;
    int v34;
    int v36;
    int v35;
    int v33;
    int v37;
    unsigned long long v38;
    int v40;
    int v39;
    int v42;
    int v41;
    int v43;
    // LINE: 17
    // LINE: 17
    v0 = (unsigned long long)str2;
    v2 = fred(    );
    if(v2 == 0) goto l0;
    v3 = joe(    );
    v1 = v3 != 0ll;
    goto l1;
    l0: (void)noop;
    v1 = 0ll;
    l1: (void)noop;
    v4 = printf(v0, v1    );
    // LINE: 18
    v5 = (unsigned long long)str2;
    v7 = fred(    );
    v6 = v7 != 0ll;
    if(v7 != 0) goto l2;
    v8 = joe(    );
    v6 = v8 != 0ll;
    l2: (void)noop;
    v9 = printf(v5, v6    );
    // LINE: 19
    v10 = (unsigned long long)str2;
    v12 = joe(    );
    if(v12 == 0) goto l3;
    v13 = fred(    );
    v11 = v13 != 0ll;
    goto l4;
    l3: (void)noop;
    v11 = 0ll;
    l4: (void)noop;
    v14 = printf(v10, v11    );
    // LINE: 20
    v15 = (unsigned long long)str2;
    v17 = joe(    );
    v16 = v17 != 0ll;
    if(v17 != 0) goto l5;
    v18 = fred(    );
    v16 = v18 != 0ll;
    l5: (void)noop;
    v19 = printf(v15, v16    );
    // LINE: 21
    v20 = (unsigned long long)str2;
    v22 = fred(    );
    if(v22 == 0) goto l6;
    v24 = joe(    );
    v23 = 1ll + v24;
    v21 = v23 != 0ll;
    goto l7;
    l6: (void)noop;
    v21 = 0ll;
    l7: (void)noop;
    v25 = printf(v20, v21    );
    // LINE: 22
    v26 = (unsigned long long)str2;
    v28 = fred(    );
    v27 = v28 != 0ll;
    if(v28 != 0) goto l8;
    v30 = joe(    );
    v29 = 0ll + v30;
    v27 = v29 != 0ll;
    l8: (void)noop;
    v31 = printf(v26, v27    );
    // LINE: 23
    v32 = (unsigned long long)str2;
    v34 = joe(    );
    if(v34 == 0) goto l9;
    v36 = fred(    );
    v35 = 0ll + v36;
    v33 = v35 != 0ll;
    goto l10;
    l9: (void)noop;
    v33 = 0ll;
    l10: (void)noop;
    v37 = printf(v32, v33    );
    // LINE: 24
    v38 = (unsigned long long)str2;
    v40 = joe(    );
    v39 = v40 != 0ll;
    if(v40 != 0) goto l11;
    v42 = fred(    );
    v41 = 1ll + v42;
    v39 = v41 != 0ll;
    l11: (void)noop;
    v43 = printf(v38, v39    );
    // LINE: 26
    return 0ll;
}
int main(int argc, char **args) { return entry(); }