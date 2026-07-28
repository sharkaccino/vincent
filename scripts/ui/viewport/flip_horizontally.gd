extends Button

func _pressed() -> void:
	StateManager.set_flip_horizontal(button_pressed)
