#include <math.h>
#include <stdio.h>
#include <string.h>

unsigned int usleep(unsigned int microseconds);

int main(int argc, char **args) {
	float z[1760];
	char b[1760];
    float A = 0, B = 0;

    char *palette = ".,-~:;=!*#$@";

	printf("hello\n");
    printf("\x1b[2J");
	printf("hello\n");
    for(int abc = 0; abc < 10000; abc = abc + 1) {
        memset(b, 32, 1760);
        memset(z, 0, sizeof z);

        for (float j = 0; j < 6.28f; j = j + 0.07f) {
            for (float i = 0; i < 6.28f; i = i + 0.02f) {
                float sj = sinf(j), cj = cosf(j);
                float si = sinf(i), ci = cosf(i);
                float sA = sinf(A), cA = cosf(A);
                float sB = sinf(B), cB = cosf(B);

                float h = cj + 2;
                float D = 1.0f / (si * h * sA + sj * cA + 5);
                float t = si * h * cA - sj * sA;

                int x = 40 + 30 * D * (ci * h * cB - t * sB);
                int y = 12 + 15 * D * (ci * h * sB + t * cB);
                int o = x + 80 * y;

                int N = 8 * ((sj * sA - si * cj * cA) * cB
                           - si * cj * sA
                           - sj * cA
                           - ci * cj * sB);

                if (22 > y && y > 0 && x > 0 && 80 > x && D > z[o]) {
                    z[o] = D;
                    b[o] = palette[N > 0 ? N : 0];
                }
            }
        }

        printf("\x1b[H");
        for (int k = 0; k < 1761; k++)
            putchar(k % 80 ? b[k] : '\n');

        A = A + 0.04f;
        B = B + 0.02f;
        usleep(30000);
    }
}