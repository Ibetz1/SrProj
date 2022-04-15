module("shadows.Shaders", package.seeall)

Shadows = require("shadows")

Shadows.BlurShader = love.graphics.newShader[[
	// Size of the canvas on which the effect is applied
	extern Vector Size;
	
	// Multiplier to the size factor (how far is the effect applied? 100% by default)
	const float Quality = 1.0;
	
	// The radius of the pixels that are analized
	const float Radius = 2.0;
	
	vec4 effect(vec4 color, Image tex, Vector tc, Vector pc) {
		
		vec4 Sum = vec4(0);
		Vector SizeFactor = Vector(Quality / Size);
		
		for (float x = -Radius; x <= Radius; x++) {
			
			for (float y = -Radius; y <= Radius; y++) {
				
				Sum += Texel(tex, tc + Vector(x, y) * SizeFactor);
				
			}
		
		}
		
		float Delta = 2.0 * Radius + 1.0;
		
		return Sum / vec4( Delta * Delta );
		
	}
	
]]

Shadows.BloomShader = love.graphics.newShader [[
	// Size of the canvas
	extern Vector Size;
	
	// Radius of the pixel
	const float Radius = 1.0;		// pixels per axis; higher = bigger glow, worse performance
	const float Quality = 5.0;			// lower = smaller glow, better quality
	vec4 effect(vec4 color, Image tex, Vector tc, Vector sc) {
		
		// Summatory of the colors
		vec4 Sum = vec4(0);
		
		// Size multiplier (for Texel)
		Vector SizeFactor = Vector(Quality / Size);
		
		// Number of samples used
		float Samples = 0.0;
		
		for (float x = -Radius; x <= Radius; x++){
		
			for (float y = -Radius; y <= Radius; y++) {
			
				// Add every pixel around to the summatory
				Sum += Texel(tex, tc + Vector(x, y) * SizeFactor);
				Samples++;
				
			}
			
		}
		
		// Return the sum divided by the number of samples and add the color of the pixel at the given point
		return (Sum / Samples + Texel(tex, tc) ) * color;
	}
	
]]

Shadows.DarkenShader = love.graphics.newShader [[
	
	vec4 effect(vec4 src, Image tex, Vector tc, Vector sc) {
		// Minimum between the color and the texture color
		return min(src, Texel(tex, tc) );
		
	}
	
]]

-- https://love2d.org/forums/viewtopic.php?t=81014#p189754
Shadows.AberrationShader = love.graphics.newShader[[
	
	// Size of the canvas
	extern Vector Size;
	
	// Offset used for the effect
	extern float Aberration = 2.0;
	vec4 effect(vec4 col, Image texture, Vector texturePos, Vector screenPos){
		
		// Divide the offset by the size of the canvas
		Vector offset = Vector(Aberration, 0) / Size;
		
		// Get the textures
		vec4 red = texture2D(texture, texturePos - offset);
		vec4 green = texture2D(texture, texturePos);
		vec4 blue = texture2D(texture, texturePos + offset);
		
		return vec4(red.r, green.g, blue.b, 1E0); //final color with alpha of 1
	}
	
]]

Shadows.LightShader = love.graphics.newShader [[
	
	// Radius of the light effect
	extern float Radius;
	
	// Center of the light
	extern vec3 Center;
	vec4 effect(vec4 Color, Image Texture, Vector tc, Vector pc) {
		
		// Distance between the screen pixel and the center of the light
		vec3	Delta		=	vec3(pc, 0.0) - Center;
		float Distance =	length( Delta );
		
		// If the distance is lower than the radius
		if (Distance <= Radius) {
			
			// Return the 100% of the alpha, minus the distance from the light divided by the radius
			return vec4( vec3(1.0), 1.0 - length( Delta / Radius ) );
			
		}
		
		// Return black
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	
]]

Shadows.RadialBlurShader = love.graphics.newShader [[
	
	// Position at which the blur is applied
	extern Vector Position;
	
	// Size of the canvas
	extern Vector Size;
	
	// Radius of the blur for the whole effect
	extern float Radius;
	
	// Distance multiplier
	const float Quality		= 1.3;
	
	// The value of PI
	const float Pi				= 3.141592653589793238462643383279502884197169399375;
	
	// The inverse of PI
	const float invPi			= 1.0 / Pi;
	
	// Radius of the blur PER pixel
	const int BlurRadius	= 5;
	
	// This function calculates gauss
	float gauss(Vector vec, float deviation) {
		
		float deviationSquare = pow(deviation, 2.0);
		float invDeviationSquare = 0.5 / deviationSquare;
		float len = pow(vec.x, 2.0) + pow(vec.y, 2.0);
		
		return exp( -len * invDeviationSquare ) * invPi * invDeviationSquare;
		
	}
	
	vec4 effect(vec4 Color, Image Texture, Vector textureCoord, Vector pixelCoord) {
		
		// Radius
		float r = length(pixelCoord - Position) / Radius;
		
		// Calculate the standard deviation for the gauss effect
		float Deviation = 1.0 + 12.0 * r * smoothstep(0.0, 1.0, r);
		
		// Size multiplier (for Texel)
		Vector SizeFactor = Vector(Quality / Size);
		vec4 Gradient = vec4(0E0);
		
		// Radius of the blur
		for (int x = -BlurRadius; x <= BlurRadius; x++) {
			
			for (int y = -BlurRadius; y <= BlurRadius; y++) {
				
				// Instantiate the vector once and use it twice
				Vector vec = Vector(x, y);
				
				// Get the pixel color at the give position, multiply it by the gauss value
				Gradient += Texel( Texture, textureCoord + vec * SizeFactor ) * gauss(vec, Deviation);
				
			}
			
		}
		
		// Return the output color multiplied by the setColor value
		return vec4( Gradient.rgb, 1E0 ) * Color;
		
	}
	
]]

Shadows.ShapeShader = love.graphics.newShader [[
	
	// Effect that renders the shape of a image
	vec4 effect(vec4 Color, Image Texture, Vector textureCoord, Vector pixelCoord) {
		
		// Get the pixel color at the given texture
		vec4 pixel = Texel(Texture, textureCoord);
		
		// If it's alpha is higher than zero
		if ( pixel.a > 0.0 ) {
			
			// If it's not black
			if ( pixel.r > 0.0 || pixel.g > 0.0 || pixel.b > 0.0 ) {
				
				// Return the setColor value
				return Color;
				
			}
			
		}
		
		// Return invisible color
		return vec4(0.0, 0.0, 0.0, 0.0);
		
	}
	
]]

-- Normal Map shader
Shadows.NormalShader = love.graphics.newShader [[
	
	// Position of the light
	extern vec3 LightPos;
	
	vec4 effect(vec4 Color, Image Texture, Vector textureCoord, Vector pixelCoord) {
		
		// Color of the pixel (the normal)
		vec4 NormalMap = Texel(Texture, textureCoord);
		
		// Direction of the light
		// I don't know why but the formula for the 'y' coordinate seems to solve a issue here
		vec3 LightDir = vec3( LightPos.x - pixelCoord.x, -abs(LightPos.y - pixelCoord.y), LightPos.z);
		
		// Normalize the normal map
		vec3 N = normalize(NormalMap.rgb * 2.0 - 1.0);
		
		// Normalize the light direction
		vec3 L = normalize(LightDir);
		
		// Get the dot product between the both and return the output color
		return Color * ( 1.0 - dot(N, L) );
		
	}
	
]]

Shadows.HeightShader = love.graphics.newShader [[
	
	// Position of the light
	extern vec3 LightPos;
	
	// Supposed center of the canvas
	extern vec3 LightCenter;
	
	// Texture position in map
	extern vec3 MapPos;
	
	// Size of the canvas
	extern Vector Size;
	
	// Height map texture
	extern Image Texture;
	
	vec4 effect(vec4 Color, Image tex, Vector tc, Vector pixelCoord) {
		
		// Size factor
		Vector inverseSize = 1.0 / Size;
		
		// Calculating moved 'tc'
		Vector textureCoord = ( LightPos.xy - LightCenter.xy + pixelCoord - MapPos.xy ) / Size;
		
		// Height on the height map at this point
		float pointHeight = Texel(Texture, textureCoord).r;
		
		// Light direction
		vec3 LightDir = vec3( LightCenter.xy - pixelCoord.xy, LightPos.z );
		
		// Normalized light direction
		vec3 L = normalize(LightDir);
		
		// Distance from the light
		float Distance = length(LightDir);
		
		// From the source position to the given point
		for (float i = 0.0; i < Distance; i++) {
			
			// Calculate every point within
			Vector position = textureCoord + L.xy * i / Size;
			
			// If it's within the canvas
			if ( position.x > 0.0 && position.y > 0.0 && position.x < 1.0 && position.y < 1.0 ) {
			
				// Get the pixel height at the given position
				float pixelHeight = Texel(Texture, position).r;
				
				// If it's lower thatn the height at some point
				if (pixelHeight > pointHeight) {
				
					// Check if it's covered by it
					if ( LightPos.z / Distance <= pixelHeight * MapPos.z / i ) {
					
						// Return white (this point will be darken)
						return vec4(1.0, 1.0, 1.0, 1.0);
						
					}
					
				}
				
			}
			
		}
		
		// Return invisible color (alpha zero)
		return vec4(0.0, 0.0, 0.0, 0.0);
		
	}
	
]]

Shadows.DropShadows = love.graphics.newShader [[
	extern vec3	lightPosition;
	extern number	lightRadius;
	extern number	lightRadiusMult;
	extern Image	texure;
	extern Vector	textureSize;
	extern number	textureZ;
	vec4 effect(vec4 color, Image _t, Vector texture_coords, Vector screen_coords) {
		// Calculate offset on canvas
		number	scale		= lightPosition.z / ( lightPosition.z - textureZ );
		number	textureOffset	= ( scale - 1.0 ) * 0.5;
		
		// Inverse of the texture size
		Vector	iTextureSize	= 1.0 / textureSize;
		
		// Position of the pixel
		vec3	textureCoord3	= vec3(screen_coords * iTextureSize, 0.0);
		
		// Alpha of the shadow
		number	pointDarken	= 0.0;
		number	pointCount	= 0.0;
		
		// Inverse of the light radius
		number	iLightRadius	= 1.0 / lightRadius;
		
		// For each pixel offset on the light's position
		for (number x = -lightRadius; x < lightRadius; x++) {
			for (number y = -lightRadius; y < lightRadius; y++) {
				
				Vector	vec		= Vector(x, y);
				number	vecLength	= length(vec);
				
				if ( vecLength <= lightRadius ) {
					
					// Which position on the light source
					vec3 position		= lightPosition + textureOffset + vec3(vec * lightRadiusMult * iTextureSize, 0.0);
					
					// Direction from the pixel position, to the light position
					vec3 direction		= normalize(position - textureCoord3);
					
					// Position on the texture's layer
					vec3 point		= textureCoord3 + ( direction / direction.z ) * textureZ;
					
					// Color on the texture
					vec4 pixelColor		= Texel(texure, point.xy - textureOffset);
					
					// Is it not a color?
					if (pixelColor.r > 0.0 || pixelColor.g > 0.0 || pixelColor.b > 0.0 || pixelColor.a > 0.0) {
						// Make the pixel darker
						pointDarken += vecLength * iLightRadius;
					}
					
					// Increment the number of pixels used
					pointCount++;
				}
			}
		}
		
		return vec4(0.0, 0.0, 0.0, pointDarken / pointCount);
		
	}
]]