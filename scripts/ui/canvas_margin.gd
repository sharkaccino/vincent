extends MarginContainer

func on_active_project_changed() -> void:
	visible = true

func on_project_removed(_p) -> void:
	if StateManager.projects.size() == 0:
		visible = false

func _ready() -> void:
	visible = false
	StateManager.active_project_changed.connect(on_active_project_changed)
	StateManager.project_removed.connect(on_project_removed)
