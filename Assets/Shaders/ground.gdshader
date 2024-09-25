shader_type canvas_item;

uniform vec2 dir = vec2(1.0, 0.0);
uniform float spd = 0.8;

void fragment() {
	COLOR = texture(TEXTURE, UV + (dir * TIME * spd));
}
