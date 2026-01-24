extends TextureRect

@onready var project_id = get_node("../../../..").get_meta("project_id")

func update_thumbnail() -> void:
	# TODO: show the combined output of all layers merged together.
	
	var connected_project = StateManager.get_project_data(project_id)
	if (connected_project.id == 0): return
	
	texture = ImageTexture.create_from_image(connected_project.layers[0].image_data)

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
	
	await get_tree().process_frame
	
	check_filter_mode()
	update_thumbnail()
	
	StateManager.canvas_updated.connect(update_thumbnail)
