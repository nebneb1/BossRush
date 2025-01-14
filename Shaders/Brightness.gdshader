shader_type canvas_item;

uniform float brightness : hint_range(0.0, 10.0, 0.01);
uniform float contrast : hint_range(0.0, 10.0, 0.01);

void fragment() {
	COLOR.rgb *= brightness;
	COLOR.rgb = pow(COLOR.rgb, vec3(contrast));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
