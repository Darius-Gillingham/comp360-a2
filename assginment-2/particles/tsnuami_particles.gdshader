shader_type particles;

uniform float width = 100.0;
uniform float height = 50.0;
uniform float curvature = 10.0;

float rand_from_seed(in uint seed) {
  int k;
  int s = int(seed);
  if (s == 0) s = 305420679;
  k = s / 127773;
  s = 16807 * (s - k * 127773) - 2836 * k;
  if (s < 0)
    s += 2147483647;
  seed = uint(s);
  return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = (x >> uint(16)) ^ x;
  return x;
}

// https://docs.godotengine.org/en/stable/tutorials/performance/vertex_animation/controlling_thousands_of_fish.html
void start() {
	uint alt_seed1 = hash(NUMBER + uint(1) + RANDOM_SEED);
	uint alt_seed2 = hash(NUMBER + uint(27) + RANDOM_SEED);
	uint alt_seed3 = hash(NUMBER + uint(43) + RANDOM_SEED);
	uint alt_seed4 = hash(NUMBER + uint(111) + RANDOM_SEED);
	
	//CUSTOM.x = rand_from_seed(alt_seed1);
	vec3 position = vec3((rand_from_seed(alt_seed2) * 2.0 - 1.0) * width / 2.0,
                     0.0,//rand_from_seed(alt_seed3) * 2.0 - 1.0,
                     0.0);//rand_from_seed(alt_seed4) * 2.0 - 1.0);
	TRANSFORM[3].xyz = position + EMISSION_TRANSFORM[3].xyz; // vec4(position,0) + 
	
	CUSTOM.w = 0.0;
	CUSTOM.x = (rand_from_seed(alt_seed2) * 2.0 - 1.0) * width / 2.0;
}

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
	CUSTOM.w += DELTA / LIFETIME;
	
	float progression = 15.0; //NUMBER;
	//float height = progression / LIFETIME; 
	//VELOCITY.y = float(height);
	
	TRANSFORM[3].y = CUSTOM.w * height + EMISSION_TRANSFORM[3].y;
	TRANSFORM[3].z = cos(CUSTOM.w * PI - PI * 0.5) * curvature * EMISSION_TRANSFORM[2].z + EMISSION_TRANSFORM[3].z + (CUSTOM.x * EMISSION_TRANSFORM[0].z);
	TRANSFORM[3].x = cos(CUSTOM.w * PI - PI * 0.5) * curvature * EMISSION_TRANSFORM[2].x + EMISSION_TRANSFORM[3].x + (CUSTOM.x * EMISSION_TRANSFORM[0].x);
	
}
