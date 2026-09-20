shader_type canvas_item;

uniform float texture_scale : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 shifted_uv = UV - vec2(0.5);

    shifted_uv = shifted_uv / texture_scale;

    vec2 final_uv = shifted_uv + vec2(0.5);

    if (final_uv.x >= 0.0 && final_uv.x <= 1.0 && final_uv.y >= 0.0 && final_uv.y <= 1.0) {
        COLOR = texture(TEXTURE, final_uv);
    } else {
        COLOR = vec4(0.0);
    }
}