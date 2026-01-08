#define __asm(x)
#define __attribute__(x)

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define M_PI 3.14159265358979323846

/* --- Vec --- */
typedef struct {
    double x, y, z;
} Vec;

static inline Vec vec(double x, double y, double z) {
    Vec v = {x, y, z};
    return v;
}

static inline Vec vec_add(Vec a, Vec b) {
    return vec(a.x + b.x, a.y + b.y, a.z + b.z);
}

static inline Vec vec_sub(Vec a, Vec b) {
    return vec(a.x - b.x, a.y - b.y, a.z - b.z);
}

static inline Vec vec_mul(Vec a, double b) {
    return vec(a.x * b, a.y * b, a.z * b);
}

static inline Vec vec_mult(Vec a, Vec b) {
    return vec(a.x * b.x, a.y * b.y, a.z * b.z);
}

static inline Vec vec_norm(Vec a) {
    double len = sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
    return vec_mul(a, 1.0 / len);
}

static inline double vec_dot(Vec a, Vec b) {
    return a.x*b.x + a.y*b.y + a.z*b.z;
}

static inline Vec vec_cross(Vec a, Vec b) {
    return vec(
        a.y*b.z - a.z*b.y,
        a.z*b.x - a.x*b.z,
        a.x*b.y - a.y*b.x
    );
}

/* --- Ray --- */
typedef struct {
    Vec o, d;
} Ray;

/* --- Materials --- */
typedef enum {
    DIFF,
    SPEC,
    REFR
} Refl;

/* --- Sphere --- */
typedef struct {
    double rad;
    Vec p, e, c;
    Refl refl;
} Sphere;

static inline double sphere_intersect(const Sphere* s, const Ray* r) {
    Vec op = vec_sub(s->p, r->o);
    double b = vec_dot(op, r->d);
    double det = b*b - vec_dot(op, op) + s->rad*s->rad;
    if (det < 0) return 0;
    det = sqrt(det);
    double t = b - det;
    if (t > 0.0001) return t;
    t = b + det;
    if (t > 0.0001) return t;
    return 0;
}

/* --- Scene --- */
Sphere spheres[] = {
    {100000,  { 100000+1,40.8,81.6}, {0,0,0}, {.75,.25,.25}, DIFF},
    {100000,  {-100000+99,40.8,81.6},{0,0,0}, {.25,.25,.75}, DIFF},
    {100000,  {50,40.8, 100000},    {0,0,0}, {.75,.75,.75}, DIFF},
    {100000,  {50,40.8,-100000+170},{0,0,0}, {0,0,0},      DIFF},
    {100000,  {50, 100000,81.6},    {0,0,0}, {.75,.75,.75}, DIFF},
    {100000,  {50,-100000+81.6,81.6},{0,0,0}, {.75,.75,.75}, DIFF},
    {16.5, {27,16.5,47},      {0,0,0}, {1,1,1},      SPEC},
    {16.5, {73,16.5,78},      {0,0,0}, {1,1,1},      REFR},
    {600,  {50,681.6-.27,81.6},{12,12,12},{0,0,0},   DIFF}
};

static int intersect_scene(const Ray* r, double* t, int* id) {
    int n = sizeof(spheres) / sizeof(spheres[0]);
    double inf = 100000000000000000;
    *t = inf;
    for (int i = 0; i < n; i++) {
        double d = sphere_intersect(&spheres[i], r);
        if (d && d < *t) {
            *t = d;
            *id = i;
        }
    }
    return *t < inf;
}

/* --- RNG --- */
static inline double rnd() {
    return rand() / (double)RAND_MAX;
}

/* --- Radiance --- */
Vec radiance(const Ray* r, int depth) {
    double t;
    int id;
    if (!intersect_scene(r, &t, &id))
        return vec(0,0,0);

    const Sphere* obj = &spheres[id];
    Vec x = vec_add(r->o, vec_mul(r->d, t));
    Vec n = vec_norm(vec_sub(x, obj->p));
    Vec nl = vec_dot(n, r->d) < 0 ? n : vec_mul(n, -1);
    Vec f = obj->c;

    double p = f.x > f.y && f.x > f.z ? f.x : (f.y > f.z ? f.y : f.z);
    depth++;
    if (depth > 5) {
        if (rnd() < p)
            f = vec_mul(f, 1/p);
        else
            return obj->e;
    }

    if (obj->refl == DIFF) {
        double r1 = 2 * M_PI * rnd();
        double r2 = rnd();
        double r2s = sqrt(r2);

        Vec w = nl;
        Vec u = vec_norm(
            fabs(w.x) > .1 ? vec_cross(vec(0,1,0), w)
                           : vec_cross(vec(1,0,0), w));
        Vec v = vec_cross(w, u);

        Vec d = vec_norm(vec_add(
            vec_add(vec_mul(u, cos(r1)*r2s),
                    vec_mul(v, sin(r1)*r2s)),
            vec_mul(w, sqrt(1-r2))));

        Ray nr = {x, d};
        return vec_add(obj->e,
            vec_mult(f, radiance(&nr, depth)));
    }

    if (obj->refl == SPEC) {
        Ray nr = {x,
            vec_sub(r->d,
                vec_mul(n, 2*vec_dot(n, r->d)))};
        return vec_add(obj->e,
            vec_mult(f, radiance(&nr, depth)));
    }

    /* REFR */
    Ray reflRay = {x,
        vec_sub(r->d,
            vec_mul(n, 2*vec_dot(n, r->d)))};
    int into = vec_dot(n, nl) > 0;
    double nc = 1, nt = 1.5;
    double nnt = into ? nc/nt : nt/nc;
    double ddn = vec_dot(r->d, nl);
    double cos2t = 1 - nnt*nnt*(1 - ddn*ddn);

    if (cos2t < 0)
        return vec_add(obj->e,
            vec_mult(f, radiance(&reflRay, depth)));

    Vec tdir = vec_norm(vec_sub(
        vec_mul(r->d, nnt),
        vec_mul(n, (into ? 1 : -1) * (ddn*nnt + sqrt(cos2t)))));

    double a = nt - nc;
    double b = nt + nc;
    double R0 = (a*a) / (b*b);
    double c = 1 - (into ? -ddn : vec_dot(tdir, n));
    double Re = R0 + (1 - R0)*c*c*c*c*c;
    double Tr = 1 - Re;
    double P = .25 + .5*Re;

    if (depth > 2) {
        if (rnd() < P)
            return vec_add(obj->e,
                vec_mult(f,
                    vec_mul(radiance(&reflRay, depth), (Re/P))));
        Ray nr = {x, tdir};
        return vec_add(obj->e,
            vec_mult(f,
                vec_mul(radiance(&nr, depth), (Tr/(1-P)))));
    }

    Ray nr = {x, tdir};
    Vec refl = radiance(&reflRay, depth);
    Vec refr = radiance(&nr, depth);
    return vec_add(obj->e,
        vec_mult(f,
            vec_add(vec_mul(refl, Re),
                    vec_mul(refr, Tr))));
}

/* --- Main --- */
int main(int argc, char** argv) {
    int w = 1024, h = 768;
    int samps = (argc == 2) ? atoi(argv[1]) / 4 : 1;

    Ray cam = {{50,52,295.6}, vec_norm(vec(0,-0.042612,-1))};
    Vec cx = vec(w * .5135 / h, 0, 0);
    Vec cy = vec_mul(vec_norm(vec_cross(cx, cam.d)), .5135);

    Vec* c = calloc(w*h, sizeof(Vec));

    for (int y = 0; y < h; y++) {
        fprintf(stderr, "\rRendering (%d spp) %5.2f%%",
            samps*4, 100.0*y/(h-1));
        for (int x = 0; x < w; x++) {
            int i = (h-y-1)*w + x;
            Vec col = vec(0,0,0);
            for (int sy = 0; sy < 2; sy++)
                for (int sx = 0; sx < 2; sx++) {
                    Vec r = vec(0,0,0);
                    for (int s = 0; s < samps; s++) {
                        double r1 = 2*rnd();
                        double dx = r1 < 1 ? sqrt(r1)-1 : 1-sqrt(2-r1);
                        double r2 = 2*rnd();
                        double dy = r2 < 1 ? sqrt(r2)-1 : 1-sqrt(2-r2);
                        Vec d = vec_add(
                            vec_add(
                                vec_mul(cx, ((sx+.5+dx)/2 + x)/w - .5),
                                vec_mul(cy, ((sy+.5+dy)/2 + y)/h - .5)),
                            cam.d);
                        Ray rr = {
                            vec_add(cam.o, vec_mul(d, 140)),
                            vec_norm(d)
                        };
                        r = vec_add(r,
                            vec_mul(radiance(&rr, 0),
                                    1.0/samps));
                    }
                    col = vec_add(col,
                        vec_mul(vec(
                            fmin(r.x,1),
                            fmin(r.y,1),
                            fmin(r.z,1)), .25));
                }
            c[i] = col;
        }
    }
	FILE *file = fopen("yippee.ppm", "w");
    fprintf(file, "P3\n%d %d\n%d\n", w, h, 255);
    for (int i = 0; i < w*h; i++)
        fprintf(file, "%d %d %d ",
            (int)(pow(c[i].x, 1/2.2)*255+.5),
            (int)(pow(c[i].y, 1/2.2)*255+.5),
            (int)(pow(c[i].z, 1/2.2)*255+.5));
	fclose(file);
    free(c);
    return 0;
}