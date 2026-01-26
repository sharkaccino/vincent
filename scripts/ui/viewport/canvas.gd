extends TextureRect

@onready var subviewport = $LayerContentRenderer
@onready var canvas_grid = %CanvasGrid

func on_resized() -> void:
	var active_project = StateManager.get_active_project()
	
	var rect = get_rect()
	var width_check = rect.size.x < active_project.size.x
	var height_check = rect.size.y < active_project.size.y
	
	if width_check || height_check:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	else:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	canvas_grid.material.set_shader_parameter("screen_space_canvas_size", rect.size)

func on_canvas_updated() -> void:
	# TODO: show the combined output of all layers merged together.
	
	if (StateManager.active_project_id == 0):
		texture = null
		return
	
	var rect = get_rect()
	
	var active_project = StateManager.get_active_project()
	canvas_grid.material.set_shader_parameter("canvas_size", active_project.size)
	canvas_grid.material.set_shader_parameter("screen_space_canvas_size", rect.size)
	texture = ImageTexture.create_from_image(active_project.layers[0].image_data)

func update_view_mode(new_value: Enums.ViewMode) -> void:
	print("view mode updated")
	
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

func _ready() -> void:
	resized.connect(on_resized)
	StateManager.canvas_updated.connect(on_canvas_updated)
	StateManager.view_mode_changed.connect(update_view_mode)
