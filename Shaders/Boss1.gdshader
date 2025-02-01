shader_type canvas_item;

uniform vec4 goop_mask_color : source_color;
uniform float tolerance : hint_range(0.01, 1.0, 0.01) = 0.5;
uniform vec4 goop_background_color : source_color;

uniform vec3 outline_color: source_color;
uniform float progress: hint_range(0.0, 1.0);
uniform sampler2D noise;
uniform float width = 0.00263;
uniform float ymult = 2.108;
uniform float distort_intencity;

bool is_goop(vec4 color){
	return distance(color.rgb, goop_mask_color.rgb) < tolerance;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 line_neg_y = vec4(outline_color.rgb, texture(TEXTURE, vec2(UV.x, UV.y - width*ymult)).a);
	vec4 line_pos_y = vec4(outline_color.rgb, texture(TEXTURE, vec2(UV.x, UV.y + width*ymult)).a);
	vec4 line_neg_x = vec4(outline_color.rgb, texture(TEXTURE, vec2(UV.x - width, UV.y)).a);
	vec4 line_pos_x = vec4(outline_color.rgb, texture(TEXTURE, vec2(UV.x + width, UV.y)).a);
	vec4 outline_y = mix(line_neg_y, line_pos_y, line_pos_y);
	vec4 outline_x = mix(line_neg_x, line_pos_x, line_pos_x);
	vec4 outline = mix(outline_y, outline_x, outline_x);
	vec4 outline_color_layer = mix(COLOR, outline, progress * (1.0 - COLOR.a));
	
	
	vec2 uv = UV;
	uv.x += (texture(noise, uv).r * 2.0 - 1.0)/500.0 * distort_intencity;
	
	vec4 pixelColor = texture(TEXTURE, uv);
	vec4 temp = pixelColor;
	if(distance(pixelColor, goop_mask_color) < tolerance){
		pixelColor = goop_background_color;
	}
	
	
	pixelColor = pixelColor + outline_color_layer - temp + (vec4(1.0) -  texture(TEXTURE, uv) * texture(TEXTURE, UV)) * distort_intencity;
	COLOR = pixelColor;
	
	
	
	//vec4 temp = pixelColor;
	//// if pixel color is within tolerance, there has to be a better way to do this lol
	//if(is_goop(pixelColor)){
		//pixelColor = goop_background_color;
	//} else {
		//pixelColor = vec4(0.0);
	//}
	//COLOR.a = temp.a;
	//COLOR = pixelColor;
}



//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
