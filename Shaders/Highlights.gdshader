shader_type canvas_item;

uniform float brightness_threshold : hint_range(0.0, 10.0, 0.01);
uniform float noise_affect;
uniform sampler2D noise;


void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	float brightness = pixelColor.r * 0.299 + pixelColor.g * 0.587 + pixelColor.b * 0.114;
	if(brightness + (texture(noise, UV).r * noise_affect) > brightness_threshold + 0.5*noise_affect*(cos(sin(TIME)*texture(noise, UV).r)+1.0)){
		COLOR = pixelColor;
	}else{
		COLOR = vec4(0.0);
	}
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
