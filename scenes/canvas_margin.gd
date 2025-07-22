extends MarginContainer

func _on_viewport_resized() -> void:
	var newDimensions = get_parent_area_size()
	add_theme_constant_override("margin_left", newDimensions.x / 2)
	add_theme_constant_override("margin_right", newDimensions.x / 2)
	add_theme_constant_override("margin_top", newDimensions.y / 2)
	add_theme_constant_override("margin_bottom", newDimensions.y / 2)
