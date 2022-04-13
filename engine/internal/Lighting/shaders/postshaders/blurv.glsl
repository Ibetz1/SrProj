extern float steps = 2.0;
extern vec2 res;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec2 pSize = vec2(1.0 / res.x, 1.0 / res.y);
	vec4 col = Texel(texture, texture_coords);
	for(int i = 1; i <= int(steps); i++) {
		col = col + Texel(texture, vec2(texture_coords.x - pSize.x * float(i), texture_coords.y));
		col = col + Texel(texture, vec2(texture_coords.x + pSize.x * float(i), texture_coords.y));
	}
	col = col / (steps * 2.0 + 1.0);
	return vec4(col.r, col.g, col.b, 1.0);
}
