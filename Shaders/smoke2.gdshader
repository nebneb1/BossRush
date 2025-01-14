shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform bool transparent = false;
uniform float transparent_thresh : hint_range(0.0, 1.0, 0.001);
uniform bool add_color = false;

//uniform float threshold1 	: hint_range(0.0,1.0) = .1;
//uniform float threshold2 	: hint_range(0.0,1.0) = .4;
//uniform float threshold3	: hint_range(0.0,1.0) = .6;
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
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 pixelColor = texture(SCREEN_TEXTURE, SCREEN_UV);
	float brightness = pow((pixelColor.r+pixelColor.g+pixelColor.b)/3.0, 2.0);
	
	COLOR.rgb = hueShift(vec3(brightness, 0.0, brightness)*10.0, brightness*100.0);
	COLOR.b += COLOR.g; 
	COLOR.g = 0.0;
	if(transparent && length(COLOR.rgb) <= transparent_thresh){
		COLOR = vec4(0.0);
	}
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
