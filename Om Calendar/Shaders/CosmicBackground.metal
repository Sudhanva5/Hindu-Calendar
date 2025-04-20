#include <metal_stdlib>
using namespace metal;

// Uniform buffer to pass dynamic values from Swift
struct Uniforms {
    float2 resolution;  // Screen resolution (width, height)
    float time;         // Time elapsed since start (used for animations)
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;         // Texture coordinates
};

// Background gradient colors (format: R, G, B, A)
constant float4 TopColor = float4(0.027, 0.046, 0.07, 1);     // Bottom Color
constant float4 BottomColor = float4(0.0, 0.0, 0.0, 1);  // Top Color

// Star colors (format: R, G, B, A)
// Increase the alpha (last number) to make stars brighter
constant float4 Star1Color = float4(1, 0.94, 0.72, 1.0);    // Warm white
constant float4 Star2Color = float4(0.8, 0.8, 1.0, 1.0);    // Cool white
constant float4 Star3Color = float4(0.63, 0.50, 0.81, 1.0); // Purple

// Star field configuration
constant float Grid = 38.0;        // Higher number = fewer stars (try 40-60)
constant float Size = 0.12;         // Base star size (try 0.3-0.5)
constant float2 Speed = float2(5.8, 2.0);  // Parallax movement speed (x, y)

// Twinkling configuration
constant float TwinkleSpeed = 8.0;   // How fast stars twinkle (try 2-5)
constant float TwinkleAmount = 0.8;  // How much stars twinkle (try 0.3-0.7)

// Generates a pseudo-random number between 0 and 1
float rand(float2 coord, float seed) {
    return fract(sin(dot(coord, float2(12.9898, 78.233)) + seed) * 43758.5453);
}

// Generates a random 2D offset for star positions
float2 randVector(float2 vec, float seed) {
    return float2(
        rand(vec, seed * 123.456),
        rand(vec, seed * 789.012)
    ) - 0.5;
}

// Calculates star brightness including twinkling effect
float calculateStarBrightness(float baseRadius, float2 gridPos, float time, float seed) {
    // Basic star brightness
    float brightness = baseRadius;
    
    // Add twinkling effect
    float twinkle = sin(time * TwinkleSpeed + rand(gridPos, seed) * 6.28318) * 0.5 + 0.5;
    brightness *= 1.0 + (twinkle * TwinkleAmount);
    
    // Smooth the brightness falloff
    return smoothstep(0.0, 1.0, brightness);
}

// Draws a layer of stars with specified parameters
void drawStars(thread float4& fragColor,    // Output color
               float4 color,                 // Star color
               float2 uv,                    // Screen coordinates
               float grid,                   // Grid size (spacing between stars)
               float size,                   // Star size
               float2 speed,                 // Movement speed
               float seed,                   // Random seed
               float time) {                 // Current time
    // Add parallax movement
    uv += time * speed;
    
    // Calculate local grid position
    float2 local = fmod(uv, grid) / grid;
    
    // Get random offset for this star
    float2 randv = randVector(floor(uv/grid), seed) - 0.5;
    float len = length(randv);
    
    // Only draw star if random position is within bounds
    if (len < 0.4) {  // Decreased from 0.5 for fewer stars
        // Calculate distance from star center
        float dist = distance(local, float2(0.5, 0.5) + randv);
        
        // Calculate star radius with position-based size variation
        float radius = 1.0 - dist / (size * (0.7 - len));
        
        // Add star to output if visible
        if (radius > 0.0) {
            float brightness = calculateStarBrightness(radius, floor(uv/grid), time, seed);
            fragColor += color * brightness * 1.5;  // Increased multiplier for brighter stars
        }
    }
}

// Vertex shader - Sets up the full-screen quad
vertex VertexOut cosmic_vertex(uint vertexID [[vertex_id]]) {
    const float2 vertices[] = {
        float2(-1, -1),  // Bottom left
        float2(-1,  1),  // Top left
        float2( 1, -1),  // Bottom right
        float2( 1,  1)   // Top right
    };
    
    VertexOut out;
    out.position = float4(vertices[vertexID], 0, 1);
    out.uv = (vertices[vertexID] + 1.0) * 0.5;  // Convert to 0-1 range
    return out;
}

// Fragment shader - Renders the cosmic background
fragment float4 cosmic_fragment(VertexOut in [[stage_in]],
                              constant Uniforms& uniforms [[buffer(0)]]) {
    // Calculate pixel coordinates
    float2 fragCoord = in.uv * uniforms.resolution;
    
    // Create background gradient
    float4 fragColor = mix(TopColor, BottomColor, in.uv.y);
    
    // Draw three layers of stars with different properties
    // Layer 1: Large, bright stars
    drawStars(fragColor, Star1Color, fragCoord, Grid, Size * 1.2, Speed, 123.456, uniforms.time);
    
    // Layer 2: Medium, bluish stars
    drawStars(fragColor, Star2Color, fragCoord, Grid * 1.5, Size, Speed * 0.7, 456.789, uniforms.time);
    
    // Layer 3: Small, purple stars (deeper parallax)
    drawStars(fragColor, Star3Color, fragCoord, Grid * 2.0, Size * 0.8, Speed * 0.5, 789.012, uniforms.time);
    
    return fragColor;
} 
