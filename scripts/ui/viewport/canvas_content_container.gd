extends Control

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
	var width_check = rect.size.x < active_project.size.x
	var height_check = rect.size.y < active_project.size.y
	
	if width_check || height_check:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	else:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func on_children_updated() -> void:
	for child in get_children():
		if child is CanvasItem:
			child.use_parent_material = true

func _ready() -> void:
	resized.connect(on_resized)
	StateManager.view_mode_changed.connect(update_view_mode)
	child_order_changed.connect(on_children_updated)
