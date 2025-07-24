extends TextureRect

func _on_active_project_changed(project_id) -> void:
	var current_project = StateManager.get_project_data(project_id)
	texture = ImageTexture.create_from_image(current_project.test_image_data)

func _on_project_removed(_i) -> void:
	if StateManager.projects.size() == 0:
		texture = null

func _ready() -> void:
	custom_minimum_size = Vector2(0, 0)
	StateManager.active_project_changed.connect(_on_active_project_changed)
	StateManager.project_removed.connect(_on_project_removed)
