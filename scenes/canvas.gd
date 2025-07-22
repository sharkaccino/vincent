extends TextureRect

func update_image() -> void:
	var current_project = StateManager.projects[StateManager.active_project]
	texture = ImageTexture.create_from_image(current_project._image_data)

func _ready() -> void:
	StateManager.projects_changed.connect(update_image)
