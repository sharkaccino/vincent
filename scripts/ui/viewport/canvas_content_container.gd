extends Control

var ci_rid

func update_view_mode(new_value: Enums.ViewMode) -> void:
	# default values
	material.set_shader_parameter("single_channel", false)
	material.set_shader_parameter("red_enabled", true)
	material.set_shader_parameter("green_enabled", true)
	material.set_shader_parameter("blue_enabled", true)
	material.set_shader_parameter("alpha_enabled", true)
	match (new_value):
		Enums.ViewMode.ONLY_COLOR:
			material.set_shader_parameter("alpha_enabled", false)
		Enums.ViewMode.RED:
			material.set_shader_parameter("single_channel", true)
			material.set_shader_parameter("green_enabled", false)
			material.set_shader_parameter("blue_enabled", false)
			material.set_shader_parameter("alpha_enabled", false)
		Enums.ViewMode.GREEN:
			material.set_shader_parameter("single_channel", true)
			material.set_shader_parameter("red_enabled", false)
			material.set_shader_parameter("blue_enabled", false)
			material.set_shader_parameter("alpha_enabled", false)
		Enums.ViewMode.BLUE:
			material.set_shader_parameter("single_channel", true)
			material.set_shader_parameter("red_enabled", false)
			material.set_shader_parameter("green_enabled", false)
			material.set_shader_parameter("alpha_enabled", false)
		Enums.ViewMode.ALPHA:
			material.set_shader_parameter("single_channel", true)
			material.set_shader_parameter("red_enabled", false)
			material.set_shader_parameter("green_enabled", false)
			material.set_shader_parameter("blue_enabled", false)

func on_resized() -> void:
	var active_project = StateManager.get_active_project()
	
	var rect = get_rect()
	var width_diff = rect.size.x / active_project.size.x
	var height_diff = rect.size.y / active_project.size.y
	
	if width_diff < 1.0 || height_diff < 1.0:
		RenderingServer.canvas_item_set_default_texture_filter(
			ci_rid, 
			RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		)
	else:
		RenderingServer.canvas_item_set_default_texture_filter(
			ci_rid, 
			RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		)
	
	var xform = Transform2D().scaled(Vector2(width_diff, height_diff))
	RenderingServer.canvas_item_set_transform(ci_rid, xform)

func redraw_chunks() -> void:
	RenderingServer.canvas_item_clear(ci_rid)
	var project = StateManager.get_active_project()
	if (project.id == 0): return
	
	for y in range(project.chunks.y):
		for x in range(project.chunks.x):
			var index = (project.chunks.x * y) + x
			var chunk: Texture2DRD = CanvasManager.chunks[index]
			
			RenderingServer.canvas_item_add_texture_rect(
				ci_rid, 
				Rect2(
					VincentProject.chunk_size * x,
					VincentProject.chunk_size * y,
					chunk.get_width(),
					chunk.get_height()
				), 
				chunk
			)
			
			RenderingServer.canvas_item_reset_physics_interpolation(ci_rid)
			
	on_resized() # ensure large canvases are loaded in at the correct scale

func _ready() -> void:
	ci_rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(ci_rid, get_canvas_item())
	RenderingServer.canvas_item_set_material(ci_rid, material)
	
	CanvasManager.chunks_rebuilt.connect(redraw_chunks)
	StateManager.view_mode_changed.connect(update_view_mode)
	resized.connect(on_resized)
