extends MarginContainer

func _on_active_project_changed(_p) -> void:
	visible = true

func _on_project_removed(_p) -> void:
	if StateManager.projects.size() == 0:
		visible = false

func _ready() -> void:
	visible = false
	StateManager.active_project_changed.connect(_on_active_project_changed)
	StateManager.project_removed.connect(_on_project_removed)
