extends Button

func _on_pressed() -> void:
	StateManager.set_active_project(get_meta("project_id"))

func _ready() -> void:
	pressed.connect(_on_pressed)
