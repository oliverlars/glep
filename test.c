#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define true 1
#define false 0

typedef struct { double x, y, z; } Vec;

Vec vec(double x, double y, double z) { return (Vec){x, y, z}; }
Vec vadd(Vec a, Vec b)    { return vec(a.x+b.x, a.y+b.y, a.z+b.z); }
Vec vsub(Vec a, Vec b)    { return vec(a.x-b.x, a.y-b.y, a.z-b.z); }
Vec vmul(Vec a, double s) { return vec(a.x*s, a.y*s, a.z*s); }
Vec vmult(Vec a, Vec b)   { return vec(a.x*b.x, a.y*b.y, a.z*b.z); }
double vdot(Vec a, Vec b) { return a.x*b.x + a.y*b.y + a.z*b.z; }
Vec vcross(Vec a, Vec b)  { return vec(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x); }
Vec vnorm(Vec v)          { return vmul(v, 1.0/sqrt(vdot(v,v))); }

#define EPSILON 0.001
#define assert_eq(a, b) assert(fabs((a) - (b)) < EPSILON)

void assert_vec_eq(Vec a, Vec b) {
	assert_eq(a.x, b.x);
	assert_eq(a.y, b.y);
	assert_eq(a.z, b.z);
}

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
	{1e5,  {1e5+1, 40.8, 81.6},    {0,0,0}, {.75,.25,.25}, DIFF},
	{1e5,  {-1e5+99, 40.8, 81.6},  {0,0,0}, {.25,.25,.75}, DIFF},
	{1e5,  {50, 40.8, 1e5},        {0,0,0}, {.75,.75,.75}, DIFF},
	{1e5,  {50, 40.8, -1e5+170},   {0,0,0}, {0,0,0},       DIFF},
	{1e5,  {50, 1e5, 81.6},        {0,0,0}, {.75,.75,.75}, DIFF},
	{1e5,  {50, -1e5+81.6, 81.6},  {0,0,0}, {.75,.75,.75}, DIFF},
	{16.5, {27, 16.5, 47},         {0,0,0}, {.999,.999,.999}, SPEC},
	{16.5, {73, 16.5, 78},         {0,0,0}, {.999,.999,.999}, REFR},
	{600,  {50, 681.6-.27, 81.6},  {12,12,12}, {0,0,0},    DIFF},
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
    if (t > eps) return t;
    return 0;
}

int intersect(Ray *r, double *t, int *id) {
    *t = 1e20;
    int i = 0;
    while (i < NUM_SPHERES) {
        double d = sphere_intersect(&spheres[i], r);
        if (d != 0.0 && d < *t) { *t = d; *id = i; }
        i = i + 1;
    }
    return *t < 1e20;
}

double rng(unsigned *seed) {
    *seed = *seed * 1103515245 + 12345;
    return (*seed & 0x7fffffff) / (double)0x7fffffff;
}

int toInt(double x) {
    double g = pow(x, 1.0/2.2);
    int v = (int)(g * 255 + 0.5);
    if (v < 0) return 0;
    if (v > 255) return 255;
    return v;
}

// ===== TEST 1: rng produces varying values =====
void test_rng() {
    printf("test_rng...\n");
    unsigned seed = 0;
    double first = rng(&seed);
    double second = rng(&seed);
    assert(first != second);
    // After enough calls, rng should produce something >= 0.75
    int found = 0;
    int i = 0;
    while (i < 100) {
        double r = rng(&seed);
        if (r >= 0.75) { found = 1; }
        i = i + 1;
    }
    assert(found);
    printf("  PASS\n");
}

// ===== TEST 2: intersect finds a sphere =====
void test_intersect() {
    printf("test_intersect...\n");
    Ray r = (Ray){vec(50, 52, 295.6), vnorm(vec(0, -0.042612, -1))};
    double t;
    int id = 0;
    int hit = intersect(&r, &t, &id);
    assert(hit);
    assert(t > 0);
    printf("  hit sphere %d at t=%f\n", id, t);
    printf("  PASS\n");
}

// ===== TEST 3: p is computed correctly from Vec f =====
void test_p_computation() {
    printf("test_p_computation...\n");
    {
        Vec f = vec(0.75, 0.25, 0.25);
        double p;
        if (f.x > f.y && f.x > f.z) {
            p = f.x;
        } else if (f.y > f.z) {
            p = f.y;
        } else {
            p = f.z;
        }
        assert_eq(p, 0.75);
    }
    {
        Vec f = vec(0.25, 0.75, 0.25);
        double p;
        if (f.x > f.y && f.x > f.z) {
            p = f.x;
        } else if (f.y > f.z) {
            p = f.y;
        } else {
            p = f.z;
        }
        assert_eq(p, 0.75);
    }
    {
        Vec f = vec(0.25, 0.25, 0.75);
        double p;
        if (f.x > f.y && f.x > f.z) {
            p = f.x;
        } else if (f.y > f.z) {
            p = f.y;
        } else {
            p = f.z;
        }
        assert_eq(p, 0.75);
    }
    {
        // Equal values - should pick z via else branch
        Vec f = vec(0.5, 0.5, 0.5);
        double p;
        if (f.x > f.y && f.x > f.z) {
            p = f.x;
        } else if (f.y > f.z) {
            p = f.y;
        } else {
            p = f.z;
        }
        assert_eq(p, 0.5);
    }
    {
        // Zero color (light source)
        Vec f = vec(0, 0, 0);
        double p;
        if (f.x > f.y && f.x > f.z) {
            p = f.x;
        } else if (f.y > f.z) {
            p = f.y;
        } else {
            p = f.z;
        }
        assert_eq(p, 0.0);
    }
    printf("  PASS\n");
}

// ===== TEST 4: Russian roulette terminates =====
void test_russian_roulette() {
    printf("test_russian_roulette...\n");
    unsigned seed = 12345;
    double p = 0.75;
    int depth = 5;
    int continued = 0;
    int terminated = 0;
    int i = 0;
    while (i < 1000) {
        if (rng(&seed) < p) {
            continued = continued + 1;
        } else {
            terminated = terminated + 1;
        }
        i = i + 1;
    }
    printf("  continued=%d terminated=%d\n", continued, terminated);
    assert(terminated > 0);
    printf("  PASS\n");
}

// ===== TEST 5: ++depth works correctly =====
void test_preincrement() {
    printf("test_preincrement...\n");
    int depth = 4;
    if (++depth > 5) {
        assert(false);
    }
    assert(depth == 5);
    if (++depth > 5) {
        assert(depth == 6);
    } else {
        assert(false);
    }
    printf("  PASS\n");
}

// ===== TEST 6: Sphere member access =====
void test_sphere_access() {
    printf("test_sphere_access...\n");
    Sphere *obj = &spheres[0];
    assert_eq(obj->rad, 1e5);
    assert_eq(obj->p.x, 1e5+1);
    assert_eq(obj->c.x, 0.75);
    assert_eq(obj->c.y, 0.25);
    assert(obj->refl == DIFF);

    obj = &spheres[6];
    assert_eq(obj->rad, 16.5);
    assert_eq(obj->c.x, 0.999);
    assert(obj->refl == SPEC);

    obj = &spheres[8];
    assert_eq(obj->e.x, 12);
    assert_eq(obj->c.x, 0);
    printf("  PASS\n");
}

// ===== TEST 7: Ray compound literal =====
void test_ray_compound() {
    printf("test_ray_compound...\n");
    Vec x = vec(1, 2, 3);
    Vec d = vec(4, 5, 6);
    Ray r = (Ray){x, d};
    assert_eq(r.o.x, 1);
    assert_eq(r.o.y, 2);
    assert_eq(r.o.z, 3);
    assert_eq(r.d.x, 4);
    assert_eq(r.d.y, 5);
    assert_eq(r.d.z, 6);
    printf("  PASS\n");
}

// ===== TEST 8: nl assignment (composite in if/else) =====
void test_nl_branch() {
    printf("test_nl_branch...\n");
    Vec n = vec(0, 1, 0);
    Vec rd = vec(0, -1, 0);
    Vec nl;
    if (vdot(n, rd) < 0) {
        nl = n;
    } else {
        nl = vmul(n, -1);
    }
    assert_eq(nl.x, 0);
    assert_eq(nl.y, 1);
    assert_eq(nl.z, 0);

    rd = vec(0, 1, 0);
    if (vdot(n, rd) < 0) {
        nl = n;
    } else {
        nl = vmul(n, -1);
    }
    assert_eq(nl.y, -1);
    printf("  PASS\n");
}

// ===== TEST 9: DIFF case - direction computation =====
void test_diff_direction() {
    printf("test_diff_direction...\n");
    unsigned seed = 42;
    Vec nl = vnorm(vec(0, 1, 0));
    double r1 = 2*3.14159265358979*rng(&seed);
    double r2 = rng(&seed);
    double r2s = sqrt(r2);
    Vec w = nl;
    Vec u;
    if (fabs(w.x) > .1) {
        u = vnorm(vcross(vec(0,1,0), w));
    } else {
        u = vnorm(vcross(vec(1,0,0), w));
    }
    Vec v = vcross(w, u);
    Vec d = vnorm(vadd(vadd(vmul(u, cos(r1)*r2s), vmul(v, sin(r1)*r2s)), vmul(w, sqrt(1-r2))));
    // d should be a unit vector
    double len = sqrt(vdot(d, d));
    assert_eq(len, 1.0);
    printf("  d=(%f, %f, %f)\n", d.x, d.y, d.z);
    printf("  PASS\n");
}

// ===== TEST 10: SPEC case - reflection direction =====
void test_spec_direction() {
    printf("test_spec_direction...\n");
    Vec rd = vnorm(vec(1, -1, 0));
    Vec n = vec(0, 1, 0);
    Vec d = vsub(rd, vmul(n, 2*vdot(n, rd)));
    // reflected should go up
    assert(d.y > 0);
    double len = sqrt(vdot(d, d));
    assert_eq(len, 1.0);
    printf("  d=(%f, %f, %f)\n", d.x, d.y, d.z);
    printf("  PASS\n");
}

// ===== TEST 11: 1/p where p is double =====
void test_int_div_double() {
    printf("test_int_div_double...\n");
    double p = 0.75;
    Vec f = vec(0.75, 0.25, 0.25);
    Vec result = vmul(f, 1/p);
    assert_eq(result.x, 1.0);
    assert_eq(result.y, 0.333);
    printf("  PASS\n");
}

// ===== TEST 12: simple recursion with Vec return =====
Vec simple_recurse(int depth, unsigned *seed) {
    if (++depth > 5) {
        if (rng(seed) < 0.75) {
            depth = depth;
        } else {
            return vec(1, 1, 1);
        }
    }
    if (depth > 50) return vec(0, 0, 0);
    Vec child = simple_recurse(depth, seed);
    return vadd(vec(0.1, 0.1, 0.1), vmult(vec(0.75, 0.75, 0.75), child));
}

void test_simple_recurse() {
    printf("test_simple_recurse...\n");
    unsigned seed = 12345;
    Vec result = simple_recurse(0, &seed);
    printf("  result=(%f, %f, %f)\n", result.x, result.y, result.z);
    printf("  PASS\n");
}

// ===== TEST 13: recursion with Ray compound literal =====
Vec recurse_with_ray(Ray r, int depth, unsigned *seed) {
    if (++depth > 5) {
        if (rng(seed) < 0.75) {
            depth = depth;
        } else {
            return vec(1, 1, 1);
        }
    }
    if (depth > 50) return vec(0, 0, 0);
    Vec child = recurse_with_ray((Ray){r.o, r.d}, depth, seed);
    return vadd(vec(0.1, 0.1, 0.1), vmult(vec(0.75, 0.75, 0.75), child));
}

void test_recurse_with_ray() {
    printf("test_recurse_with_ray...\n");
    unsigned seed = 12345;
    Ray ray = (Ray){vec(50, 52, 295), vec(0, -0.04, -1)};
    Vec result = recurse_with_ray(ray, 0, &seed);
    printf("  result=(%f, %f, %f)\n", result.x, result.y, result.z);
    printf("  PASS\n");
}

// ===== TEST 14: recursion with intersect =====
Vec recurse_with_intersect(Ray r, int depth, unsigned *seed) {
    double t;
    int id = 0;
    if (!intersect(&r, &t, &id)) return vec(0,0,0);

    Sphere *obj = &spheres[id];
    Vec x = vadd(r.o, vmul(r.d, t));
    Vec n = vnorm(vsub(x, obj->p));
    Vec f = obj->c;

    double p;
    if (f.x > f.y && f.x > f.z) {
        p = f.x;
    } else if (f.y > f.z) {
        p = f.y;
    } else {
        p = f.z;
    }

    if (++depth > 5) {
        if (rng(seed) < p) {
            f = vmul(f, 1/p);
        } else {
            return obj->e;
        }
    }

    // Always do DIFF-like bounce
    Vec nl;
    if (vdot(n, r.d) < 0) {
        nl = n;
    } else {
        nl = vmul(n, -1);
    }

    // Simplified direction: just use normal
    Vec child = recurse_with_intersect((Ray){x, nl}, depth, seed);
    return vadd(obj->e, vmult(f, child));
}

void test_recurse_with_intersect() {
    printf("test_recurse_with_intersect...\n");
    unsigned seed = 12345;
    Ray ray = (Ray){vec(50, 52, 295.6), vnorm(vec(0, -0.042612, -1))};
    Vec result = recurse_with_intersect(ray, 0, &seed);
    printf("  result=(%f, %f, %f)\n", result.x, result.y, result.z);
    printf("  PASS\n");
}

// ===== TEST 15: full DIFF bounce (with cos/sin) =====
Vec recurse_diff_only(Ray r, int depth, unsigned *seed) {
    double t;
    int id = 0;
    if (!intersect(&r, &t, &id)) return vec(0,0,0);

    Sphere *obj = &spheres[id];
    Vec x = vadd(r.o, vmul(r.d, t));
    Vec n = vnorm(vsub(x, obj->p));

    Vec nl;
    if (vdot(n, r.d) < 0) {
        nl = n;
    } else {
        nl = vmul(n, -1);
    }

    Vec f = obj->c;

    double p;
    if (f.x > f.y && f.x > f.z) {
        p = f.x;
    } else if (f.y > f.z) {
        p = f.y;
    } else {
        p = f.z;
    }

    if (++depth > 5) {
        if (rng(seed) < p) {
            f = vmul(f, 1/p);
        } else {
            return obj->e;
        }
    }

    double r1 = 2*3.14159265358979*rng(seed);
    double r2 = rng(seed);
    double r2s = sqrt(r2);
    Vec w = nl;
    Vec u;
    if (fabs(w.x) > .1) {
        u = vnorm(vcross(vec(0,1,0), w));
    } else {
        u = vnorm(vcross(vec(1,0,0), w));
    }
    Vec v = vcross(w, u);
    Vec d = vnorm(vadd(vadd(vmul(u, cos(r1)*r2s), vmul(v, sin(r1)*r2s)), vmul(w, sqrt(1-r2))));
    Vec child = recurse_diff_only((Ray){x, d}, depth, seed);
    return vadd(obj->e, vmult(f, child));
}

void test_recurse_diff_only() {
    printf("test_recurse_diff_only...\n");
    unsigned seed = 12345;
    Ray ray = (Ray){vec(50, 52, 295.6), vnorm(vec(0, -0.042612, -1))};
    Vec result = recurse_diff_only(ray, 0, &seed);
    printf("  result=(%f, %f, %f)\n", result.x, result.y, result.z);
    printf("  PASS\n");
}

int main(int argc, char **args) {
    test_rng();
    test_intersect();
    test_p_computation();
    test_russian_roulette();
    test_preincrement();
    test_sphere_access();
    test_ray_compound();
    test_nl_branch();
    test_diff_direction();
    test_spec_direction();
    test_int_div_double();
    test_simple_recurse();
    test_recurse_with_ray();
    test_recurse_with_intersect();
    test_recurse_diff_only();

    printf("\nAll tests passed!\n");
    return 0;
}
