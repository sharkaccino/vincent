extends TextureButton

func _pressed() -> void:
	var primary = Color(StateManager.primary_color)
	var secondary = Color(StateManager.secondary_color)
	
	StateManager.set_primary_color(secondary)
	StateManager.set_secondary_color(primary)
