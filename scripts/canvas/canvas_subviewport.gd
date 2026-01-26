extends SubViewport

@onready var layer_content = get_node("%LayerContent")

func on_canvas_update_request() -> void:
	if (StateManager.active_project_id == 0):
		return
		
	var active_project = StateManager.get_active_project()
	
	var layer = active_project.active_layer_index
	var layer_content_data = active_project.layers[layer].image_data
	layer_content.texture.set_image(layer_content_data)
	
	await RenderingServer.frame_post_draw
	
	var image_data = get_texture().get_image()
	
	# fixes subviewport alpha premultiplication
	for y in image_data.get_size().y:
		for x in image_data.get_size().x:
			var color: Color = image_data.get_pixel(x, y)
			if (color.a != 0):
				var r = color.r
				var g = color.g
				var b = color.b
				var a = color.a
				image_data.set_pixel(x, y, Color(r/a, g/a, b/a, a))
	
	active_project.layers[layer].image_data = image_data
	
	StateManager.canvas_updated.emit()

func on_project_changed() -> void:
	if (StateManager.active_project_id == 0):
		layer_content.texture = null
		return
		
	var active_project = StateManager.get_active_project()
	size = active_project.size
	
	var layer = active_project.active_layer_index
	var layer_content_data = active_project.layers[layer].image_data
	layer_content.texture = ImageTexture.create_from_image(layer_content_data)

func _ready() -> void:
	StateManager.canvas_update_request.connect(on_canvas_update_request)
	StateManager.active_project_changed.connect(on_project_changed)
