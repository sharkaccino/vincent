shader_type canvas_item;

uniform float current_hue;

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
	vec3 output = vec3(1);
	vec3 hue = hsl_to_rgb(vec3(current_hue, 1, 0.5));
	output = mix(output, hue, UV.x);
	output *= 1.0 - UV.y;
	
	COLOR *= vec4(output, 1);
}