// Radius of the light effect
extern float Radius;

// Center of the light
extern vec3 Position;

extern vec2 Glow = vec2(1, 1);
extern float Smooth = 1.5;

vec4 effect(vec4 pixel, Image Texture, vec2 tc, vec2 pc) {
    
    // Distance between the screen pixel and the center of the light
    vec3 Delta = vec3(pc, 0.0) - Position;
    float Distance = length( Delta );

    float att = clamp((1.0 - Distance / Radius) / Smooth, 0.0, 1.0);


    // If the distance is lower than the radius
    if (Distance <= Radius) {
        
        return vec4(clamp(pixel.rgb * pow(att, Smooth) + pow(smoothstep(Glow.x, 1.0, att), Smooth) * Glow.y, 0.0, 1.0), 1);

        // Return the 100% of the alpha, minus the distance from the light divided by the radius
        // return vec4( Color.rgb * pow(att, Smooth), 1.0 - length( Delta / (Radius) ));
        
    }
    
    discard;
}