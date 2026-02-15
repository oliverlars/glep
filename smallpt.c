// smallpt.c - Minimal path tracer in C
// Based on Kevin Beason's smallpt (2008)
// Compile: cc -O3 -o smallpt smallpt.c -lm

#include <math.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct { double x, y, z; } Vec;

Vec vec(double x, double y, double z) { return (Vec){x, y, z}; }
Vec vadd(Vec a, Vec b)    { return vec(a.x+b.x, a.y+b.y, a.z+b.z); }
Vec vsub(Vec a, Vec b)    { return vec(a.x-b.x, a.y-b.y, a.z-b.z); }
Vec vmul(Vec a, double s) { return vec(a.x*s, a.y*s, a.z*s); }
Vec vmult(Vec a, Vec b)   { return vec(a.x*b.x, a.y*b.y, a.z*b.z); }
double vdot(Vec a, Vec b) { return a.x*b.x + a.y*b.y + a.z*b.z; }
Vec vcross(Vec a, Vec b)  { return vec(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x); }
Vec vnorm(Vec v)          { return vmul(v, 1.0/sqrt(vdot(v,v))); }

typedef struct { Vec o, d; } Ray;

#define DIFF 0
#define SPEC 1
#define REFR 2

typedef struct {
	double rad;
	Vec p, e, c;
	int refl;
} Sphere;

Sphere spheres[9] = {
	{1e5,  {1e5+1, 40.8, 81.6},    {0,0,0}, {.75,.25,.25}, DIFF},  // Left
	{1e5,  {-1e5+99, 40.8, 81.6},  {0,0,0}, {.25,.25,.75}, DIFF},  // Right
	{1e5,  {50, 40.8, 1e5},        {0,0,0}, {.75,.75,.75}, DIFF},  // Back
	{1e5,  {50, 40.8, -1e5+170},   {0,0,0}, {0,0,0},       DIFF},  // Front
	{1e5,  {50, 1e5, 81.6},        {0,0,0}, {.75,.75,.75}, DIFF},  // Bottom
	{1e5,  {50, -1e5+81.6, 81.6},  {0,0,0}, {.75,.75,.75}, DIFF},  // Top
	{16.5, {27, 16.5, 47},         {0,0,0}, {.999,.999,.999}, SPEC}, // Mirror
	{16.5, {73, 16.5, 78},         {0,0,0}, {.999,.999,.999}, REFR}, // Glass
	{600,  {50, 681.6-.27, 81.6},  {12,12,12}, {0,0,0},    DIFF},  // Light
};
#define NUM_SPHERES (sizeof(spheres)/sizeof(Sphere))

double sphere_intersect(Sphere *s, Ray *r) {
    Vec op = vsub(s->p, r->o);
    double eps = 1e-4;
    double b = vdot(op, r->d);
    double det = b*b - vdot(op,op) + s->rad*s->rad;
    if (det < 0) return 0;
    det = sqrt(det);
    double t = b - det;
    if (t > eps) return t;
    t = b + det;
    return t > eps ? t : 0;
}

int intersect(Ray *r, double *t, int *id) {
    *t = 1e20;
    for (int i = 0; i < NUM_SPHERES; i++) {
        double d = sphere_intersect(&spheres[i], r);
        if (d && d < *t) { *t = d; *id = i; }
    }
    return *t < 1e20;
}

double rng(unsigned *seed) {
    *seed = *seed * 1103515245 + 12345;
    return (*seed & 0x7fffffff) / (double)0x7fffffff;
}

Vec radiance(Ray r, int depth, unsigned *seed) {
    double t;
    int id = 0;
    if (!intersect(&r, &t, &id)) return vec(0,0,0);

    Sphere *obj = &spheres[id];
    Vec x = vadd(r.o, vmul(r.d, t));
    Vec n = vnorm(vsub(x, obj->p));
    Vec nl = vdot(n, r.d) < 0 ? n : vmul(n, -1);
    Vec f = obj->c;

    double p = f.x > f.y && f.x > f.z ? f.x : (f.y > f.z ? f.y : f.z);
    if (++depth > 5) {
        if (rng(seed) < p) f = vmul(f, 1/p);
        else return obj->e;
    }

    if (obj->refl == DIFF) {
        double r1 = 2*M_PI*rng(seed), r2 = rng(seed), r2s = sqrt(r2);
        Vec w = nl;
        Vec u = vnorm(vcross(fabs(w.x) > .1 ? vec(0,1,0) : vec(1,0,0), w));
        Vec v = vcross(w, u);
        Vec d = vnorm(vadd(vadd(vmul(u, cos(r1)*r2s), vmul(v, sin(r1)*r2s)), vmul(w, sqrt(1-r2))));
        return vadd(obj->e, vmult(f, radiance((Ray){x, d}, depth, seed)));
    }

    if (obj->refl == SPEC) {
        Vec d = vsub(r.d, vmul(n, 2*vdot(n, r.d)));
        return vadd(obj->e, vmult(f, radiance((Ray){x, d}, depth, seed)));
    }

    // REFR (glass)
    Ray refl_ray = (Ray){x, vsub(r.d, vmul(n, 2*vdot(n, r.d)))};
    int into = vdot(n, nl) > 0;
    double nc = 1, nt = 1.5;
    double nnt = into ? nc/nt : nt/nc;
    double ddn = vdot(r.d, nl);
    double cos2t = 1 - nnt*nnt*(1 - ddn*ddn);

    if (cos2t < 0) // Total internal reflection
        return vadd(obj->e, vmult(f, radiance(refl_ray, depth, seed)));

    Vec tdir = vnorm(vsub(vmul(r.d, nnt), vmul(n, (into ? 1 : -1) * (ddn*nnt + sqrt(cos2t)))));
    double a = nt - nc, b = nt + nc;
    double R0 = a*a / (b*b);
    double c = 1 - (into ? -ddn : vdot(tdir, n));
    double Re = R0 + (1-R0)*c*c*c*c*c;
    double Tr = 1 - Re;
    double P = .25 + .5*Re;

    if (depth > 2) {
        if (rng(seed) < P)
            return vadd(obj->e, vmult(f, vmul(radiance(refl_ray, depth, seed), Re/P)));
        else
            return vadd(obj->e, vmult(f, vmul(radiance((Ray){x, tdir}, depth, seed), Tr/(1-P))));
    }
    return vadd(obj->e, vmult(f, vadd(vmul(radiance(refl_ray, depth, seed), Re),
                                      vmul(radiance((Ray){x, tdir}, depth, seed), Tr))));
}

int main(int argc, char **argv) {
    int w = 256;
	int h = 192;
    int samps = argc > 1 ? atoi(argv[1])/4 : 1;
    
    Ray cam = (Ray){(Vec){50, 52, 295.6}, vnorm(vec(0, -0.042612, -1))};
    Vec cx = vec(w * .5135 / h, 0, 0);
    Vec cy = vmul(vnorm(vcross(cx, cam.d)), .5135);
    Vec *c = calloc(w * h, sizeof(Vec));

    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            int i = (h - y - 1) * w + x;
            unsigned int seed = y*y*y + x;
            for (int sy = 0; sy < 2; sy++) {
                for (int sx = 0; sx < 2; sx++) {
                    Vec r = {0, 0, 0};
                    for (int s = 0; s < samps; s++) {
                        double r1 = 2*rng(&seed), dx = r1<1 ? sqrt(r1)-1 : 1-sqrt(2-r1);
                        double r2 = 2*rng(&seed), dy = r2<1 ? sqrt(r2)-1 : 1-sqrt(2-r2);
                        Vec d = vadd(vadd(vmul(cx, ((sx+.5+dx)/2+x)/w - .5),
                                         vmul(cy, ((sy+.5+dy)/2+y)/h - .5)), cam.d);
                        d = vnorm(d);
                        Ray ray = (Ray){vadd(cam.o, vmul(d, 140)), d};
                        r = vadd(r, vmul(radiance(ray, 0, &seed), 1./samps));
                    }
                    c[i] = vadd(c[i], vmul(vec(fmin(1, r.x), fmin(1, r.y), fmin(1, r.z)), .25));
                }
            }
        }
    }

    FILE *f = fopen("image.ppm", "w");
    fprintf(f, "P3\n%d %d\n255\n", w, h);
    for (int i = 0; i < w*h; i++)
        fprintf(f, "%d %d %d ", (int)(pow(fmin(1,c[i].x), 1/2.2)*255+.5),
                                (int)(pow(fmin(1,c[i].y), 1/2.2)*255+.5),
                                (int)(pow(fmin(1,c[i].z), 1/2.2)*255+.5));
    return 0;
}
