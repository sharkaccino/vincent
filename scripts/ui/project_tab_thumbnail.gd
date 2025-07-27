extends TextureRect

# TODO: update when any change is made to the image

# TODO: show the combined output of all layers merged together.

func _ready() -> void:
	var current_project = StateManager.get_project_data(get_node("../../../..").get_meta("project_id"))
	if current_project == null: return
	texture = ImageTexture.create_from_image(current_project.layers[0].image_data)
