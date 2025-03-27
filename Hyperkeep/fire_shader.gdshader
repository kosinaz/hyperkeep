shader_type spatial;
render_mode blend_add, unshaded;

uniform vec4 base_color : source_color = vec4(1.0, 0.2, 0.0, 1.0);  // Darker orange base
uniform vec4 flame_color : source_color = vec4(1.0, 0.8, 0.2, 1.0);  // Brighter yellow-orange flame
uniform float rim_power = 3.0;
uniform float noise_scale = 10.0;
uniform float speed = 2.0;  // Faster animation

varying vec3 vertex_pos;
varying vec3 normal_interp;
varying vec3 world_pos;

void vertex() {
	vertex_pos = VERTEX;
	normal_interp = NORMAL;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float random(vec3 pos) {
	return fract(sin(dot(pos.xyz, vec3(70.9898, 78.233, 32.4355))) * 43758.5453123);
}

float noise(vec3 pos) {
	vec3 i = floor(pos);
	vec3 f = fract(pos);
	f = f * f * (3.0 - 2.0 * f);
	float n = dot(i, vec3(1.0, 57.0, 113.0));
	return mix(
		mix(
			mix(random(n + vec3(0.0, 0.0, 0.0)), random(n + vec3(1.0, 0.0, 0.0)), f.x),
			mix(random(n + vec3(0.0, 1.0, 0.0)), random(n + vec3(1.0, 1.0, 0.0)), f.x),
			f.y),
		mix(
			mix(random(n + vec3(0.0, 0.0, 1.0)), random(n + vec3(1.0, 0.0, 1.0)), f.x),
			mix(random(n + vec3(0.0, 1.0, 1.0)), random(n + vec3(1.0, 1.0, 1.0)), f.x),
			f.y),
		f.z);
}

void fragment() {
	// Calculate rim lighting effect
	vec3 n = normalize(normal_interp);
	vec3 view_dir = normalize(CAMERA_POSITION_WORLD - world_pos);
	float rim = pow(1.0 - clamp(dot(n, view_dir), 0.0, 1.0), rim_power);
	
	// Animate procedural noise
	float time = TIME * speed;
	vec3 noise_pos = world_pos * noise_scale + vec3(0.0, time, 0.0);
	float noise_value = noise(noise_pos);
	
	// Add some variation
	noise_value *= random(world_pos + vec3(0.0, time, 0.0));
	
	// Mix colors based on noise and rim effect
	vec4 color = mix(base_color, flame_color, noise_value * rim);
	
	// Apply alpha based on noise and rim
	float alpha = clamp(noise_value * rim * 2.0, 0.0, 1.0);
	
	// Final color
	ALBEDO = color.rgb;
	ALPHA = alpha;
	EMISSION = color.rgb * 3.0;  // Brighter emission
}