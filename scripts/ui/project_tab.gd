extends Button

func _on_pressed() -> void:
	# TODO: ignore if this is already the active project
	StateManager.set_active_project(get_meta("project_id"))

func _ready() -> void:
	pressed.connect(_on_pressed)
