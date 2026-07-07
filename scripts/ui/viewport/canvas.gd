extends TextureRect

var current_project_id = 0

func update_canvas() -> void:
	# TODO: show the combined output of all layers merged together.
	var project_id = StateManager.active_project_id
	if (project_id == 0):
		texture = null
		return
		
	var active_project = StateManager.get_active_project()
	
	if (texture == null):
		texture = ImageTexture.create_from_image(active_project.layers[0].image)
	elif (project_id != current_project_id):
		texture.set_image(active_project.layers[0].image)
	else:
		texture.update(active_project.layers[0].image)
	
	current_project_id = project_id

func _ready() -> void:
	StateManager.canvas = self
	
	StateManager.active_project_changed.connect(update_canvas)
	StateManager.canvas_updated.connect(update_canvas)
