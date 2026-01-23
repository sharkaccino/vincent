extends TextureRect

# TODO: update when any change is made to the image

# TODO: show the combined output of all layers merged together.

func _ready() -> void:
	var connected_project = StateManager.get_project_data(get_node("../../../..").get_meta("project_id"))
	if connected_project.id == 0: return
	
	texture = ImageTexture.create_from_image(connected_project.layers[0].image_data)
	
	await get_tree().process_frame
	
	var t_size = get_rect().size
	var p_size = connected_project.size
	
	print(t_size, p_size, p_size.x > t_size.x || p_size.y > t_size.y)
	
	if (p_size.x > t_size.x || p_size.y > t_size.y):
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	else:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
