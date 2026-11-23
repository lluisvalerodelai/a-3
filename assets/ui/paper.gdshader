shader_type canvas_item;
render_mode unshaded;

float grain(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 pixel = UV * vec2(1280.0, 720.0);
	float fine = grain(floor(pixel * 1.6));
	float fibre = grain(floor(pixel * vec2(0.2, 0.8)));
	float wash = sin(UV.x * 9.0 + UV.y * 5.0) * 0.006;
	vec3 paper = vec3(0.945, 0.918, 0.851);
	COLOR = vec4(paper + (fine - 0.5) * 0.045 + (fibre - 0.5) * 0.014 + wash, 1.0);
}
