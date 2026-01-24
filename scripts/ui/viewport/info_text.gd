extends Label

var layer_name = "?"
var last_pos = Vector2i(0, 0)

func update(value: Vector2) -> void:
	if (StateManager.active_project_id == 0):
		visible = false
		return
	visible = true
	
	var layer_text = str("Layer: ", layer_name)
	
	# TODO: make this configurable
	var step = 1
	var x_rounded = snapped(value.x, step)
	var y_rounded = snapped(value.y, step)
	
	var pos_text = str("Pos: ", x_rounded, ", ", y_rounded)
	
	text = str(layer_text, "\n", pos_text)
	last_pos = value

func update_layer_name() -> void:
	var active_project = StateManager.get_active_project()
	var layer_index = active_project.active_layer_index
	var active_layer: VincentProject.Layer = active_project.layers[layer_index]
	layer_name = active_layer.name
	update(last_pos)

func _ready() -> void:
	visible = false
	StateManager.active_project_changed.connect(update_layer_name)
	StateManager.pointer_move.connect(update)
