extends Tree

@onready var no_project_label = $NoProjectLabel

var raw_text: String

func refresh_data() -> void:
	clear()
	
	var current_project: Project = StateManager.get_active_project()
	var root = create_item()
	
	if current_project.id == 0:
		no_project_label.visible = true
		return
	
	no_project_label.visible = false
	
	var cat_general = create_item(root)
	cat_general.set_text(0, "General")
	cat_general.set_selectable(0, false)
	
	var width = create_item(cat_general)
	width.set_text(0, "Width: %s" % current_project.size.x)
	
	var height = create_item(cat_general)
	height.set_text(0, "Height: %s" % current_project.size.y)
	
	var pixel_count = create_item(cat_general)
	pixel_count.set_text(0, "Pixel Count: %s" % (current_project.size.x * current_project.size.y))
	
	var cat_layers = create_item(root)
	cat_layers.set_text(0, "Layers")
	cat_layers.set_selectable(0, false)
	
	var layer_count = create_item(cat_layers)
	layer_count.set_text(0, "Layer Count: %s" % current_project.layers.size())
	
	var layers_visible = 0
	var layers_locked = 0
	var total_effects = 0
	var active_effects = 0
	var empty_layers = 0
	
	for layer in current_project.layers:
		if layer.visible:
			layers_visible += 1
		if layer.locked:
			layers_locked += 1
		if layer.image_data.is_invisible():
			empty_layers += 1
		
		for effect in layer.effects:
			total_effects += 1
			
			if effect.enabled:
				active_effects += 1
	
	var item_visible_layers = create_item(cat_layers)
	item_visible_layers.set_text(0, "Visible Layers: %s" % layers_visible)
	
	var item_locked_layers = create_item(cat_layers)
	item_locked_layers.set_text(0, "Locked Layers: %s" % layers_locked)
	
	var item_empty_layers = create_item(cat_layers)
	item_empty_layers.set_text(0, "Empty Layers: %s" % empty_layers)
	
	var item_effects = create_item(cat_layers)
	item_effects.set_text(0, "Total Layer Effects: %s" % total_effects)
	
	var item_active_effects = create_item(cat_layers)
	item_active_effects.set_text(0, "Active Layer Effects: %s" % active_effects)

func _ready() -> void:
	no_project_label.add_theme_color_override("font_color", get_theme_color("font_color"))
	StateManager.active_project_changed.connect(refresh_data)
	
