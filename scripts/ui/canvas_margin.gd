extends MarginContainer

func on_active_project_changed() -> void:
	if StateManager.active_project_id == 0:
		visible = false
	else:
		visible = true

func _ready() -> void:
	visible = false
	StateManager.active_project_changed.connect(on_active_project_changed)
