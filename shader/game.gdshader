shader_type canvas_item;

uniform vec2 size = vec2(32.0, 28.0);
// If you intend to read from mipmaps with `textureLod()` LOD values greater than `0.0`,
// use `filter_nearest_mipmap` instead. This shader doesn't require it.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
//instance uniform vec4 water_color: source_color = vec4(0.65,0.75,1.0,1.0);

const vec4 water_color = vec4(0.65,0.75,1.0,1.0);
const vec4 highlight_color = vec4(0.75,0.90,1.0,1.);

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}


void fragment() {
		float yOff = sin(TIME*7.0 + SCREEN_UV.y*50.0)/1000.0;
		float xOff = sin(TIME*2.0 + SCREEN_UV.x*5.0)/400.0;
		vec2 uv = SCREEN_UV + vec2(xOff, yOff);
		
		vec4 color = water_color;
		//vec2 noisePos = UV*vec2(40.,10.) + vec2(TIME, TIME)/7.0;
		//float n = noise(noisePos);
		//for (float i = 2.0; i < 4.0; i++) {
			//n += noise(noisePos*pow(2.0,i)) / i;	
		//}
		//float threshold = cos(TIME) / 4.0 + 0.5;
		//if (n < threshold + 0.05 && n > threshold - 0.05) {
			//color = highlight_color;
		//}
        COLOR = textureLod(screen_texture, uv, 0.0) * color;
}
