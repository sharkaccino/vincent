extends Label

# TODO: update displayed resolution when changed

func _ready() -> void:
	var current_project = StateManager.get_project_data(get_node("../../../..").get_meta("project_id"))
	if current_project.id == 0: return
	text = str(current_project.size.x) + " x " + str(current_project.size.y)
