shader_type canvas_item;

uniform vec2 size = vec2(32.0, 28.0);
// If you intend to read from mipmaps with `textureLod()` LOD values greater than `0.0`,
// use `filter_nearest_mipmap` instead. This shader doesn't require it.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
//instance uniform vec4 water_color: source_color = vec4(0.65,0.75,1.0,1.0);

const vec4 water_color = vec4(0.65,0.75,1.0,1.0);

void fragment() {
		float yOff = sin(TIME*7.0 + SCREEN_UV.y*50.0)/1000.0;
		float xOff = sin(TIME*2.0 + SCREEN_UV.x*5.0)/400.0;
		vec2 uv = SCREEN_UV + vec2(xOff, yOff);
		vec4 color = water_color;
        COLOR = textureLod(screen_texture, uv, 0.0) * color;
}
