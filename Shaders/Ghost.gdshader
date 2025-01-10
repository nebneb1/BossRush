shader_type canvas_item;

uniform vec4 GhostColor : source_color;


void fragment() {
	vec4 PixelColor = texture(TEXTURE, UV);
	if (PixelColor.a >= 0.05){
		PixelColor = GhostColor;
	}
	
	COLOR = PixelColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
