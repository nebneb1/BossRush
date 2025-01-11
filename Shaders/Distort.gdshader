shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Center of the whirl effect
uniform vec2 center = vec2(0.5, 0.5);

// Intensity of the whirl effect
uniform float strength : hint_range(-10.0, 10.0) = 1.0;

// Falloff of the effect: how the intensity decreases with distance
uniform float falloff : hint_range(0.1, 10.0) = 1.0;

// Rotation direction (positive for clockwise, negative for counterclockwise)
uniform float direction : hint_range(-1.0, 1.0) = 1.0;

// Tiling effect: scale UV coordinates
uniform vec2 tiling = vec2(1.0, 1.0);

// Color tint multiplier
uniform vec4 color_tint = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Adjust UV coordinates for tiling
    vec2 uv = SCREEN_UV * tiling;

    // Calculate the offset from the center
    vec2 offset = uv - center;

    // Compute the distance from the center
    float distance = length(offset);

    // Apply falloff to the strength
    float adjusted_strength = strength * pow(distance, falloff);

    // Compute the angle of rotation
    float angle = direction * adjusted_strength;

    // Rotate the offset
    float cos_angle = cos(angle);
    float sin_angle = sin(angle);
    vec2 rotated_offset = vec2(
        cos_angle * offset.x - sin_angle * offset.y,
        sin_angle * offset.x + cos_angle * offset.y
    );

    // Map the rotated offset back to UV space
    vec2 rotated_uv = center + rotated_offset;

    // Sample the screen texture using the rotated UV coordinates
    vec4 sampled_color = texture(SCREEN_TEXTURE, rotated_uv);

    // Apply color tint
    COLOR = sampled_color * color_tint;
}
