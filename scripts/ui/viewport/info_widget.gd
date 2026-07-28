extends VBoxContainer

@onready var node_layer_name = $ActiveLayerName
@onready var node_pointer_pos = $PointerPosition
@onready var node_flip = $FlipStatus

func update_visibility() -> void:
	visible = StateManager.active_project_id != 0

func update_pos(value: Vector2) -> void:
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

func update_layer_name() -> void:
	var active_project = StateManager.get_active_project()
	var layer_index = active_project.active_layer_index
	var active_layer: VincentProject.Layer = active_project.layers[layer_index]
	
	node_layer_name.text = tr("INFO_WGT_LAYER_NAME").format({
		layer_name = active_layer.name
	})

func update_flip_status() -> void:
	var active_project = StateManager.get_active_project()
	var flags = 0
	
	if active_project.viewport.flip_x: flags += 1
	if active_project.viewport.flip_y: flags += 1
	
	if flags == 0: 
		node_flip.visible = false
		return
	node_flip.visible = true
	
	if flags == 2: 
		node_flip.text = tr("INFO_WGT_FLIP_BOTH")
		return
	
	if active_project.viewport.flip_x:
		node_flip.text = tr("INFO_WGT_FLIP_X")
	else:
		node_flip.text = tr("INFO_WGT_FLIP_Y")

func update_all() -> void:
	update_visibility()
	update_layer_name()
	update_flip_status()

func _ready() -> void:
	visible = false
	
	StateManager.active_project_changed.connect(update_all)
	#StateManager.active_layer_changed.connect(update_layer_name)
	StateManager.pointer_move.connect(update_pos)
	StateManager.canvas_flipped.connect(update_flip_status)
