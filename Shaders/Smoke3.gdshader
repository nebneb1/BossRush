shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float weird = 2.0;
uniform vec4 default_color : source_color;
uniform float default_color_threshold : hint_range(0.0, 0.1, 0.001);
uniform vec4 colors[10] : source_color;


vec3 hueShift( vec3 color, float hueAdjust ){

    const vec3  kRGBToYPrime = vec3 (0.299, 0.587, 0.114);
    const vec3  kRGBToI      = vec3 (0.596, -0.275, -0.321);
    const vec3  kRGBToQ      = vec3 (0.212, -0.523, 0.311);

    const vec3  kYIQToR     = vec3 (1.0, 0.956, 0.621);
    const vec3  kYIQToG     = vec3 (1.0, -0.272, -0.647);
    const vec3  kYIQToB     = vec3 (1.0, -1.107, 1.704);

    float   YPrime  = dot (color, kRGBToYPrime);
    float   I       = dot (color, kRGBToI);
    float   Q       = dot (color, kRGBToQ);
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    hue += hueAdjust;

    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    vec3    yIQ   = vec3 (YPrime, I, Q);

    return vec3( dot (yIQ, kYIQToR), dot (yIQ, kYIQToG), dot (yIQ, kYIQToB) );
}
//uniform float threshold1 	: hint_range(0.0,1.0) = .1;
//uniform float threshold2 	: hint_range(0.0,1.0) = .4;
//uniform float threshold3	: hint_range(0.0,1.0) = .6;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 pixelColor = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float brightness = pow((pixelColor.r+pixelColor.g+pixelColor.b)/3.0, weird);
	if (brightness < default_color_threshold){
		pixelColor.rgb = hueShift(vec3(brightness*1.5, brightness, brightness*2.0)*10.0, brightness*1000.0);
		
		vec3 lowest_dist_color = colors[0].rgb;
		float lowest_dist = 10000.0;
		
		for(int i = 0; i < 10; i++){
			if (distance(colors[i].rgb, pixelColor.rgb) < lowest_dist){
				lowest_dist = distance(colors[i].rgb, pixelColor.rgb);
				lowest_dist_color = colors[i].rgb;
			}
		}
		COLOR = vec4(lowest_dist_color.rgb, pixelColor.a);
	} else {
		COLOR = default_color;
	}
	
	
	if(length(COLOR.rgb) <= 0.3){
		COLOR = vec4(0.0);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
