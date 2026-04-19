extends SubViewport

@onready var layer_content = get_node("%LayerContent")
var last_pointer_pos = Vector2(0, 0)

func on_canvas_update_request() -> void:
	if (StateManager.active_project_id == 0):
		return
		
	var active_project = StateManager.get_active_project()
	
	var layer = active_project.active_layer_index
	var layer_content_data: Image = active_project.layers[layer].image_data
	layer_content.texture.update(layer_content_data)
	layer_content.material.set_shader_parameter("pointer_pos", last_pointer_pos)
	
	await RenderingServer.frame_post_draw
	
	var viewport_data = get_texture().get_image()
	var img_size = layer_content_data.get_size()
	layer_content_data.blend_rect(
		viewport_data, 
		Rect2i(0, 0, img_size.x, img_size.y), 
		Vector2i(0, 0)
	)
	layer_content_data.generate_mipmaps()
	
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

func on_pointer_move(pos: Vector2) -> void:
	last_pointer_pos = pos
	layer_content.material.set_shader_parameter("pointer_pos", pos)

func _ready() -> void:
	layer_content.texture = null
	StateManager.pointer_move.connect(on_pointer_move)
	StateManager.canvas_update_request.connect(on_canvas_update_request)
	StateManager.active_project_changed.connect(on_project_changed)
