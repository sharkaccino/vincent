extends TextureRect

@onready var project_id = get_node("../../../..").get_meta("project_id")

func update_thumbnail() -> void:
	if (project_id == 0): return
	if (StateManager.active_project_id != project_id): return
	
	var image_data: Image = await CanvasManager.get_image()
	
	await get_tree().process_frame
	
	# TODO: use set_image() when canvas resolution is changed
	texture.update(image_data)

func check_filter_mode() -> void:
	var connected_project = StateManager.get_project_data(project_id)
	if connected_project.id == 0: return
	
	var t_size = get_rect().size
	var p_size = connected_project.size
	
	#print(t_size, p_size, p_size.x > t_size.x || p_size.y > t_size.y)
	
	if (p_size.x > t_size.x || p_size.y > t_size.y):
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	else:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _ready() -> void:
	var connected_project = StateManager.get_project_data(project_id)
	if connected_project.id == 0: return
	
	# TODO: use texture2DRD instead
	var image_data: Image = await CanvasManager.get_image()
	texture = ImageTexture.create_from_image(image_data)
	
	await get_tree().process_frame
	
	check_filter_mode()
	
	#CanvasManager.canvas_update.connect(update_thumbnail)
