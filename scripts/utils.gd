extends Node

func get_bounding_box_size(initial_box_size: Vector2, angle_radians: float) -> Vector2:
	var halfWidth = initial_box_size.x / 2
	var halfHeight = initial_box_size.y / 2
	var newWidth = abs(halfWidth * cos(angle_radians)) + abs(halfHeight * sin(angle_radians))
	var newHeight = abs(halfWidth * sin(angle_radians)) + abs(halfHeight * cos(angle_radians))
	return Vector2(newWidth * 2, newHeight * 2)
