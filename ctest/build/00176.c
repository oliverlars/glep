__attribute__((aligned(8))) struct { 

    char b0[24];

}_g0 = {
.b0 = {
},
};
__attribute__((aligned(4))) struct { 

    char b0[64];

}_g1 = {
.b0 = {
},
};
void *array = &_g1;
__attribute__((aligned(1))) struct { 

    char b0[4];

}_g2 = {
.b0 = {
37, 100, 32, 0, },
};
void *str0 = &_g2;
__attribute__((aligned(1))) struct { 

    char b0[2];

}_g3 = {
.b0 = {
10, 0, },
};
void *str1 = &_g3;
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
extern void swap(int v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
    int v7;
    int v9;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v12;
    unsigned long long v13;
    unsigned long long v8;
    int v14;
    int v16;
    unsigned long long v17;
    unsigned long long v18;
    unsigned long long v19;
    unsigned long long v20;
    unsigned long long v15;
    int v22;
    unsigned long long v23;
    unsigned long long v24;
    unsigned long long v25;
    unsigned long long v26;
    unsigned long long v21;
    int v27;
    int v29;
    unsigned long long v30;
    unsigned long long v31;
    unsigned long long v32;
    unsigned long long v33;
    unsigned long long v28;
    int v34;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v6[4] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 8
    // LINE: 8
    v7 = memset(v6, 0ll, 8ll    );
    v9 = *((int*)v0);
    v10 = (unsigned long long)array;
    v11 = v10;
    v12 = (unsigned long long)v9;
    v13 = v12 * 4llu;
    v8 = v11 + v13;
    v14 = *((int*)v8);
    *((int*)v6) = v14;
    // LINE: 9
    v16 = *((int*)v0);
    v17 = (unsigned long long)array;
    v18 = v17;
    v19 = (unsigned long long)v16;
    v20 = v19 * 4llu;
    v15 = v18 + v20;
    v22 = *((int*)v3);
    v23 = (unsigned long long)array;
    v24 = v23;
    v25 = (unsigned long long)v22;
    v26 = v25 * 4llu;
    v21 = v24 + v26;
    v27 = *((int*)v21);
    *((int*)v15) = v27;
    // LINE: 10
    v29 = *((int*)v3);
    v30 = (unsigned long long)array;
    v31 = v30;
    v32 = (unsigned long long)v29;
    v33 = v32 * 4llu;
    v28 = v31 + v33;
    v34 = *((int*)v6);
    *((int*)v28) = v34;
}
extern int partition(int v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
    int v7;
    int v8;
    unsigned long long v9;
    int v10;
    int v12;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v16;
    unsigned long long v11;
    int v17;
    unsigned long long v18;
    int v19;
    int v20;
    unsigned long long v21;
    int v22;
    int v23;
    int v24;
    int v26;
    int v28;
    int v29;
    int v27;
    int v32;
    unsigned long long v33;
    unsigned long long v34;
    unsigned long long v35;
    unsigned long long v36;
    unsigned long long v31;
    int v37;
    int v38;
    int v30;
    int v39;
    int v40;
    int v43;
    int v42;
    int v45;
    int v46;
    int v47;
    int v48;
    int v49;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v6[4] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    char alloca_v9[4] __attribute__((aligned(16)));
    v9 = (unsigned long long)alloca_v9;
    char alloca_v18[4] __attribute__((aligned(16)));
    v18 = (unsigned long long)alloca_v18;
    char alloca_v21[4] __attribute__((aligned(16)));
    v21 = (unsigned long long)alloca_v21;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 17
    // LINE: 17
    v7 = memset(v6, 0ll, 8ll    );
    v8 = *((int*)v0);
    *((int*)v6) = v8;
    // LINE: 18
    v10 = memset(v9, 0ll, 8ll    );
    v12 = *((int*)v6);
    v13 = (unsigned long long)array;
    v14 = v13;
    v15 = (unsigned long long)v12;
    v16 = v15 * 4llu;
    v11 = v14 + v16;
    v17 = *((int*)v11);
    *((int*)v9) = v17;
    // LINE: 19
    v19 = memset(v18, 0ll, 8ll    );
    v20 = *((int*)v0);
    *((int*)v18) = v20;
    // LINE: 20
    v22 = memset(v21, 0ll, 8ll    );
    // LINE: 22
    v23 = *((int*)v6);
    v24 = *((int*)v3);
    swap(v23, v24    );
    // LINE: 23
    // LINE: 23
    v26 = *((int*)v0);
    *((int*)v21) = v26;
    l0: (void)noop;
    v28 = *((int*)v21);
    v29 = *((int*)v3);
    v27 = v28 < v29;
    if(v27 == 0) goto l1;
    // LINE: 25
    // LINE: 25
    v32 = *((int*)v21);
    v33 = (unsigned long long)array;
    v34 = v33;
    v35 = (unsigned long long)v32;
    v36 = v35 * 4llu;
    v31 = v34 + v36;
    v37 = *((int*)v31);
    v38 = *((int*)v9);
    v30 = v37 < v38;
    if(v30 == 0) goto l3;
    // LINE: 27
    // LINE: 27
    v39 = *((int*)v21);
    v40 = *((int*)v18);
    swap(v39, v40    );
    // LINE: 28
    v43 = *((int*)v18);
    v42 = v43 + 1ll;
    *((int*)v18) = v42;
    goto l4;
    l3: (void)noop;
    l4: (void)noop;
    l2: (void)noop;
    v45 = *((int*)v21);
    v46 = v45 + 1ll;
    *((int*)v21) = v46;
    goto l0;
    l1: (void)noop;
    // LINE: 31
    v47 = *((int*)v3);
    v48 = *((int*)v18);
    swap(v47, v48    );
    // LINE: 33
    v49 = *((int*)v18);
    return v49;
}
extern void quicksort(int v2,
int v5) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    int v7;
    int v8;
    int v6;
    unsigned long long v9;
    int v10;
    int v11;
    int v12;
    int v13;
    int v14;
    int v16;
    int v15;
    int v18;
    int v17;
    int v19;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[4] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v9[4] __attribute__((aligned(16)));
    v9 = (unsigned long long)alloca_v9;
    v1 = memset(v0, 0ll, 8ll    );
    *((int*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((int*)v3) = v5;
    // LINE: 39
    // LINE: 39
    v7 = *((int*)v0);
    v8 = *((int*)v3);
    v6 = v8 <= v7;
    if(v6 == 0) goto l5;
    // LINE: 40
    return;
    goto l6;
    l5: (void)noop;
    l6: (void)noop;
    // LINE: 42
    v10 = memset(v9, 0ll, 8ll    );
    v11 = *((int*)v0);
    v12 = *((int*)v3);
    v13 = partition(v11, v12    );
    *((int*)v9) = v13;
    // LINE: 43
    v14 = *((int*)v0);
    v16 = *((int*)v9);
    v15 = v16 - 1ll;
    quicksort(v14, v15    );
    // LINE: 44
    v18 = *((int*)v9);
    v17 = v18 + 1ll;
    v19 = *((int*)v3);
    quicksort(v17, v19    );
}
extern int entry() {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    unsigned long long v4;
    unsigned long long v5;
    unsigned long long v6;
    unsigned long long v2;
    unsigned long long v8;
    unsigned long long v9;
    unsigned long long v10;
    unsigned long long v11;
    unsigned long long v7;
    unsigned long long v13;
    unsigned long long v14;
    unsigned long long v15;
    unsigned long long v16;
    unsigned long long v12;
    unsigned long long v18;
    unsigned long long v19;
    unsigned long long v20;
    unsigned long long v21;
    unsigned long long v17;
    unsigned long long v23;
    unsigned long long v24;
    unsigned long long v25;
    unsigned long long v26;
    unsigned long long v22;
    unsigned long long v28;
    unsigned long long v29;
    unsigned long long v30;
    unsigned long long v31;
    unsigned long long v27;
    unsigned long long v33;
    unsigned long long v34;
    unsigned long long v35;
    unsigned long long v36;
    unsigned long long v32;
    unsigned long long v38;
    unsigned long long v39;
    unsigned long long v40;
    unsigned long long v41;
    unsigned long long v37;
    unsigned long long v43;
    unsigned long long v44;
    unsigned long long v45;
    unsigned long long v46;
    unsigned long long v42;
    unsigned long long v48;
    unsigned long long v49;
    unsigned long long v50;
    unsigned long long v51;
    unsigned long long v47;
    unsigned long long v53;
    unsigned long long v54;
    unsigned long long v55;
    unsigned long long v56;
    unsigned long long v52;
    unsigned long long v58;
    unsigned long long v59;
    unsigned long long v60;
    unsigned long long v61;
    unsigned long long v57;
    unsigned long long v63;
    unsigned long long v64;
    unsigned long long v65;
    unsigned long long v66;
    unsigned long long v62;
    unsigned long long v68;
    unsigned long long v69;
    unsigned long long v70;
    unsigned long long v71;
    unsigned long long v67;
    unsigned long long v73;
    unsigned long long v74;
    unsigned long long v75;
    unsigned long long v76;
    unsigned long long v72;
    unsigned long long v78;
    unsigned long long v79;
    unsigned long long v80;
    unsigned long long v81;
    unsigned long long v77;
    int v84;
    int v83;
    unsigned long long v85;
    int v87;
    unsigned long long v88;
    unsigned long long v89;
    unsigned long long v90;
    unsigned long long v91;
    unsigned long long v86;
    int v92;
    int v93;
    int v95;
    int v96;
    unsigned long long v97;
    int v98;
    int v101;
    int v100;
    unsigned long long v102;
    int v104;
    unsigned long long v105;
    unsigned long long v106;
    unsigned long long v107;
    unsigned long long v108;
    unsigned long long v103;
    int v109;
    int v110;
    int v112;
    int v113;
    unsigned long long v114;
    int v115;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 49
    // LINE: 49
    v1 = memset(v0, 0ll, 8ll    );
    // LINE: 51
    v3 = (unsigned long long)array;
    v4 = v3;
    v5 = (unsigned long long)0ll;
    v6 = v5 * 4llu;
    v2 = v4 + v6;
    *((int*)v2) = 62ll;
    // LINE: 52
    v8 = (unsigned long long)array;
    v9 = v8;
    v10 = (unsigned long long)1ll;
    v11 = v10 * 4llu;
    v7 = v9 + v11;
    *((int*)v7) = 83ll;
    // LINE: 53
    v13 = (unsigned long long)array;
    v14 = v13;
    v15 = (unsigned long long)2ll;
    v16 = v15 * 4llu;
    v12 = v14 + v16;
    *((int*)v12) = 4ll;
    // LINE: 54
    v18 = (unsigned long long)array;
    v19 = v18;
    v20 = (unsigned long long)3ll;
    v21 = v20 * 4llu;
    v17 = v19 + v21;
    *((int*)v17) = 89ll;
    // LINE: 55
    v23 = (unsigned long long)array;
    v24 = v23;
    v25 = (unsigned long long)4ll;
    v26 = v25 * 4llu;
    v22 = v24 + v26;
    *((int*)v22) = 36ll;
    // LINE: 56
    v28 = (unsigned long long)array;
    v29 = v28;
    v30 = (unsigned long long)5ll;
    v31 = v30 * 4llu;
    v27 = v29 + v31;
    *((int*)v27) = 21ll;
    // LINE: 57
    v33 = (unsigned long long)array;
    v34 = v33;
    v35 = (unsigned long long)6ll;
    v36 = v35 * 4llu;
    v32 = v34 + v36;
    *((int*)v32) = 74ll;
    // LINE: 58
    v38 = (unsigned long long)array;
    v39 = v38;
    v40 = (unsigned long long)7ll;
    v41 = v40 * 4llu;
    v37 = v39 + v41;
    *((int*)v37) = 37ll;
    // LINE: 59
    v43 = (unsigned long long)array;
    v44 = v43;
    v45 = (unsigned long long)8ll;
    v46 = v45 * 4llu;
    v42 = v44 + v46;
    *((int*)v42) = 65ll;
    // LINE: 60
    v48 = (unsigned long long)array;
    v49 = v48;
    v50 = (unsigned long long)9ll;
    v51 = v50 * 4llu;
    v47 = v49 + v51;
    *((int*)v47) = 33ll;
    // LINE: 61
    v53 = (unsigned long long)array;
    v54 = v53;
    v55 = (unsigned long long)10ll;
    v56 = v55 * 4llu;
    v52 = v54 + v56;
    *((int*)v52) = 96ll;
    // LINE: 62
    v58 = (unsigned long long)array;
    v59 = v58;
    v60 = (unsigned long long)11ll;
    v61 = v60 * 4llu;
    v57 = v59 + v61;
    *((int*)v57) = 38ll;
    // LINE: 63
    v63 = (unsigned long long)array;
    v64 = v63;
    v65 = (unsigned long long)12ll;
    v66 = v65 * 4llu;
    v62 = v64 + v66;
    *((int*)v62) = 53ll;
    // LINE: 64
    v68 = (unsigned long long)array;
    v69 = v68;
    v70 = (unsigned long long)13ll;
    v71 = v70 * 4llu;
    v67 = v69 + v71;
    *((int*)v67) = 16ll;
    // LINE: 65
    v73 = (unsigned long long)array;
    v74 = v73;
    v75 = (unsigned long long)14ll;
    v76 = v75 * 4llu;
    v72 = v74 + v76;
    *((int*)v72) = 74ll;
    // LINE: 66
    v78 = (unsigned long long)array;
    v79 = v78;
    v80 = (unsigned long long)15ll;
    v81 = v80 * 4llu;
    v77 = v79 + v81;
    *((int*)v77) = 55ll;
    // LINE: 68
    // LINE: 68
    *((int*)v0) = 0ll;
    l7: (void)noop;
    v84 = *((int*)v0);
    v83 = v84 < 16ll;
    if(v83 == 0) goto l8;
    // LINE: 69
    v85 = (unsigned long long)str0;
    v87 = *((int*)v0);
    v88 = (unsigned long long)array;
    v89 = v88;
    v90 = (unsigned long long)v87;
    v91 = v90 * 4llu;
    v86 = v89 + v91;
    v92 = *((int*)v86);
    v93 = printf(v85, v92    );
    l9: (void)noop;
    v95 = *((int*)v0);
    v96 = v95 + 1ll;
    *((int*)v0) = v96;
    goto l7;
    l8: (void)noop;
    // LINE: 71
    v97 = (unsigned long long)str1;
    v98 = printf(v97    );
    // LINE: 73
    quicksort(0ll, 15ll    );
    // LINE: 75
    // LINE: 75
    *((int*)v0) = 0ll;
    l10: (void)noop;
    v101 = *((int*)v0);
    v100 = v101 < 16ll;
    if(v100 == 0) goto l11;
    // LINE: 76
    v102 = (unsigned long long)str0;
    v104 = *((int*)v0);
    v105 = (unsigned long long)array;
    v106 = v105;
    v107 = (unsigned long long)v104;
    v108 = v107 * 4llu;
    v103 = v106 + v108;
    v109 = *((int*)v103);
    v110 = printf(v102, v109    );
    l12: (void)noop;
    v112 = *((int*)v0);
    v113 = v112 + 1ll;
    *((int*)v0) = v113;
    goto l10;
    l11: (void)noop;
    // LINE: 78
    v114 = (unsigned long long)str1;
    v115 = printf(v114    );
    // LINE: 80
    return 0ll;
}
int main(int argc, char **args) { return entry(); }