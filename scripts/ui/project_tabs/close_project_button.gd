extends Button

func _on_pressed() -> void:
	var project_id = get_node("../../../..").get_meta("project_id")
	StateManager.remove_project(project_id)

func _ready() -> void:
	pressed.connect(_on_pressed)
