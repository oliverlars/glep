__attribute__((aligned(8))) struct { 

    char b0[24];

}_g0 = {
.b0 = {
},
};
__attribute__((aligned(1))) struct { 

    char b0[4];

}_g1 = {
.b0 = {
37, 102, 10, 0, },
};
void *str0 = &_g1;
__attribute__((aligned(1))) struct { 

    char b0[19];

}_g2 = {
.b0 = {
37, 100, 32, 37, 100, 32, 37, 100, 32, 37, 100, 32, 37, 100, 32, 37, 100, 10, 0, },
};
void *str1 = &_g2;
unsigned long long memset(unsigned long long, int, unsigned int);
unsigned long long memcpy(unsigned long long, unsigned long long, unsigned int);
int noop = 0;
extern char __stdinp[];
extern char __stdoutp[];
extern char __stderrp[];
extern char sys_nerr[];
extern char sys_errlist[];
extern char signgam[];
typedef struct __sincosf_stret_return {
float r0;float r1;} __sincosf_stret_return;
typedef struct __sincos_stret_return {
double r0;double r1;} __sincos_stret_return;
typedef struct __sincospif_stret_return {
float r0;float r1;} __sincospif_stret_return;
typedef struct __sincospi_stret_return {
double r0;double r1;} __sincospi_stret_return;
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
int __math_errhandling();
int __fpclassifyf(float);
int __fpclassifyd(double);
int __fpclassifyl(double);
int __isnormalf(float);
int __isnormald(double);
int __isnormall(double);
int __isfinitef(float);
int __isfinited(double);
int __isfinitel(double);
int __isinff(float);
int __isinfd(double);
int __isinfl(double);
int __isnanf(float);
int __isnand(double);
int __isnanl(double);
int __signbitf(float);
int __signbitd(double);
int __signbitl(double);
float acosf(float);
double acos(double);
double acosl(double);
float asinf(float);
double asin(double);
double asinl(double);
float atanf(float);
double atan(double);
double atanl(double);
float atan2f(float,float);
double atan2(double,double);
double atan2l(double,double);
float cosf(float);
double cos(double);
double cosl(double);
float sinf(float);
double sin(double);
double sinl(double);
float tanf(float);
double tan(double);
double tanl(double);
float acoshf(float);
double acosh(double);
double acoshl(double);
float asinhf(float);
double asinh(double);
double asinhl(double);
float atanhf(float);
double atanh(double);
double atanhl(double);
float coshf(float);
double cosh(double);
double coshl(double);
float sinhf(float);
double sinh(double);
double sinhl(double);
float tanhf(float);
double tanh(double);
double tanhl(double);
float expf(float);
double exp(double);
double expl(double);
float exp2f(float);
double exp2(double);
double exp2l(double);
float expm1f(float);
double expm1(double);
double expm1l(double);
float logf(float);
double log(double);
double logl(double);
float log10f(float);
double log10(double);
double log10l(double);
float log2f(float);
double log2(double);
double log2l(double);
float log1pf(float);
double log1p(double);
double log1pl(double);
float logbf(float);
double logb(double);
double logbl(double);
float modff(float,unsigned long long);
double modf(double,unsigned long long);
double modfl(double,unsigned long long);
float ldexpf(float,int);
double ldexp(double,int);
double ldexpl(double,int);
float frexpf(float,unsigned long long);
double frexp(double,unsigned long long);
double frexpl(double,unsigned long long);
int ilogbf(float);
int ilogb(double);
int ilogbl(double);
float scalbnf(float,int);
double scalbn(double,int);
double scalbnl(double,int);
float scalblnf(float,long long);
double scalbln(double,long long);
double scalblnl(double,long long);
float fabsf(float);
double fabs(double);
double fabsl(double);
float cbrtf(float);
double cbrt(double);
double cbrtl(double);
float hypotf(float,float);
double hypot(double,double);
double hypotl(double,double);
float powf(float,float);
double pow(double,double);
double powl(double,double);
float sqrtf(float);
double sqrt(double);
double sqrtl(double);
float erff(float);
double erf(double);
double erfl(double);
float erfcf(float);
double erfc(double);
double erfcl(double);
float lgammaf(float);
double lgamma(double);
double lgammal(double);
float tgammaf(float);
double tgamma(double);
double tgammal(double);
float ceilf(float);
double ceil(double);
double ceill(double);
float floorf(float);
double floor(double);
double floorl(double);
float nearbyintf(float);
double nearbyint(double);
double nearbyintl(double);
float rintf(float);
double rint(double);
double rintl(double);
long long lrintf(float);
long long lrint(double);
long long lrintl(double);
float roundf(float);
double round(double);
double roundl(double);
long long lroundf(float);
long long lround(double);
long long lroundl(double);
long long llrintf(float);
long long llrint(double);
long long llrintl(double);
long long llroundf(float);
long long llround(double);
long long llroundl(double);
float truncf(float);
double trunc(double);
double truncl(double);
float fmodf(float,float);
double fmod(double,double);
double fmodl(double,double);
float remainderf(float,float);
double remainder(double,double);
double remainderl(double,double);
float remquof(float,float,unsigned long long);
double remquo(double,double,unsigned long long);
double remquol(double,double,unsigned long long);
float copysignf(float,float);
double copysign(double,double);
double copysignl(double,double);
float nanf(unsigned long long);
double nan(unsigned long long);
double nanl(unsigned long long);
float nextafterf(float,float);
double nextafter(double,double);
double nextafterl(double,double);
double nexttoward(double,double);
float nexttowardf(float,double);
double nexttowardl(double,double);
float fdimf(float,float);
double fdim(double,double);
double fdiml(double,double);
float fmaxf(float,float);
double fmax(double,double);
double fmaxl(double,double);
float fminf(float,float);
double fmin(double,double);
double fminl(double,double);
float fmaf(float,float,float);
double fma(double,double,double);
double fmal(double,double,double);
float __exp10f(float);
double __exp10(double);
void __sincosf(float,unsigned long long,unsigned long long);
void __sincos(double,unsigned long long,unsigned long long);
float __cospif(float);
double __cospi(double);
float __sinpif(float);
double __sinpi(double);
float __tanpif(float);
double __tanpi(double);
int __fabsf16(int);
int __hypotf16(int,int);
int __sqrtf16(int);
int __ceilf16(int);
int __floorf16(int);
int __rintf16(int);
int __roundf16(int);
int __truncf16(int);
int __copysignf16(int,int);
int __nextafterf16(int,int);
int __fmaxf16(int,int);
int __fminf16(int,int);
int __fmaf16(int,int,int);
void __sincospif(float,unsigned long long,unsigned long long);
void __sincospi(double,unsigned long long,unsigned long long);
__sincosf_stret_return __sincosf_stret(float);
__sincos_stret_return __sincos_stret(double);
__sincospif_stret_return __sincospif_stret(float);
__sincospi_stret_return __sincospi_stret(double);
double j0(double);
double j1(double);
double jn(int,double);
double y0(double);
double y1(double);
double yn(int,double);
double scalb(double,double);
extern void __sincosf(float v2,
unsigned long long v5,
unsigned long long v8) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    int v10;
    float v11;
    unsigned long long v12;
    unsigned long long v13;
    int v14;
    unsigned long long v16;
    unsigned long long v17;
    float v19;
    unsigned long long v21;
    unsigned long long v22;
    float v24;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[8] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v6[8] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    char alloca_v9[8] __attribute__((aligned(16)));
    v9 = (unsigned long long)alloca_v9;
    char alloca_v12[8] __attribute__((aligned(16)));
    v12 = (unsigned long long)alloca_v12;
    v1 = memset(v0, 0ll, 8ll    );
    *((float*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((unsigned long long*)v3) = v5;
    v7 = memset(v6, 0ll, 8ll    );
    *((unsigned long long*)v6) = v8;
    // LINE: 700
    // LINE: 700
    v10 = memset(v9, 0ll, 8ll    );
    v11 = *((float*)v0);
    *((__sincosf_stret_return*)v12) = __sincosf_stret(v11    );
    v13 = v12;
    v14 = memcpy(v9, v13, 8ll    );
    // LINE: 701
    v16 = *((unsigned long long*)v3);
    v17 = v9 + 0llu;
    v19 = *((float*)v17);
    *((float*)v16) = v19;
    // LINE: 701
    v21 = *((unsigned long long*)v6);
    v22 = v9 + 4llu;
    v24 = *((float*)v22);
    *((float*)v21) = v24;
}
extern void __sincos(double v2,
unsigned long long v5,
unsigned long long v8) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    int v10;
    double v11;
    unsigned long long v12;
    unsigned long long v13;
    int v14;
    unsigned long long v16;
    unsigned long long v17;
    double v19;
    unsigned long long v21;
    unsigned long long v22;
    double v24;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[8] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v6[8] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    char alloca_v9[16] __attribute__((aligned(16)));
    v9 = (unsigned long long)alloca_v9;
    char alloca_v12[16] __attribute__((aligned(16)));
    v12 = (unsigned long long)alloca_v12;
    v1 = memset(v0, 0ll, 8ll    );
    *((double*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((unsigned long long*)v3) = v5;
    v7 = memset(v6, 0ll, 8ll    );
    *((unsigned long long*)v6) = v8;
    // LINE: 705
    // LINE: 705
    v10 = memset(v9, 0ll, 16ll    );
    v11 = *((double*)v0);
    *((__sincos_stret_return*)v12) = __sincos_stret(v11    );
    v13 = v12;
    v14 = memcpy(v9, v13, 16ll    );
    // LINE: 706
    v16 = *((unsigned long long*)v3);
    v17 = v9 + 0llu;
    v19 = *((double*)v17);
    *((double*)v16) = v19;
    // LINE: 706
    v21 = *((unsigned long long*)v6);
    v22 = v9 + 8llu;
    v24 = *((double*)v22);
    *((double*)v21) = v24;
}
extern void __sincospif(float v2,
unsigned long long v5,
unsigned long long v8) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    int v10;
    float v11;
    unsigned long long v12;
    unsigned long long v13;
    int v14;
    unsigned long long v16;
    unsigned long long v17;
    float v19;
    unsigned long long v21;
    unsigned long long v22;
    float v24;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[8] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v6[8] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    char alloca_v9[8] __attribute__((aligned(16)));
    v9 = (unsigned long long)alloca_v9;
    char alloca_v12[8] __attribute__((aligned(16)));
    v12 = (unsigned long long)alloca_v12;
    v1 = memset(v0, 0ll, 8ll    );
    *((float*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((unsigned long long*)v3) = v5;
    v7 = memset(v6, 0ll, 8ll    );
    *((unsigned long long*)v6) = v8;
    // LINE: 710
    // LINE: 710
    v10 = memset(v9, 0ll, 8ll    );
    v11 = *((float*)v0);
    *((__sincospif_stret_return*)v12) = __sincospif_stret(v11    );
    v13 = v12;
    v14 = memcpy(v9, v13, 8ll    );
    // LINE: 711
    v16 = *((unsigned long long*)v3);
    v17 = v9 + 0llu;
    v19 = *((float*)v17);
    *((float*)v16) = v19;
    // LINE: 711
    v21 = *((unsigned long long*)v6);
    v22 = v9 + 4llu;
    v24 = *((float*)v22);
    *((float*)v21) = v24;
}
extern void __sincospi(double v2,
unsigned long long v5,
unsigned long long v8) {
    unsigned long long v0;
    int v1;
    unsigned long long v3;
    int v4;
    unsigned long long v6;
    int v7;
    unsigned long long v9;
    int v10;
    double v11;
    unsigned long long v12;
    unsigned long long v13;
    int v14;
    unsigned long long v16;
    unsigned long long v17;
    double v19;
    unsigned long long v21;
    unsigned long long v22;
    double v24;
    char alloca_v0[8] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    char alloca_v3[8] __attribute__((aligned(16)));
    v3 = (unsigned long long)alloca_v3;
    char alloca_v6[8] __attribute__((aligned(16)));
    v6 = (unsigned long long)alloca_v6;
    char alloca_v9[16] __attribute__((aligned(16)));
    v9 = (unsigned long long)alloca_v9;
    char alloca_v12[16] __attribute__((aligned(16)));
    v12 = (unsigned long long)alloca_v12;
    v1 = memset(v0, 0ll, 8ll    );
    *((double*)v0) = v2;
    v4 = memset(v3, 0ll, 8ll    );
    *((unsigned long long*)v3) = v5;
    v7 = memset(v6, 0ll, 8ll    );
    *((unsigned long long*)v6) = v8;
    // LINE: 715
    // LINE: 715
    v10 = memset(v9, 0ll, 16ll    );
    v11 = *((double*)v0);
    *((__sincospi_stret_return*)v12) = __sincospi_stret(v11    );
    v13 = v12;
    v14 = memcpy(v9, v13, 16ll    );
    // LINE: 716
    v16 = *((unsigned long long*)v3);
    v17 = v9 + 0llu;
    v19 = *((double*)v17);
    *((double*)v16) = v19;
    // LINE: 716
    v21 = *((unsigned long long*)v6);
    v22 = v9 + 8llu;
    v24 = *((double*)v22);
    *((double*)v21) = v24;
}
extern int entry() {
    unsigned long long v0;
    int v1;
    double v2;
    float v3;
    unsigned long long v4;
    float v5;
    int v6;
    unsigned long long v7;
    double v8;
    int v9;
    unsigned long long v10;
    double v11;
    int v12;
    unsigned long long v13;
    double v14;
    int v15;
    unsigned long long v16;
    double v17;
    int v18;
    unsigned long long v19;
    int v20;
    int v21;
    int v22;
    int v23;
    int v24;
    int v25;
    int v26;
    unsigned long long v27;
    int v28;
    int v29;
    int v30;
    int v31;
    int v32;
    int v33;
    int v34;
    unsigned long long v35;
    int v36;
    int v37;
    int v38;
    int v39;
    int v40;
    int v41;
    int v42;
    float v44;
    float v46;
    float v48;
    float v47;
    unsigned long long v49;
    float v50;
    int v51;
    float v53;
    float v55;
    float v57;
    float v56;
    unsigned long long v58;
    float v59;
    int v60;
    float v62;
    float v64;
    float v66;
    float v65;
    unsigned long long v67;
    float v68;
    int v69;
    float v71;
    float v73;
    float v75;
    float v74;
    unsigned long long v76;
    float v77;
    int v78;
    unsigned long long v79;
    int v80;
    unsigned long long v81;
    double v82;
    int v83;
    float v85;
    unsigned long long v86;
    float v87;
    int v88;
    unsigned long long v89;
    double v90;
    int v91;
    char alloca_v0[4] __attribute__((aligned(16)));
    v0 = (unsigned long long)alloca_v0;
    // LINE: 7
    // LINE: 7
    v1 = memset(v0, 0ll, 8ll    );
    v2 = 12.34 + 56.78;
    v3 = (float)v2;
    *((float*)v0) = v3;
    // LINE: 8
    v4 = (unsigned long long)str0;
    v5 = *((float*)v0);
    v6 = printf(v4, v5    );
    // LINE: 11
    v7 = (unsigned long long)str0;
    v8 = 12.34 + 56.78;
    v9 = printf(v7, v8    );
    // LINE: 12
    v10 = (unsigned long long)str0;
    v11 = 12.34 - 56.78;
    v12 = printf(v10, v11    );
    // LINE: 13
    v13 = (unsigned long long)str0;
    v14 = 12.34 * 56.78;
    v15 = printf(v13, v14    );
    // LINE: 14
    v16 = (unsigned long long)str0;
    v17 = 12.34 / 56.78;
    v18 = printf(v16, v17    );
    // LINE: 17
    v19 = (unsigned long long)str1;
    v20 = 12.34 < 56.78;
    v21 = 12.34 <= 56.78;
    v22 = 12.34 == 56.78;
    v23 = 56.78 <= 12.34;
    v24 = 56.78 < 12.34;
    v25 = 12.34 != 56.78;
    v26 = printf(v19, v20, v21, v22, v23, v24, v25    );
    // LINE: 18
    v27 = (unsigned long long)str1;
    v28 = 12.34 < 12.34;
    v29 = 12.34 <= 12.34;
    v30 = 12.34 == 12.34;
    v31 = 12.34 <= 12.34;
    v32 = 12.34 < 12.34;
    v33 = 12.34 != 12.34;
    v34 = printf(v27, v28, v29, v30, v31, v32, v33    );
    // LINE: 19
    v35 = (unsigned long long)str1;
    v36 = 56.78 < 12.34;
    v37 = 56.78 <= 12.34;
    v38 = 56.78 == 12.34;
    v39 = 12.34 <= 56.78;
    v40 = 12.34 < 56.78;
    v41 = 56.78 != 12.34;
    v42 = printf(v35, v36, v37, v38, v39, v40, v41    );
    // LINE: 22
    v44 = (float)12.34;
    *((float*)v0) = v44;
    // LINE: 23
    v46 = (float)56.78;
    v48 = *((float*)v0);
    v47 = v48 + v46;
    *((float*)v0) = v47;
    // LINE: 24
    v49 = (unsigned long long)str0;
    v50 = *((float*)v0);
    v51 = printf(v49, v50    );
    // LINE: 26
    v53 = (float)12.34;
    *((float*)v0) = v53;
    // LINE: 27
    v55 = (float)56.78;
    v57 = *((float*)v0);
    v56 = v57 - v55;
    *((float*)v0) = v56;
    // LINE: 28
    v58 = (unsigned long long)str0;
    v59 = *((float*)v0);
    v60 = printf(v58, v59    );
    // LINE: 30
    v62 = (float)12.34;
    *((float*)v0) = v62;
    // LINE: 31
    v64 = (float)56.78;
    v66 = *((float*)v0);
    v65 = v66 * v64;
    *((float*)v0) = v65;
    // LINE: 32
    v67 = (unsigned long long)str0;
    v68 = *((float*)v0);
    v69 = printf(v67, v68    );
    // LINE: 34
    v71 = (float)12.34;
    *((float*)v0) = v71;
    // LINE: 35
    v73 = (float)56.78;
    v75 = *((float*)v0);
    v74 = v75 / v73;
    *((float*)v0) = v74;
    // LINE: 36
    v76 = (unsigned long long)str0;
    v77 = *((float*)v0);
    v78 = printf(v76, v77    );
    // LINE: 39
    v79 = (unsigned long long)str0;
    v80 = printf(v79, 12.34    );
    // LINE: 40
    v81 = (unsigned long long)str0;
    v82 = -12.34;
    v83 = printf(v81, v82    );
    // LINE: 43
    v85 = (float)2ll;
    *((float*)v0) = v85;
    // LINE: 44
    v86 = (unsigned long long)str0;
    v87 = *((float*)v0);
    v88 = printf(v86, v87    );
    // LINE: 45
    v89 = (unsigned long long)str0;
    v90 = sin(2ll    );
    v91 = printf(v89, v90    );
    // LINE: 47
    return 0ll;
}
int main(int argc, char **args) { return entry(); }