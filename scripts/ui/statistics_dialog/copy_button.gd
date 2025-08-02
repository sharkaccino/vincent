extends Button

func _on_pressed() -> void:
	# TODO: copy stats to clipboard
	pass
	
func _ready() -> void:
	pressed.connect(_on_pressed)
	
