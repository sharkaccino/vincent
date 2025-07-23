extends TextureRect

func _ready() -> void:
	var current_project = StateManager.get_project_data(get_node("../../../..").get_meta("project_id"))
	if current_project == null: return
	texture = ImageTexture.create_from_image(current_project.test_image_data)
