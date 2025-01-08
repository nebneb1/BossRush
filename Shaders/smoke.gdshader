shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


uniform vec4 colors[10] : source_color;

//uniform float threshold1 	: hint_range(0.0,1.0) = .1;
//uniform float threshold2 	: hint_range(0.0,1.0) = .4;
//uniform float threshold3	: hint_range(0.0,1.0) = .6;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 pixelColor = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 lowest_dist_color = colors[0].rgb;
	float lowest_dist = 10000.0;
	
	for(int i = 0; i < 10; i++){
		if (distance(colors[i].rgb, pixelColor.rgb) < lowest_dist){
			lowest_dist = distance(colors[i].rgb, pixelColor.rgb);
			lowest_dist_color = colors[i].rgb;
		}
	}
	COLOR = vec4(lowest_dist_color.rgb, pixelColor.a);
	
	//if(length(COLOR.rgb) <= 0.01){
	//	COLOR = vec4(0.0);
	//}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
