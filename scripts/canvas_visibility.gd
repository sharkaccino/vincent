extends Control

@onready var vp = %EditorViewport
@onready var canvas_node = %CanvasTransformControl

var canvas_width = 0
var canvas_height = 0
var canvas_zoom = 1.0
var canvas_rotation = 0

func _draw() -> void:
	var new_pos = vp.global_position - ((size - vp.size) / 2)
	
	# position adjustment to ensure the box stays centered on
	# the viewport while inheriting the rotation of the canvas
	var offset = (size / 2)
	var rad = deg_to_rad(canvas_rotation)
	new_pos += Vector2(
		(cos(rad) * (offset.x * -1)) - (sin(rad) * (offset.y * -1)) + offset.x,
		(sin(rad) * (offset.x * -1)) + (cos(rad) * (offset.y * -1)) + offset.y
	)
	
	global_position = new_pos
	
	var rect = get_rect()
	
	# convert rect to canvas space
	rect.position = Vector2(
		floorf(rect.position.x / canvas_zoom),
		floorf(rect.position.y / canvas_zoom)
	)
	rect.size = Vector2(
		ceilf(canvas_width * (rect.size.x / canvas_node.size.x)),
		ceilf(canvas_height * (rect.size.y / canvas_node.size.y))
	)
	
	# extra padding to eliminate leakage 
	# around the edges of the viewport
	var padding = 2
	rect.position -= Vector2(padding, padding)
	rect.size += Vector2(padding, padding) * 2
	
	# testing only
	#rect.position += Vector2(10.0, 10.0)
	#rect.size -= Vector2(20.0, 20.0)
	
	if (StateManager.canvas_visible_rect != rect):
		#print(rect)
		StateManager.canvas_visible_rect = rect
		StateManager.canvas_visible_rect_changed.emit()

func update_size() -> void:
	size = Utils.get_bounding_box_size(
		vp.size, 
		deg_to_rad(StateManager.get_active_project().viewport.rotate * -1)
	)

func on_project_changed() -> void:
	var active_project = StateManager.get_active_project()
	canvas_width = active_project.size.x
	canvas_height = active_project.size.y
	queue_redraw()
	
func on_zoom_level_changed() -> void:
	var active_project = StateManager.get_active_project()
	canvas_zoom = active_project.viewport.zoom
	queue_redraw()

func on_rotation_changed() -> void:
	var active_project = StateManager.get_active_project()
	canvas_rotation = active_project.viewport.rotate
	update_size()

func _ready() -> void:
	vp.draw.connect(func() -> void: queue_redraw())
	StateManager.rotation_changed.connect(on_rotation_changed)
	StateManager.active_project_changed.connect(on_project_changed)
	StateManager.zoom_level_changed.connect(on_zoom_level_changed)
	vp.resized.connect(update_size)
	
