extends TextureRect

# TODO: show the combined output of all layers merged together.

func on_active_project_changed() -> void:
	var active_project = StateManager.get_active_project()
	texture = ImageTexture.create_from_image(active_project.layers[0].image_data)

func on_project_removed(_i) -> void:
	if StateManager.projects.size() == 0:
		texture = null

func _ready() -> void:
	custom_minimum_size = Vector2(0, 0)
	StateManager.active_project_changed.connect(on_active_project_changed)
	StateManager.project_removed.connect(on_project_removed)
