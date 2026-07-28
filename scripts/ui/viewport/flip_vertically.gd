extends Button

func _pressed() -> void:
	StateManager.set_flip_vertical(button_pressed)
