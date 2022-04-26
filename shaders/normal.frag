// Position of the light
extern vec3 LightPos;

vec4 effect(vec4 Color, Image Texture, vec2 textureCoord, vec2 pixelCoord) {
	
	// Color of the pixel (the normal)
	vec4 NormalMap = Texel(Texture, textureCoord);
	vec2 dist = LightPos.xy - pixelCoord.xy;

	if (NormalMap.rgb == vec3(0, 0, 0)) {
		discard;
	}
	
	// Direction of the light
	vec3 LightDir = vec3( dist, 10 );

	// Normalize the normal map
	vec3 N = normalize(NormalMap.rgb * 2.0 - 1.0);

	// Normalize the light direction
	vec3 L = normalize(LightDir);

	// Get the dot product between the both and return the output color
	return Color * ( dot(N, L) );

}