shader_type canvas_item;

uniform vec2 dir = vec2(1.0, 0.0);
uniform float offset = 0.0;

void fragment() {
	COLOR = texture(TEXTURE, UV + dir * offset);
}