shader_type canvas_item;

uniform float amount : hint_range(0, 1) = 0.0;
uniform float diamondPixelSize = 40.0;

void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
	float yFraction = fract(FRAGCOORD.y / diamondPixelSize);

	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);

	if (xDistance + yDistance + UV.x + UV.y > amount * 4.0) {
		discard;
	}
}