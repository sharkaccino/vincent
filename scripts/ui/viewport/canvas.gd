extends TextureRect

# TODO: show the combined output of all layers merged together.

func check_filter_mode() -> void:
	var active_project = StateManager.get_active_project()
	
	var rect = get_rect()
	var width_check = rect.size.x < active_project.size.x
	var height_check = rect.size.y < active_project.size.y
	
	if width_check || height_check:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	else:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func on_active_project_changed() -> void:
	if StateManager.active_project_id == 0:
		texture = null
	else:
		var active_project = StateManager.get_active_project()
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
	custom_minimum_size = Vector2(0, 0)
	resized.connect(check_filter_mode)
	StateManager.active_project_changed.connect(on_active_project_changed)
	StateManager.view_mode_changed.connect(update_view_mode)
