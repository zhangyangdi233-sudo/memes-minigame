shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_prepass_alpha;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform vec4 body_tint : source_color = vec4(1.0);
uniform vec4 veil_color : source_color = vec4(0.04, 0.06, 0.04, 1.0);
uniform vec2 face_center = vec2(0.5, 0.185);
uniform vec2 face_size = vec2(0.31, 0.145);
uniform float mask_mode : hint_range(0.0, 2.0, 1.0) = 0.0;
uniform float mask_strength : hint_range(0.0, 1.0) = 0.88;
uniform float seed = 0.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float face_mask(vec2 uv) {
	vec2 distance_to_face = abs(uv - face_center) / max(face_size, vec2(0.001));
	float rectangle = 1.0 - step(1.0, max(distance_to_face.x, distance_to_face.y));
	float feather = 1.0 - smoothstep(0.74, 1.0, max(distance_to_face.x, distance_to_face.y));
	return rectangle * feather;
}

void fragment() {
	float face = face_mask(UV);
	float clock = mod(TIME + seed * 7.31, 64.0);
	float strip = floor((UV.y - face_center.y) * 180.0);
	float strip_noise = hash21(vec2(strip, floor(clock * 7.0) + seed));
	vec2 sample_uv = UV;

	if (mask_mode < 0.5) {
		float jump = (strip_noise - 0.5) * 0.085 * face;
		jump += sin(clock * 13.0 + strip * 0.7) * 0.008 * face;
		sample_uv.x += jump;
	} else if (mask_mode > 1.5) {
		float scratch = step(0.57, sin((UV.x + UV.y * 0.43) * 155.0 + clock * 4.0 + seed * 9.0));
		sample_uv.x += (scratch - 0.5) * 0.026 * face;
	}

	vec4 base = texture(albedo_texture, sample_uv) * body_tint;
	float veil = 0.0;
	if (mask_mode < 0.5) {
		float scan = step(0.42, strip_noise) * (0.62 + 0.38 * sin(clock * 19.0 + strip));
		veil = face * clamp(scan, 0.0, 1.0) * mask_strength;
	} else if (mask_mode < 1.5) {
		vec2 block_size = face_size * vec2(0.94, 0.74);
		vec2 block_distance = abs(UV - face_center - vec2(sin(clock * 3.0 + seed) * 0.004, 0.0));
		veil = (1.0 - step(1.0, max(block_distance.x / block_size.x, block_distance.y / block_size.y))) * mask_strength;
		veil *= 0.88 + 0.12 * step(0.5, hash21(vec2(floor(clock * 12.0), strip + seed)));
	} else {
		float diagonal_a = step(0.72, sin((UV.x * 1.9 + UV.y) * 145.0 + clock * 5.0 + seed));
		float diagonal_b = step(0.80, sin((UV.x - UV.y * 1.3) * 121.0 - clock * 7.0));
		veil = face * clamp(diagonal_a + diagonal_b, 0.0, 1.0) * mask_strength;
	}

	ALBEDO = mix(base.rgb, veil_color.rgb, veil);
	EMISSION = veil_color.rgb * veil * (0.05 + 0.05 * sin(clock * 11.0));
	ROUGHNESS = 0.92;
	ALPHA = base.a;
	ALPHA_SCISSOR_THRESHOLD = 0.08;
}
