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
37, 100, 44, 32, 37, 100, 10, 0, },
};
void *str1 = &_g1;
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
    int v9;
    unsigned long long v10;
    int v11;
    unsigned long long v12;
    int v13;
    unsigned long long v14;
    int v15;
    unsigned long long v22;
    int v24;
    int v25;
    int v23;
    int v26;
    unsigned long long v27;
    int v30;
    int v31;
    int v29;
    int v32;
    unsigned long long v33;
    int v35;
    int v34;
    int v37;
    int v38;
    int v36;
    int v39;
    unsigned long long v40;
    int v42;
    int v41;
    int v44;
    int v45;
    int v43;
    int v46;
    unsigned long long v47;
    int v50;
    int v51;
    int v49;
    int v48;
    int v52;
    int v53;
    unsigned long long v54;
    int v57;
    int v58;
    int v56;
    int v55;
    int v59;
    int v60;
    unsigned long long v61;
    int v63;
    int v65;
    int v66;
    int v64;
    int v62;
    int v67;
    unsigned long long v68;
    int v70;
    int v72;
    int v74;
    int v75;
    int v73;
    int v71;
    int v69;
    int v76;
    unsigned long long v77;
    int v79;
    int v80;
    int v78;
    int v82;
    int v83;
    int v81;
    int v84;
    unsigned long long v85;
    int v87;
    int v88;
    int v86;
    int v90;
    int v91;
    int v89;
    int v92;
    unsigned long long v93;
    int v96;
    int v97;
    int v95;
    int v99;
    int v100;
    int v98;
    int v94;
    int v101;
    unsigned long long v102;
    int v104;
    int v107;
    int v108;
    int v106;
    int v109;
    int v105;
    int v103;
    int v110;
    unsigned long long v111;
    int v113;
    int v116;
    int v117;
    int v115;
    int v118;
    int v114;
    int v112;
    int v119;
    unsigned long long v120;
    int v121;
    int v122;
    unsigned long long v123;
    int v124;
    int v125;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v2[4] __attribute__((aligned(16)));
    v2 = (unsigned long long)alloca_v2;
    char alloca_v4[4] __attribute__((aligned(16)));
    v4 = (unsigned long long)alloca_v4;
    char alloca_v6[4] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    char alloca_v8[4] __attribute__((aligned(16)));
    v8 = (unsigned long long)alloca_v8;
    char alloca_v10[4] __attribute__((aligned(16)));
    v10 = (unsigned long long)alloca_v10;
    char alloca_v12[4] __attribute__((aligned(16)));
    v12 = (unsigned long long)alloca_v12;
    char alloca_v14[4] __attribute__((aligned(16)));
    v14 = (unsigned long long)alloca_v14;
    // LINE: 5
    // LINE: 5
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 6
    v3 = memset(v2, 0ll, 8ll    );
    // LINE: 7
    v5 = memset(v4, 0ll, 8ll    );
    // LINE: 8
    v7 = memset(v6, 0ll, 8ll    );
    // LINE: 9
    v9 = memset(v8, 0ll, 8ll    );
    // LINE: 10
    v11 = memset(v10, 0ll, 8ll    );
    // LINE: 11
    v13 = memset(v12, 0ll, 8ll    );
    // LINE: 12
    v15 = memset(v14, 0ll, 8ll    );
    // LINE: 14
    *((int*)v0) = 12ll;
    // LINE: 15
    *((int*)v2) = 34ll;
    // LINE: 16
    *((int*)v4) = 56ll;
    // LINE: 17
    *((int*)v6) = 78ll;
    // LINE: 18
    *((int*)v8) = 0ll;
    // LINE: 19
    *((int*)v10) = 1ll;
    // LINE: 21
    v22 = (unsigned long long)str0;
    v24 = *((int*)v4);
    v25 = *((int*)v6);
    v23 = v24 + v25;
    v26 = printf(v22, v23    );
    // LINE: 22
    v27 = (unsigned long long)str0;
    v30 = *((int*)v4);
    v31 = *((int*)v6);
    v29 = v30 + v31;
    *((int*)v14) = v29;
    v32 = printf(v27, v29    );
    // LINE: 23
    v33 = (unsigned long long)str0;
    v35 = *((int*)v8);
    v34 = v35 != 0ll;
    if(v35 != 0) goto l0;
    v37 = *((int*)v8);
    if(v37 == 0) goto l1;
    v38 = *((int*)v10);
    v36 = v38 != 0ll;
    goto l2;
    l1: (void)noop;
    v36 = 0ll;
    l2: (void)noop;
    v34 = v36 != 0ll;
    l0: (void)noop;
    v39 = printf(v33, v34    );
    // LINE: 24
    v40 = (unsigned long long)str0;
    v42 = *((int*)v8);
    v41 = v42 != 0ll;
    if(v42 != 0) goto l3;
    v44 = *((int*)v10);
    if(v44 == 0) goto l4;
    v45 = *((int*)v10);
    v43 = v45 != 0ll;
    goto l5;
    l4: (void)noop;
    v43 = 0ll;
    l5: (void)noop;
    v41 = v43 != 0ll;
    l3: (void)noop;
    v46 = printf(v40, v41    );
    // LINE: 25
    v47 = (unsigned long long)str0;
    v50 = *((int*)v8);
    if(v50 == 0) goto l7;
    v51 = *((int*)v8);
    v49 = v51 != 0ll;
    goto l8;
    l7: (void)noop;
    v49 = 0ll;
    l8: (void)noop;
    v48 = v49 != 0ll;
    if(v49 != 0) goto l6;
    v52 = *((int*)v10);
    v48 = v52 != 0ll;
    l6: (void)noop;
    v53 = printf(v47, v48    );
    // LINE: 26
    v54 = (unsigned long long)str0;
    v57 = *((int*)v8);
    if(v57 == 0) goto l10;
    v58 = *((int*)v10);
    v56 = v58 != 0ll;
    goto l11;
    l10: (void)noop;
    v56 = 0ll;
    l11: (void)noop;
    v55 = v56 != 0ll;
    if(v56 != 0) goto l9;
    v59 = *((int*)v10);
    v55 = v59 != 0ll;
    l9: (void)noop;
    v60 = printf(v54, v55    );
    // LINE: 27
    v61 = (unsigned long long)str0;
    v63 = *((int*)v0);
    if(v63 == 0) goto l12;
    v65 = *((int*)v10);
    v66 = *((int*)v10);
    v64 = v65 | v66;
    v62 = v64 != 0ll;
    goto l13;
    l12: (void)noop;
    v62 = 0ll;
    l13: (void)noop;
    v67 = printf(v61, v62    );
    // LINE: 28
    v68 = (unsigned long long)str0;
    v70 = *((int*)v0);
    v72 = *((int*)v2);
    v74 = *((int*)v4);
    v75 = *((int*)v6);
    v73 = v74 & v75;
    v71 = v72 ^ v73;
    v69 = v70 | v71;
    v76 = printf(v68, v69    );
    // LINE: 29
    v77 = (unsigned long long)str1;
    v79 = *((int*)v0);
    v80 = *((int*)v0);
    v78 = v79 == v80;
    v82 = *((int*)v0);
    v83 = *((int*)v2);
    v81 = v82 == v83;
    v84 = printf(v77, v78, v81    );
    // LINE: 30
    v85 = (unsigned long long)str1;
    v87 = *((int*)v0);
    v88 = *((int*)v0);
    v86 = v87 != v88;
    v90 = *((int*)v0);
    v91 = *((int*)v2);
    v89 = v90 != v91;
    v92 = printf(v85, v86, v89    );
    // LINE: 31
    v93 = (unsigned long long)str0;
    v96 = *((int*)v0);
    v97 = *((int*)v2);
    v95 = v96 != v97;
    if(v95 == 0) goto l14;
    v99 = *((int*)v4);
    v100 = *((int*)v6);
    v98 = v99 != v100;
    v94 = v98 != 0ll;
    goto l15;
    l14: (void)noop;
    v94 = 0ll;
    l15: (void)noop;
    v101 = printf(v93, v94    );
    // LINE: 32
    v102 = (unsigned long long)str0;
    v104 = *((int*)v0);
    v107 = *((int*)v2);
    v108 = *((int*)v4);
    v106 = v107 * v108;
    v109 = *((int*)v10);
    v105 = v106 / v109;
    v103 = v104 + v105;
    v110 = printf(v102, v103    );
    // LINE: 33
    v111 = (unsigned long long)str0;
    v113 = *((int*)v0);
    v116 = *((int*)v2);
    v117 = *((int*)v4);
    v115 = v116 * v117;
    v118 = *((int*)v10);
    v114 = v115 / v118;
    v112 = v113 + v114;
    v119 = printf(v111, v112    );
    // LINE: 34
    v120 = (unsigned long long)str0;
    v121 = 4ll << 4ll;
    v122 = printf(v120, v121    );
    // LINE: 35
    v123 = (unsigned long long)str0;
    v124 = 64ll >> 4ll;
    v125 = printf(v123, v124    );
    // LINE: 37
    return 0ll;
}
int main(int argc, char **args) { return entry(); }