extends TextureRect

func _on_project_added(_i) -> void:
	visible = true

func _on_project_removed(_i) -> void:
	if StateManager.projects.size() == 0:
		visible = false

func _ready() -> void:
	visible = false
	custom_minimum_size = Vector2(0, 0)
	StateManager.project_added.connect(_on_project_added)
	StateManager.project_removed.connect(_on_project_removed)
