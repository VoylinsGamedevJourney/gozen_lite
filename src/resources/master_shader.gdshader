shader_type canvas_item;

uniform vec2 position = vec2(0.0);

uniform float rotation = 0;
uniform float rotation_pivot_x: hint_range (0.0, 1.0, 0.1) = 0.5;
uniform float rotation_pivot_y: hint_range (0.0, 1.0, 0.1) = 0.5;

uniform float scale : hint_range(0.001, 10, 0.001) = 1;
uniform float scale_pivot_x: hint_range (0.0, 1.0, 0.1) = 0.5;
uniform float scale_pivot_y: hint_range (0.0, 1.0, 0.1) = 0.5;

uniform float alpha: hint_range(0.0, 1, 0.001) = 1;
uniform float blur: hint_range(0.0, 5) = 0.0; // TODO

uniform float brightness: hint_range(-1, 1) = 0.0;
uniform float contrast: hint_range(0, 3) = 1.0;
uniform float saturation: hint_range(0, 3) = 1.0;

uniform float red_value: hint_range(0, 1) = 1.0;
uniform float green_value: hint_range(0, 1) = 1.0;
uniform float blue_value: hint_range(0, 1) = 1.0;

uniform vec4 tint_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_effect_factor: hint_range(0, 1) = 0.0;



void fragment() {
	float aspect = TEXTURE_PIXEL_SIZE.x/TEXTURE_PIXEL_SIZE.y;
	float cosine = cos(rotation);
	float sine = sin(rotation);
	
	// Positioning
	vec2 uv = UV - (position * TEXTURE_PIXEL_SIZE);
	
	// Rotation
	uv -= vec2(rotation_pivot_x, rotation_pivot_y);
	uv.x /= aspect;
	uv = vec2(cosine * uv.x - sine * uv.y, cosine * uv.y + sine * uv.x);
	uv.x *= aspect;
	uv += vec2(rotation_pivot_x, rotation_pivot_y);
	
	// Scaling
	uv = (uv - vec2(scale_pivot_x, scale_pivot_y)) / scale + vec2(scale_pivot_x, scale_pivot_y);
	
	// Removing not necessary pixels
	bool is_inside = all(greaterThanEqual(uv, vec2(0.0))) && all(lessThanEqual(uv, vec2(1.0)));
	if (is_inside) {
		// Giving color
		vec4 tex = texture(TEXTURE, uv);
		
		// Brightness
		mat4 brightness_matrix = mat4(
			vec4(1, 0, 0, 0),
			vec4(0, 1, 0, 0),
			vec4(0, 0, 1, 0),
			vec4(brightness, brightness, brightness, 1)
		);
		
		// Contrast
		float contrast_value = (1.0 - contrast) / 2.0;
		mat4 contrast_matrix = mat4(
			vec4(contrast, 0, 0, 0), 
			vec4(0, contrast, 0, 0),
			vec4(0, 0, contrast, 0),
			vec4(contrast_value, contrast_value, contrast_value, 1)
		);
		
		// Saturation
		vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
		float sat_adjust = 1.0 - saturation;
		vec3 red = vec3(luminance.x * sat_adjust) + vec3(saturation, 0, 0) * red_value;
		vec3 green = vec3(luminance.y * sat_adjust) + vec3(0, saturation, 0) * green_value;
		vec3 blue = vec3(luminance.z * sat_adjust) + vec3(0, 0,saturation) * blue_value;
		mat4 saturation_matrix = mat4(
			vec4(red, 0),
			vec4(green,0),
			vec4(blue,0),
			vec4(0, 0, 0, 1)
		);
		
		// TODO: Blur
		
		// Setting correct color
		COLOR = brightness_matrix * contrast_matrix * saturation_matrix * mix(
				tex, tex * tint_color, tint_effect_factor);
		// Transparency
		COLOR.a = alpha;
	} else {
		COLOR = vec4(0.0);
	}
}
