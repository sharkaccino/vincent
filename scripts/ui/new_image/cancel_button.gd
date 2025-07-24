extends Button

func _on_pressed() -> void:
	get_window().hide()

func _ready() -> void:
	pressed.connect(_on_pressed)
