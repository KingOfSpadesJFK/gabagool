shader_type canvas_item;

uniform vec2 size = vec2(32.0, 28.0);
// If you intend to read from mipmaps with `textureLod()` LOD values greater than `0.0`,
// use `filter_nearest_mipmap` instead. This shader doesn't require it.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
		vec2 uv = SCREEN_UV + vec2(0.0, sin(TIME + SCREEN_UV.y*2.0)/50.0);
        COLOR = textureLod(screen_texture, uv, 0.0) * vec4(0.65,0.75,1.0,1.0);
}
