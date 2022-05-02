// Size of the canvas on which the effect is applied
extern vec2 Size;

// Multiplier to the size factor (how far is the effect applied? 100% by default)
const float Quality = 3.0;

// The radius of the pixels that are analized
const float Radius = 1.0;

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc) {
    
    vec4 Sum = vec4(0);
    vec2 SizeFactor = vec2(Quality / Size);
    
    for (float x = -Radius; x <= Radius; x++) {
        
        for (float y = -Radius; y <= Radius; y++) {
            
            Sum += Texel(tex, tc + vec2(x, y) * SizeFactor);
            
        }
    }
    
    float Delta = 2.0 * Radius + 1.0;
    
    return Sum / vec4( Delta * Delta );
    
}