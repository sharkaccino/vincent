shader_type canvas_item;

uniform float size;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 center = UV * vec2(2) - vec2(1);
	float circle = length(center);
	float pixel_size = 1.0 / (size / 2.5);
	
	float outer_mask = smoothstep(1.0, 1.0 - pixel_size, circle);
	float inner_mask_offset = 1.0 - (pixel_size * 3.0);
	float inner_mask = smoothstep(inner_mask_offset, inner_mask_offset + pixel_size, circle);
	
	float ring_mask = outer_mask * inner_mask;

	float offset = pixel_size;
	float final_color = smoothstep((1.0 - offset) - pixel_size, (1.0 - offset), circle);
	float final_mask = ring_mask;
	
	COLOR = vec4(vec3(final_color),final_mask);
}