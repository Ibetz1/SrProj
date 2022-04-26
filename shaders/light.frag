// Radius of the light effect
extern float Radius;

// Center of the light
extern vec3 Position;

extern vec2 Glow = vec2(1, 1);
extern float Smooth = 1.5;

extern Image NormalMap;

vec4 effect(vec4 pixel, Image Texture, vec2 tc, vec2 pc) {
    
    // Distance between the screen pixel and the center of the light
    vec3 Delta = vec3(pc, 0.0) - Position;
    float Distance = length( Delta );


    // If the distance is lower than the radius
    if (Distance <= Radius) {
        float att = clamp((1.0 - Distance / Radius) / Smooth, 0.0, 1.0);

        return vec4(clamp(pixel.rgb * pow(att, Smooth) + pow(smoothstep(Glow.x, 1.0, att), Smooth) * Glow.y, 0.0, 1.0), 1);
    }
    
    discard;
}