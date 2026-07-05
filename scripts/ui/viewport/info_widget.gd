extends VBoxContainer

@onready var node_layer_name = $ActiveLayerName
@onready var node_pointer_pos = $PointerPosition

var current_layer_name = "?"
var last_pos = Vector2i(0, 0)

func update(value: Vector2) -> void:
	if (StateManager.active_project_id == 0):
		visible = false
		return
	visible = true
	
	node_layer_name.text = tr("INFO_WGT_LAYER_NAME").format({
		layer_name = current_layer_name
	})
	
	# TODO: make this configurable
	#var step = 0.1
	#var x_rounded = snapped(value.x, step)
	#var y_rounded = snapped(value.y, step)
	
	var x_rounded = int(floor(value.x))
	var y_rounded = int(floor(value.y))
	
	node_pointer_pos.text = tr("INFO_WGT_POSITION").format({
		x = x_rounded,
		y = y_rounded
	})
	
	last_pos = value

func update_layer_name() -> void:
	var active_project = StateManager.get_active_project()
	var layer_index = active_project.active_layer_index
	var active_layer: VincentProject.Layer = active_project.layers[layer_index]
	current_layer_name = active_layer.name
	update(last_pos)

func _ready() -> void:
	visible = false
	StateManager.active_project_changed.connect(update_layer_name)
	StateManager.pointer_move.connect(update)
