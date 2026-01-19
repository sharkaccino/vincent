extends TextureRect

# TODO: show the combined output of all layers merged together.

func on_active_project_changed() -> void:
	if StateManager.active_project_id == 0:
		texture = null
	else:
		var active_project = StateManager.get_active_project()
		texture = ImageTexture.create_from_image(active_project.layers[0].image_data)

func _ready() -> void:
	custom_minimum_size = Vector2(0, 0)
	StateManager.active_project_changed.connect(on_active_project_changed)
