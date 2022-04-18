	// Position of the light
	extern vec3 LightPos;
	
	vec4 effect(vec4 Color, Image Texture, vec2 textureCoord, vec2 pixelCoord) {
		
		// Color of the pixel (the normal)
		vec4 NormalMap = Texel(Texture, textureCoord);
		
		if (NormalMap.rgb == vec3(0, 0, 0)) {
			discard;
		}

		// Direction of the light
		// I don't know why but the formula for the 'y' coordinate seems to solve a issue here
		vec3 LightDir = vec3( LightPos.xy -  pixelCoord.xy, LightPos.z );
		
		// Normalize the normal map
		vec3 N = normalize(NormalMap.rgb * 2.0 - 1.0);
		
		// Normalize the light direction
		vec3 L = normalize(LightDir);
		
		// Get the dot product between the both and return the output color
		return Color * ( 1.0 - dot(N, L) );
		
	}