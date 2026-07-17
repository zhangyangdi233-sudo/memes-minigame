shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;

uniform sampler2D character_texture : source_color, filter_linear_mipmap;
uniform sampler2D scribble_atlas : source_color, filter_linear_mipmap;
uniform vec4 ink_color : source_color = vec4(0.008, 0.008, 0.008, 1.0);
uniform vec2 face_center = vec2(0.5, 0.18);
uniform vec2 face_size = vec2(0.16, 0.09);
uniform float brush_width_px : hint_range(40.0, 60.0, 1.0) = 56.0;
uniform float ink_opacity : hint_range(0.0, 1.0) = 1.0;
uniform float frame_rate : hint_range(1.0, 12.0, 1.0) = 6.0;
uniform float variation : hint_range(0.0, 2.0, 1.0) = 0.0;
uniform float seed = 0.0;


float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}


float atlas_ink(vec2 local_uv, float frame_index, vec2 texel, float dilation) {
	vec2 frame_cell = vec2(mod(frame_index, 2.0), floor(frame_index * 0.5));
	vec2 atlas_uv = (frame_cell + clamp(local_uv, vec2(0.01), vec2(0.99))) * 0.5;
	float ink = texture(scribble_atlas, atlas_uv).a;
	ink = max(ink, texture(scribble_atlas, atlas_uv + vec2(texel.x * dilation, 0.0)).a);
	ink = max(ink, texture(scribble_atlas, atlas_uv - vec2(texel.x * dilation, 0.0)).a);
	ink = max(ink, texture(scribble_atlas, atlas_uv + vec2(0.0, texel.y * dilation)).a);
	ink = max(ink, texture(scribble_atlas, atlas_uv - vec2(0.0, texel.y * dilation)).a);
	return smoothstep(0.28, 0.54, ink);
}


float marker_line(vec2 local_uv, float row, float angle, float stroke_id, float animation_frame, float half_width) {
	float identity = stroke_id + seed * 9.17 + variation * 13.0;
	vec2 frame_jitter = vec2(
		hash21(vec2(identity + 3.0, animation_frame)),
		hash21(vec2(identity + 19.0, animation_frame + 5.0))
	) - vec2(0.5);
	vec2 center = vec2(0.5, row) + frame_jitter * vec2(0.022, 0.030);
	vec2 direction = vec2(cos(angle), sin(angle));
	vec2 normal = vec2(-direction.y, direction.x);
	vec2 point = local_uv - center;
	float along = dot(point, direction);
	float across = dot(point, normal);
	float wave = sin(along * mix(12.0, 23.0, hash21(vec2(identity, 4.0))) + identity) * 0.030;
	wave += sin(along * 49.0 - identity * 0.8) * 0.010;
	float rough_edge = sin(along * 119.0 + identity * 2.0) * 0.007;
	float stroke = 1.0 - smoothstep(half_width + rough_edge, half_width + rough_edge + 0.014, abs(across - wave));
	float cap = 1.0 - smoothstep(0.46, 0.54, abs(along));
	return stroke * cap;
}


void fragment() {
	float character_alpha = texture(character_texture, UV).a;
	vec2 local_face_uv = (UV - (face_center - face_size)) / max(face_size * 2.0, vec2(0.001));
	float inside_face = step(0.0, local_face_uv.x) * step(local_face_uv.x, 1.0);
	inside_face *= step(0.0, local_face_uv.y) * step(local_face_uv.y, 1.0);

	float animation_frame = floor((TIME + seed * 0.41) * frame_rate);
	vec2 redraw_jitter = vec2(
		hash21(vec2(animation_frame, seed + 2.0)),
		hash21(vec2(animation_frame + 31.0, seed + 7.0))
	) - vec2(0.5);

	vec2 atlas_texel = 1.0 / max(vec2(textureSize(scribble_atlas, 0)), vec2(1.0));
	float dilation = mix(0.0, 2.0, clamp((brush_width_px - 40.0) / 20.0, 0.0, 1.0));
	float frame_a = mod(animation_frame + floor(seed), 4.0);
	float frame_b = mod(frame_a + 1.0, 4.0);
	float atlas_a = atlas_ink(local_face_uv + redraw_jitter * 0.018, frame_a, atlas_texel, dilation);
	float atlas_b = atlas_ink(local_face_uv - redraw_jitter * 0.013 + vec2(0.006, -0.004), frame_b, atlas_texel, dilation);
	float hand_drawn_ink = max(atlas_a, atlas_b);

	vec2 source_size = max(vec2(textureSize(character_texture, 0)), vec2(1.0));
	float face_height_px = max(face_size.y * 2.0 * source_size.y, 1.0);
	float marker_half_width = (brush_width_px * 0.5) / face_height_px;
	float forced_ink = 0.0;
	// Each pass remains a recognizable 40-60 px marker stroke. The two almost
	// horizontal center passes cross both eyes in every redraw frame; the
	// surrounding passes break the silhouette without filling a rectangular
	// face-sized block.
	forced_ink = max(forced_ink, marker_line(local_face_uv, 0.26, 0.14, 41.0, animation_frame, marker_half_width * 0.82));
	forced_ink = max(forced_ink, marker_line(local_face_uv, 0.40, -0.035, 42.0, animation_frame, marker_half_width * 1.04));
	forced_ink = max(forced_ink, marker_line(local_face_uv, 0.53, 0.040, 43.0, animation_frame, marker_half_width * 1.04));
	forced_ink = max(forced_ink, marker_line(local_face_uv, 0.67, -0.13, 44.0, animation_frame, marker_half_width * 0.88));
	forced_ink = max(forced_ink, marker_line(local_face_uv, 0.47, 0.50, 71.0, animation_frame, marker_half_width * 0.72));
	forced_ink = max(forced_ink, marker_line(local_face_uv, 0.58, -0.46, 72.0, animation_frame, marker_half_width * 0.72));

	// The atlas contributes irregular marker grain only where a procedural
	// stroke already exists. It can no longer merge the whole face into a blob.
	float marker_grain = mix(0.88, 1.0, hand_drawn_ink);
	float opaque_ink = step(0.06, forced_ink * marker_grain);
	opaque_ink *= inside_face * step(0.08, character_alpha) * ink_opacity;
	ALBEDO = ink_color.rgb;
	EMISSION = vec3(0.0);
	ROUGHNESS = 1.0;
	ALPHA = opaque_ink;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
