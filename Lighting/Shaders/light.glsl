// Radius of the light effect
extern float Radius;

// Center of the light
extern vec3 Position;

vec4 effect(vec4 Color, Image Texture, vec2 tc, vec2 pc) {
    
    // Distance between the screen pixel and the center of the light
    vec3	Delta		=	vec3(pc, 0.0) - Position;
    float Distance =	length( Delta );
    
    // If the distance is lower than the radius
    if (Distance <= Radius) {
        
        // Return the 100% of the alpha, minus the distance from the light divided by the radius
        return vec4( Color.rgb, 1.0 - length( Delta / Radius ) );
        
    }
    
    discard;
}