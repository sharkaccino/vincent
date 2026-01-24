extends SubViewport

@onready var layer_content = get_node("%LayerContent")

func on_project_changed() -> void:
	if (StateManager.active_project_id == 0):
		layer_content.texture = null
		return
		
	var active_project = StateManager.get_active_project()
	size = active_project.size
	layer_content.texture = ImageTexture.create_from_image(active_project.layers[0].image_data)
	
	await RenderingServer.frame_post_draw
	
	var image_data = get_texture().get_image()
	for y in image_data.get_size().y:
		for x in image_data.get_size().x:
			var color: Color = image_data.get_pixel(x, y)
			if (color.a != 0):
				var r = color.r
				var g = color.g
				var b = color.b
				var a = color.a
				image_data.set_pixel(x, y, Color(r/a, g/a, b/a, a))
	
	active_project.layers[0].image_data = image_data
	StateManager.canvas_updated.emit()

func _ready() -> void:
	StateManager.active_project_changed.connect(on_project_changed)
