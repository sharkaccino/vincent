extends Node

func get_bounding_box_size(initial_box_size: Vector2, angle_radians: float) -> Vector2:
	var halfWidth = initial_box_size.x / 2
	var halfHeight = initial_box_size.y / 2
	var newWidth = abs(halfWidth * cos(angle_radians)) + abs(halfHeight * sin(angle_radians))
	var newHeight = abs(halfWidth * sin(angle_radians)) + abs(halfHeight * cos(angle_radians))
	return Vector2(newWidth * 2, newHeight * 2)

func color_to_hsl(hsv: Color) -> Vector4:
	var hsl = Vector4(0,0,0,1)
	
	var lightness = hsv.v * (1.0 - (hsv.s / 2.0))
	var saturation = (hsv.v - lightness) / min(lightness, 1.0 - lightness)
	if (lightness == 0 || lightness == 1):
		saturation = 0.0
	
	hsl.x = hsv.h
	hsl.y = saturation
	hsl.z = lightness
	hsl.w = hsv.a
	
	return hsl

func hsl_to_color(hsl: Vector4) -> Color:
	var hsv = Color(0,0,0,1)
	
	var value = hsl.z + (hsl.y * min(hsl.z, 1.0 - hsl.z))
	var saturation = 2.0 * (1.0 - (hsl.z / value))
	
	if (value == 0):
		saturation = 0.0
	
	hsv.a = hsl.w
	hsv.v = value
	hsv.s = saturation
	hsv.h = hsl.x
	
	return hsv
