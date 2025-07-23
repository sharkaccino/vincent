extends Label

func _ready() -> void:
	var current_project = StateManager.get_project_data(get_node("../../../..").get_meta("project_id"))
	if current_project == null: return
	text = current_project.name
