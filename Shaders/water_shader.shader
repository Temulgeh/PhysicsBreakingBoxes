shader_type canvas_item;


uniform vec2 screen_resolution;
uniform sampler2D effect_texture;

uniform vec4 outline_color = vec4(0.0, 0.0, 0.2, 0.4);

uniform vec2 scrolling_a = vec2(.15, -.12);
uniform float scrolling_b_x = -.075;
uniform float scrolling_b_y_sin_speed = 0.7;
uniform float scrolling_b_y_sin_depth = 50.0;
uniform vec3 effect_color = vec3(0.4, 0.7, 1.0);
uniform float effect_fill = 0.8;
uniform float effect_opacity = 0.5;


void fragment()
{
	vec2 effect_size = vec2(64.0) / screen_resolution;
	vec2 effect_uv_a = mod(SCREEN_UV + vec2(TIME) * scrolling_a, effect_size) / effect_size;
	vec2 effect_uv_b = vec2(1.0) - mod(
		SCREEN_UV + vec2(
			TIME * scrolling_b_x,
			sin(TIME * scrolling_b_y_sin_speed) * scrolling_b_y_sin_depth / screen_resolution.y
	), effect_size) / effect_size;
	vec4 output_color = texture(TEXTURE, UV);
	float outline_multiplier = 1.0 - (
		texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2( 1.0,  0.0)).a *
		texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2( 0.0, -1.0)).a *
		texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2(-1.0,  0.0)).a *
		texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * vec2( 0.0,  1.0)).a
	);
	float effect_alpha = max(texture(effect_texture, effect_uv_a).r, texture(effect_texture, effect_uv_b).r);
	vec3 effect_applied = output_color.rgb / (vec3(1.0) - effect_alpha * effect_fill * effect_color);
	output_color.rgb = mix(
		mix(output_color.rgb, effect_applied, effect_opacity),
		output_color.rgb * (1.0 - outline_color.a) + outline_color.rgb * outline_color.a,
		outline_multiplier
	);
	COLOR = output_color;
}
