shader_type canvas_item;

uniform vec4 color1;
uniform vec4 color2;
uniform int mode : hint_enum("gradient", "hue", "lightness");

vec3 hsl_to_rgb(vec3 hsl) {
	float H = hsl.x;
	float S = hsl.y;
	float L = hsl.z;
	
	float C = (1.0 - abs(2.0 * L - 1.0)) * S;
	float Hp = H * 6.0;
	float X = C * (1.0 - abs(mod(Hp, 2.0) - 1.0));
	
	vec3 rgb1;
	if (0.0 <= Hp && Hp < 1.0) {
		rgb1 = vec3(C, X, 0.0);
	} else if (1.0 <= Hp && Hp < 2.0) {
		rgb1 = vec3(X, C, 0.0);
	} else if (2.0 <= Hp && Hp < 3.0) {
		rgb1 = vec3(0.0, C, X);
	} else if (3.0 <= Hp && Hp < 4.0) {
		rgb1 = vec3(0.0, X, C);
	} else if (4.0 <= Hp && Hp < 5.0) {
		rgb1 = vec3(X, 0.0, C);
	} else {
		rgb1 = vec3(C, 0.0, X);
	}
	
	float m = L - 0.5 * C;
	return rgb1 + vec3(m);
}

void fragment() {
	if (mode == 1) {
		// hue
		if (color1.a == 0.0) discard;
		float s_offset = 0.5 - (color1.g * 0.5);
		COLOR *= vec4(hsl_to_rgb(vec3(UV.x, color1.g, color1.b * (0.5 + s_offset))), color1.a);
	} else if (mode == 2) {
		// lightness
		if (color1.a == 0.0) discard;
		vec3 col = hsl_to_rgb(vec3(color1.r, color1.g, UV.x));
		COLOR *= vec4(col, color1.a);
	} else {
		// gradient
		vec4 col = mix(color1, color2, UV.x);
		if (col.a == 0.0) discard;
		//col.rgb /= col.a;
		COLOR *= col;
	}
}