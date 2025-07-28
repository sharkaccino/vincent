extends Button

@onready var project_id = get_meta("project_id")

func _on_pressed() -> void:
	# TODO: ignore if this is already the active project
	StateManager.set_active_project(project_id)

func _ready() -> void:
	var this_project = StateManager.get_project_data(project_id)
	tooltip_text = this_project.name
	pressed.connect(_on_pressed)
