extends TextureButton

func _pressed() -> void:
	StateManager.set_primary_color(Color(0,0,0,1))
	StateManager.set_secondary_color(Color(1,1,1,1))
