#include <stdio.h>
#include <math.h>
#include <float.h>
#include <stdbool.h>

/* ── Vector math ─────────────────────────────────────────────────── */

typedef struct { double x, y, z; } v3;

static v3 v3_add(v3 a, v3 b)       { return (v3){a.x+b.x, a.y+b.y, a.z+b.z}; }
static v3 v3_sub(v3 a, v3 b)       { return (v3){a.x-b.x, a.y-b.y, a.z-b.z}; }
static v3 v3_mul(v3 a, double s)    { return (v3){a.x*s, a.y*s, a.z*s}; }
static v3 v3_hadamard(v3 a, v3 b)   { return (v3){a.x*b.x, a.y*b.y, a.z*b.z}; }
static double v3_dot(v3 a, v3 b)    { return a.x*b.x + a.y*b.y + a.z*b.z; }
static double v3_len(v3 a)          { return sqrt(v3_dot(a, a)); }
static v3 v3_norm(v3 a)             { double l = v3_len(a); return (v3){a.x/l, a.y/l, a.z/l}; }
static v3 v3_reflect(v3 d, v3 n)    { return v3_sub(d, v3_mul(n, 2.0 * v3_dot(d, n))); }

/* ── Scene description ───────────────────────────────────────────── */

typedef struct {
    v3 center;
    double radius;
    v3 color;
    double reflectivity;  /* 0 = diffuse, 1 = perfect mirror */
    double specular_exp;
} Sphere;

static const Sphere spheres[3] = {
    /* Reflective ball */
    { .center = {0.0, 1.0, -5.0}, .radius = 1.0,
      .color = {0.8, 0.8, 0.9}, .reflectivity = 0.85, .specular_exp = 128.0 },
    /* Matte red ball for visual interest */
    { .center = {2.2, 0.6, -4.0}, .radius = 0.6,
      .color = {0.9, 0.2, 0.2}, .reflectivity = 0.15, .specular_exp = 32.0 },
    /* Small blue ball */
    { .center = {-1.8, 0.5, -3.5}, .radius = 0.5,
      .color = {0.2, 0.3, 0.9}, .reflectivity = 0.1, .specular_exp = 32.0 },
};
#define NUM_SPHERES (sizeof(spheres) / sizeof(spheres[0]))

/* Floor at y = 0 */
#define FLOOR_Y 0.0

/* Point light */
static const v3 light_pos = {3.0, 8.0, -2.0};
static const v3 light_color = {1.0, 1.0, 1.0};
static const double light_intensity = 1.0;
static const v3 ambient = {0.08, 0.08, 0.1};

/* Sky */
static v3 sky_color(v3 dir) {
    double t = 0.5 * (dir.y + 1.0);
    /* gradient from warm horizon to blue zenith */
    v3 bottom = {0.7, 0.6, 0.5};
    v3 top    = {0.3, 0.45, 0.75};
    return v3_add(v3_mul(bottom, 1.0 - t), v3_mul(top, t));
}

/* ── Ray-scene intersection ──────────────────────────────────────── */

typedef struct {
    bool hit;
    double t;
    v3 point;
    v3 normal;
    v3 color;
    double reflectivity;
    double specular_exp;
} Hit;

static Hit intersect_sphere(v3 ro, v3 rd, const Sphere *s) {
    Hit h = {0};
    v3 oc = v3_sub(ro, s->center);
    double b = v3_dot(oc, rd);
    double c = v3_dot(oc, oc) - s->radius * s->radius;
    double disc = b * b - c;
    if (disc < 0.0) return h;
    double sq = sqrt(disc);
    double t = -b - sq;
    if (t < 1e-4) t = -b + sq;
    if (t < 1e-4) return h;
    h.hit = true;
    h.t = t;
    h.point = v3_add(ro, v3_mul(rd, t));
    h.normal = v3_norm(v3_sub(h.point, s->center));
    h.color = s->color;
    h.reflectivity = s->reflectivity;
    h.specular_exp = s->specular_exp;
    return h;
}

static Hit intersect_floor(v3 ro, v3 rd) {
    Hit h = {0};
    if (fabs(rd.y) < 1e-8) return h;
    double t = (FLOOR_Y - ro.y) / rd.y;
    if (t < 1e-4) return h;
    h.hit = true;
    h.t = t;
    h.point = v3_add(ro, v3_mul(rd, t));
    h.normal = (v3){0.0, 1.0, 0.0};

    /* Checkerboard pattern — floor() handles negatives correctly */
    int fx = (int)floor(h.point.x);
    int fz = (int)floor(h.point.z);
    bool white = ((fx ^ fz) & 1) == 0;
    h.color = white ? (v3){0.9, 0.9, 0.9} : (v3){0.15, 0.15, 0.15};
    h.reflectivity = 0.15;
    h.specular_exp = 64.0;
    return h;
}

static Hit trace_scene(v3 ro, v3 rd) {
    Hit closest = {0};
    closest.t = DBL_MAX;

    for (int i = 0; i < (int)NUM_SPHERES; i++) {
        Hit h = intersect_sphere(ro, rd, &spheres[i]);
        if (h.hit && h.t < closest.t) closest = h;
    }

    Hit fh = intersect_floor(ro, rd);
    if (fh.hit && fh.t < closest.t) closest = fh;

    return closest;
}

/* ── Shadow test ─────────────────────────────────────────────────── */

static bool in_shadow(v3 point, v3 to_light, double light_dist) {
    for (int i = 0; i < (int)NUM_SPHERES; i++) {
        Hit h = intersect_sphere(point, to_light, &spheres[i]);
        if (h.hit && h.t < light_dist) return true;
    }
    /* Floor can't cast shadow on things above it in this scene */
    return false;
}

/* ── Shading (Whitted recursive) ─────────────────────────────────── */

#define MAX_DEPTH 6

static v3 shade(v3 ro, v3 rd, int depth) {
    if (depth >= MAX_DEPTH) return (v3){0, 0, 0};

    Hit h = trace_scene(ro, rd);
    if (!h.hit) return sky_color(rd);

    /* Direct illumination: diffuse + Blinn-Phong specular */
    v3 to_light = v3_sub(light_pos, h.point);
    double light_dist = v3_len(to_light);
    to_light = v3_norm(to_light);

    v3 result = v3_hadamard(ambient, h.color);

    /* Bias the shadow origin slightly off the surface */
    v3 shadow_origin = v3_add(h.point, v3_mul(h.normal, 1e-4));

    if (!in_shadow(shadow_origin, to_light, light_dist)) {
        /* Diffuse */
        double ndotl = fmax(0.0, v3_dot(h.normal, to_light));
        double attenuation = light_intensity / (1.0 + 0.05 * light_dist * light_dist);
        v3 diffuse = v3_mul(v3_hadamard(h.color, light_color), ndotl * attenuation);

        /* Blinn-Phong specular */
        v3 view_dir = v3_mul(rd, -1.0);
        v3 half_dir = v3_norm(v3_add(to_light, view_dir));
        double ndoth = fmax(0.0, v3_dot(h.normal, half_dir));
        double spec = pow(ndoth, h.specular_exp) * attenuation;
        v3 specular = v3_mul(light_color, spec * 0.5);

        result = v3_add(result, v3_add(diffuse, specular));
    }

    /* Reflection (Whitted recursion) */
    if (h.reflectivity > 0.001) {
        v3 refl_dir = v3_reflect(rd, h.normal);
        v3 refl_origin = v3_add(h.point, v3_mul(h.normal, 1e-4));
        v3 refl_color = shade(refl_origin, refl_dir, depth + 1);
        result = v3_add(v3_mul(result, 1.0 - h.reflectivity),
                        v3_mul(refl_color, h.reflectivity));
    }

    return result;
}

/* ── Tone mapping & output ───────────────────────────────────────── */

static double linear_to_srgb(double x) {
    if (x < 0.0031308) return 12.92 * x;
    return 1.055 * pow(x, 1.0 / 2.4) - 0.055;
}

static int to_byte(double x) {
    int v = (int)(linear_to_srgb(fmin(fmax(x, 0.0), 1.0)) * 255.0 + 0.5);
    return v < 0 ? 0 : (v > 255 ? 255 : v);
}

/* ── Main ────────────────────────────────────────────────────────── */

#define WIDTH  960
#define HEIGHT 540
#define SAMPLES_PER_AXIS 2  /* 2x2 = 4 samples per pixel */

int main() {
    v3 cam_pos  = {0.0, 2.5, 2.0};
    v3 cam_look = {0.0, 0.5, -5.0};
    v3 cam_up   = {0.0, 1.0, 0.0};
    double fov  = 55.0;

    /* Camera basis */
    v3 forward = v3_norm(v3_sub(cam_look, cam_pos));
    v3 right   = v3_norm((v3){
        forward.z * cam_up.y - forward.y * cam_up.z,
        forward.x * cam_up.z - forward.z * cam_up.x,
        forward.y * cam_up.x - forward.x * cam_up.y
    });
    v3 up = (v3){
        right.y * forward.z - right.z * forward.y,
        right.z * forward.x - right.x * forward.z,
        right.x * forward.y - right.y * forward.x
    };

    double aspect = (double)WIDTH / (double)HEIGHT;
    double half_h = tan(fov * 0.5 * M_PI / 180.0);
    double half_w = half_h * aspect;

    /* PPM output */
    FILE *f = fopen("render.ppm", "wb");
    fprintf(f, "P6\n%d %d\n255\n", WIDTH, HEIGHT);

    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            v3 accum = {0, 0, 0};

            /* Stratified 2x2 supersampling */
            for (int sy = 0; sy < SAMPLES_PER_AXIS; sy++) {
                for (int sx = 0; sx < SAMPLES_PER_AXIS; sx++) {
                    double px = (double)x + ((double)sx + 0.5) / SAMPLES_PER_AXIS;
                    double py = (double)y + ((double)sy + 0.5) / SAMPLES_PER_AXIS;

                    double u = (2.0 * px / WIDTH  - 1.0) * half_w;
                    double v = (2.0 * py / HEIGHT - 1.0) * half_h;

                    v3 rd = v3_norm(v3_add(forward, v3_add(v3_mul(right, u), v3_mul(up, v))));
                    v3 c = shade(cam_pos, rd, 0);
                    accum = v3_add(accum, c);
                }
            }

            double inv = 1.0 / (SAMPLES_PER_AXIS * SAMPLES_PER_AXIS);
            unsigned char rgb[3] = {
                (unsigned char)to_byte(accum.x * inv),
                (unsigned char)to_byte(accum.y * inv),
                (unsigned char)to_byte(accum.z * inv)
            };
            fwrite(rgb, 1, 3, f);
        }
    }

    fclose(f);
    printf("Wrote render.ppm (%dx%d)\n", WIDTH, HEIGHT);
    return 0;
}
