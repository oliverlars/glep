#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TILE_W 8
#define TILE_H 8
#define MAX_LIGHTS_PER_TILE 64

#define SCREEN_W 1920
#define SCREEN_H 1080
#define TILE_PX_W (SCREEN_W / TILE_W)
#define TILE_PX_H (SCREEN_H / TILE_H)

typedef struct {
	float x1, y1, x2, y2; // screen-space AABB [0,1]
	float z;
	int type; // 0=point, 1=spot
	int id;
} Light;

typedef struct {
	int offset;
	int count;
} TileHeader;

// intermediate CPU-side tile grid + the flat index buffer it produces
#define TILE_COUNT (TILE_H * TILE_W)
typedef struct {
	int tiles[TILE_COUNT * MAX_LIGHTS_PER_TILE];
	int tile_count[TILE_COUNT];
	int index_buf[TILE_COUNT * MAX_LIGHTS_PER_TILE];
	int index_count;
} TileGrid;


// int light_less(Light *lights, int a, int b) {
// 	// if (lights[a].type != lights[b].type)
// 	// 	return lights[a].type < lights[b].type;
// 	// return lights[a].z < lights[b].z;

// 	printf("Light pointer?: %d", lights[0].id);
// 	return 0;
// }

int main() {


	Light light;
	light.id = 123;

	int array[10];
	int after_array = 0;

	printf("distance = %lu | %lu", &after_array - array, sizeof array);

	//light_less(&light, 0, 1);

	return 0;
}